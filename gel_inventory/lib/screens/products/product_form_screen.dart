import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/product.dart';
import '../../models/product_price.dart';
import '../../models/supplier.dart';
import '../../models/product_discount.dart';
import '../../repositories/product_discount_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;
  const ProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _piecesCtrl = TextEditingController();
  final _withdrawalCtrl = TextEditingController();
  final _sellingCtrl = TextEditingController();

  late TabController _tabController;
  bool _loading = false;
  Product? _existing;
  List<ProductPrice> _priceHistory = [];
  List<Supplier> _suppliers = [];
  String? _selectedSupplierId;
  ProductDiscount? _existingDiscount;
  // Separate controllers per discount type so values don't bleed when toggling
  final _percentMinQtyCtrl = TextEditingController();
  final _percentValueCtrl  = TextEditingController();
  final _amountMinQtyCtrl  = TextEditingController();
  final _amountValueCtrl   = TextEditingController();
  String _discountType = 'percent'; // 'percent' | 'amount'

  TextEditingController get _activeMinQtyCtrl =>
      _discountType == 'percent' ? _percentMinQtyCtrl : _amountMinQtyCtrl;
  TextEditingController get _activeValueCtrl =>
      _discountType == 'percent' ? _percentValueCtrl : _amountValueCtrl;

  bool get isNew => widget.productId == null || widget.productId == 'new';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: isNew ? 1 : 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    _suppliers = await ref.read(supplierRepositoryProvider).getAll();
    if (!isNew) {
      final all = await ref.read(productRepositoryProvider).getAll();
      _existing = all.where((p) => p.id == widget.productId).firstOrNull;
      if (_existing != null) {
        _nameCtrl.text = _existing!.name;
        _piecesCtrl.text = _existing!.piecesPerBox.toString();
        _selectedSupplierId = _existing!.supplierId;
        _priceHistory = await ref
            .read(productRepositoryProvider)
            .getPriceHistory(_existing!.id);
        if (_priceHistory.isNotEmpty) {
          _withdrawalCtrl.text =
              _priceHistory.first.withdrawalPrice.toStringAsFixed(2);
          _sellingCtrl.text =
              _priceHistory.first.sellingPrice.toStringAsFixed(2);
        }
        _existingDiscount = await ref
            .read(productDiscountRepositoryProvider)
            .getForProduct(_existing!.id);
        if (_existingDiscount != null) {
          final ppb = _existing!.piecesPerBox;
          _discountType = _existingDiscount!.discountType;
          // Populate only the matching type's controllers
          _activeMinQtyCtrl.text =
              (_existingDiscount!.minQuantityPieces ~/ ppb).toString();
          _activeValueCtrl.text =
              _existingDiscount!.discountValue.toStringAsFixed(1);
        }
      }
    } else if (_suppliers.isNotEmpty) {
      _selectedSupplierId = _suppliers.first.id;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _piecesCtrl.dispose();
    _withdrawalCtrl.dispose();
    _sellingCtrl.dispose();
    _percentMinQtyCtrl.dispose();
    _percentValueCtrl.dispose();
    _amountMinQtyCtrl.dispose();
    _amountValueCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final product = Product(
      id: _existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      supplierId: _selectedSupplierId!,
      piecesPerBox: int.parse(_piecesCtrl.text),
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );
    await ref.read(productRepositoryProvider).upsertProduct(product);

    // Add price if entered
    final withdrawal = double.tryParse(_withdrawalCtrl.text);
    final selling = double.tryParse(_sellingCtrl.text);
    if (withdrawal != null && selling != null) {
      final currentPrice =
          isNew ? null : _priceHistory.firstOrNull;
      final needsNewPrice = currentPrice == null ||
          currentPrice.withdrawalPrice != withdrawal ||
          currentPrice.sellingPrice != selling;
      if (needsNewPrice) {
        await ref.read(productRepositoryProvider).addPrice(ProductPrice(
              id: const Uuid().v4(),
              productId: product.id,
              withdrawalPrice: withdrawal,
              sellingPrice: selling,
              effectiveFrom: DateTime.now(),
            ));
      }
    }

    ref.invalidate(productsListProvider);
    if (mounted) context.go('/products');
  }

  /// Saves only the discount rule for an existing product.
  /// Called from the Discount tab so the Details form doesn't need to be mounted.
  Future<void> _saveDiscountOnly() async {
    final existing = _existing;
    if (existing == null) return;

    final minBoxes = int.tryParse(_activeMinQtyCtrl.text);
    final discPct = double.tryParse(_activeValueCtrl.text);

    if (minBoxes != null && minBoxes > 0 && discPct != null && discPct > 0) {
      final newDiscount = ProductDiscount(
        id: _existingDiscount?.id ?? const Uuid().v4(),
        productId: existing.id,
        minQuantityPieces: minBoxes * existing.piecesPerBox,
        discountValue: discPct,
        discountType: _discountType,
      );
      await ref.read(productDiscountRepositoryProvider).upsert(newDiscount);
      setState(() => _existingDiscount = newDiscount);
    } else {
      await ref
          .read(productDiscountRepositoryProvider)
          .deleteForProduct(existing.id);
      setState(() => _existingDiscount = null);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discount rule saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: isNew ? 'New Product' : 'Edit Product',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!isNew)
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'Price History'),
                      Tab(text: 'Discount'),
                    ],
                  ),
                Expanded(
                  child: isNew
                      ? _buildForm()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildForm(),
                            _buildPriceHistory(),
                            _buildDiscount(),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Product Name *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedSupplierId,
              decoration: const InputDecoration(labelText: 'Supplier *'),
              items: _suppliers
                  .map((s) =>
                      DropdownMenuItem(value: s.id, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSupplierId = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _piecesCtrl,
              decoration: const InputDecoration(labelText: 'Pieces per Box *'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (int.tryParse(v) == null || int.parse(v) < 1) {
                  return 'Must be â‰¥ 1';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Pricing',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _withdrawalCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Withdrawal Price/pc'),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sellingCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Selling Price/pc'),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/products'),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _save,
                  child: Text(isNew ? 'Create' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscount() {
    final ppb = int.tryParse(_piecesCtrl.text) ??
        _existing?.piecesPerBox ??
        1;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantity Discount',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Automatically apply a discount when the ordered quantity reaches a threshold.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 12),
          // Discount type selector
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                  value: 'percent',
                  icon: Icon(Icons.percent, size: 16),
                  label: Text('Percentage')),
              ButtonSegment(
                  value: 'amount',
                  icon: Icon(Icons.attach_money, size: 16),
                  label: Text('Fixed Amount')),
            ],
            selected: {_discountType},
            onSelectionChanged: (s) => setState(() => _discountType = s.first),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _activeMinQtyCtrl,
            decoration: InputDecoration(
              labelText: 'Minimum quantity (boxes) to trigger discount',
              helperText: ppb > 0
                  ? '= ${(int.tryParse(_activeMinQtyCtrl.text) ?? 0) * ppb} pcs'
                  : null,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _activeValueCtrl,
            decoration: InputDecoration(
              labelText: _discountType == 'percent'
                  ? 'Discount %'
                  : 'Discount Amount (₱)',
              suffixText: _discountType == 'percent' ? '%' : null,
              prefixText: _discountType == 'amount' ? '₱ ' : null,
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 8),
          if (_existingDiscount != null)
            Text(
              _existingDiscount!.isPercent
                  ? 'Current: ${(_existingDiscount!.minQuantityPieces ~/ ppb)} boxes → ${_existingDiscount!.discountValue.toStringAsFixed(1)}% off'
                  : 'Current: ${(_existingDiscount!.minQuantityPieces ~/ ppb)} boxes → ₱${_existingDiscount!.discountValue.toStringAsFixed(2)} off',
              style: TextStyle(color: Colors.green.shade700, fontSize: 13),
            ),
          const SizedBox(height: 24),
          Text(
            'Leave both fields empty to remove the discount rule.',
            style:
                TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _saveDiscountOnly,
              child: const Text('Save Discount'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceHistory() {
    final dateFmt = DateFormat('MMM dd, yyyy HH:mm');
    return _priceHistory.isEmpty
        ? const Center(child: Text('No price history yet.'))
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _priceHistory.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = _priceHistory[i];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(
                    'Sell: ${formatCurrency(p.sellingPrice)} | Withdraw: ${formatCurrency(p.withdrawalPrice)}'),
                subtitle: Text('Effective: ${dateFmt.format(p.effectiveFrom)}'),
                trailing: i == 0
                    ? const Chip(label: Text('Current'))
                    : null,
              );
            },
          );
  }
}


