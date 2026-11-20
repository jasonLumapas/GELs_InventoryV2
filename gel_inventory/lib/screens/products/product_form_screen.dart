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
import '../../models/product_supplier_price.dart';
import '../../repositories/product_discount_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/product_supplier_price_repository.dart';
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
  final _productCodeCtrl = TextEditingController();
  final _piecesCtrl = TextEditingController();
  final _withdrawalBoxCtrl = TextEditingController();
  final _sellingCtrl = TextEditingController();
  final _sellingOpCtrl = TextEditingController();
  final _reorderPointCtrl = TextEditingController();
  final _reorderQuantityCtrl = TextEditingController();

  late TabController _tabController;
  bool _loading = false;
  Product? _existing;
  List<ProductPrice> _priceHistory = [];
  List<Supplier> _suppliers = [];
  String? _selectedSupplierId;
  ProductDiscount? _existingDiscount;
  ProductSupplierPrice? _existingSupplierPrice;
  final _supplierPriceBoxCtrl = TextEditingController();
  final List<double> _supplierDiscountPercents = [];
  bool _supplierVatEnabled = false;
  bool _supplierBuyXGetYEnabled = false;
  final _supplierBuyQtyCtrl = TextEditingController();
  final _supplierFreeQtyCtrl = TextEditingController();
  String _supplierFreeQtyUnit = 'box'; // 'piece' | 'box'
  // Separate controllers per discount type so values don't bleed when toggling
  final _percentMinQtyCtrl = TextEditingController();
  final _percentValueCtrl  = TextEditingController();
  final _amountMinQtyCtrl  = TextEditingController();
  final _amountValueCtrl   = TextEditingController();
  final _buyQtyCtrl  = TextEditingController();
  final _freeQtyCtrl = TextEditingController();
  String _discountType = 'percent'; // 'percent' | 'amount' | 'buy_x_get_y'
  String _freeQtyUnit = 'box'; // 'piece' | 'box'
  bool _percentEnabled  = false;
  bool _amountEnabled   = false;
  bool _buyXGetYEnabled = false;

  TextEditingController get _activeMinQtyCtrl =>
      _discountType == 'percent' ? _percentMinQtyCtrl : _amountMinQtyCtrl;
  TextEditingController get _activeValueCtrl =>
      _discountType == 'percent' ? _percentValueCtrl : _amountValueCtrl;

  bool get isNew => widget.productId == null || widget.productId == 'new';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: isNew ? 1 : 4, vsync: this);
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
        _productCodeCtrl.text = _existing!.productCode ?? '';
        _piecesCtrl.text = _existing!.piecesPerBox.toString();
        _selectedSupplierId = _existing!.supplierId;
        _reorderPointCtrl.text = _existing!.reorderPoint?.toString() ?? '';
        _reorderQuantityCtrl.text =
            _existing!.reorderQuantity?.toString() ?? '';
        _priceHistory = await ref
            .read(productRepositoryProvider)
            .getPriceHistory(_existing!.id);
        if (_priceHistory.isNotEmpty) {
          _withdrawalBoxCtrl.text = (_priceHistory.first.withdrawalPrice *
                  _existing!.piecesPerBox)
              .toStringAsFixed(2);
          _sellingCtrl.text =
              _priceHistory.first.sellingPrice.toStringAsFixed(2);
          _sellingOpCtrl.text =
              _priceHistory.first.sellingPriceOp?.toStringAsFixed(2) ?? '';
        }
        _existingSupplierPrice = await ref
            .read(productSupplierPriceRepositoryProvider)
            .getForProduct(_existing!.id);
        if (_existingSupplierPrice != null) {
          _supplierPriceBoxCtrl.text =
              _existingSupplierPrice!.priceBox.toStringAsFixed(2);
          _supplierDiscountPercents
            ..clear()
            ..addAll(_existingSupplierPrice!.discountPercents);
          _supplierVatEnabled = _existingSupplierPrice!.vatEnabled;
          _supplierBuyXGetYEnabled = _existingSupplierPrice!.hasBuyXGetY;
          if (_supplierBuyXGetYEnabled) {
            final ppb = _existing!.piecesPerBox;
            _supplierBuyQtyCtrl.text =
                (_existingSupplierPrice!.buyMinQuantityPieces! ~/ ppb)
                    .toString();
            _supplierFreeQtyUnit = _existingSupplierPrice!.freeQuantityUnit;
            final freeQtyPieces = _existingSupplierPrice!.freeQuantityPieces!;
            _supplierFreeQtyCtrl.text = (_supplierFreeQtyUnit == 'box'
                    ? freeQtyPieces ~/ ppb
                    : freeQtyPieces)
                .toString();
          }
        }
        _existingDiscount = await ref
            .read(productDiscountRepositoryProvider)
            .getForProduct(_existing!.id);
        if (_existingDiscount != null) {
          final ppb = _existing!.piecesPerBox;
          _discountType = _existingDiscount!.discountType;
          _percentEnabled  = _discountType == 'percent';
          _amountEnabled   = _discountType == 'amount';
          _buyXGetYEnabled = _discountType == 'buy_x_get_y';
          if (_buyXGetYEnabled) {
            _buyQtyCtrl.text =
                (_existingDiscount!.minQuantityPieces ~/ ppb).toString();
            _freeQtyUnit = _existingDiscount!.freeQuantityUnit;
            final freeQtyPieces = _existingDiscount!.freeQuantityPieces ?? 0;
            _freeQtyCtrl.text = (_freeQtyUnit == 'box'
                    ? freeQtyPieces ~/ ppb
                    : freeQtyPieces)
                .toString();
          } else {
            // Populate only the matching type's controllers
            _activeMinQtyCtrl.text =
                (_existingDiscount!.minQuantityPieces ~/ ppb).toString();
            _activeValueCtrl.text =
                _existingDiscount!.discountValue.toStringAsFixed(1);
          }
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
    _productCodeCtrl.dispose();
    _piecesCtrl.dispose();
    _withdrawalBoxCtrl.dispose();
    _sellingCtrl.dispose();
    _sellingOpCtrl.dispose();
    _reorderPointCtrl.dispose();
    _reorderQuantityCtrl.dispose();
    _percentMinQtyCtrl.dispose();
    _percentValueCtrl.dispose();
    _amountMinQtyCtrl.dispose();
    _amountValueCtrl.dispose();
    _buyQtyCtrl.dispose();
    _freeQtyCtrl.dispose();
    _supplierPriceBoxCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final product = Product(
      id: _existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      productCode:
          _productCodeCtrl.text.trim().isEmpty ? null : _productCodeCtrl.text.trim(),
      supplierId: _selectedSupplierId!,
      piecesPerBox: int.parse(_piecesCtrl.text),
      createdAt: _existing?.createdAt ?? DateTime.now(),
      reorderPoint: int.tryParse(_reorderPointCtrl.text),
      reorderQuantity: int.tryParse(_reorderQuantityCtrl.text),
    );
    await ref.read(productRepositoryProvider).upsertProduct(product);

    // Add price if entered. Withdrawal price is entered per box and divided
    // down to per-piece at full precision, so re-multiplying by
    // piecesPerBox elsewhere (e.g. supplier deliveries) reproduces the
    // box price exactly instead of drifting from 2-decimal rounding.
    final withdrawalBox = double.tryParse(_withdrawalBoxCtrl.text);
    final withdrawal = withdrawalBox != null && product.piecesPerBox > 0
        ? withdrawalBox / product.piecesPerBox
        : null;
    final selling = double.tryParse(_sellingCtrl.text);
    final sellingOp = double.tryParse(_sellingOpCtrl.text);
    if (withdrawal != null && selling != null) {
      final currentPrice =
          isNew ? null : _priceHistory.firstOrNull;
      final needsNewPrice = currentPrice == null ||
          currentPrice.withdrawalPrice != withdrawal ||
          currentPrice.sellingPrice != selling ||
          currentPrice.sellingPriceOp != sellingOp;
      if (needsNewPrice) {
        await ref.read(productRepositoryProvider).addPrice(ProductPrice(
              id: const Uuid().v4(),
              productId: product.id,
              withdrawalPrice: withdrawal,
              sellingPrice: selling,
              sellingPriceOp: sellingOp,
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

    final bool hasActive = _percentEnabled || _amountEnabled || _buyXGetYEnabled;
    if (!hasActive) {
      await ref
          .read(productDiscountRepositoryProvider)
          .deleteForProduct(existing.id);
      setState(() => _existingDiscount = null);
    } else if (_buyXGetYEnabled) {
      final buyBoxes = int.tryParse(_buyQtyCtrl.text);
      final freeQty  = int.tryParse(_freeQtyCtrl.text);
      if (buyBoxes != null && buyBoxes > 0 &&
          freeQty != null && freeQty > 0) {
        final newDiscount = ProductDiscount(
          id: _existingDiscount?.id ?? const Uuid().v4(),
          productId: existing.id,
          minQuantityPieces: buyBoxes * existing.piecesPerBox,
          discountValue: 0,
          discountType: 'buy_x_get_y',
          freeQuantityPieces: _freeQtyUnit == 'box'
              ? freeQty * existing.piecesPerBox
              : freeQty,
          freeQuantityUnit: _freeQtyUnit,
        );
        await ref.read(productDiscountRepositoryProvider).upsert(newDiscount);
        setState(() => _existingDiscount = newDiscount);
      }
    } else {
      final minBoxes = int.tryParse(_activeMinQtyCtrl.text);
      final discVal  = double.tryParse(_activeValueCtrl.text);
      if (minBoxes != null && minBoxes > 0 && discVal != null && discVal > 0) {
        final newDiscount = ProductDiscount(
          id: _existingDiscount?.id ?? const Uuid().v4(),
          productId: existing.id,
          minQuantityPieces: minBoxes * existing.piecesPerBox,
          discountValue: discVal,
          discountType: _discountType,
        );
        await ref.read(productDiscountRepositoryProvider).upsert(newDiscount);
        setState(() => _existingDiscount = newDiscount);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discount rule saved.')),
      );
    }
  }

  /// Saves only the supplier price for an existing product.
  /// Called from the Supplier Pricing tab so the Details form doesn't need
  /// to be mounted.
  Future<void> _saveSupplierPricingOnly() async {
    final existing = _existing;
    if (existing == null) return;

    final priceBox = double.tryParse(_supplierPriceBoxCtrl.text);
    int? buyMinQuantityPieces;
    int? freeQuantityPieces;
    if (_supplierBuyXGetYEnabled) {
      final buyBoxes = int.tryParse(_supplierBuyQtyCtrl.text);
      final freeQty = int.tryParse(_supplierFreeQtyCtrl.text);
      if (buyBoxes != null && buyBoxes > 0 &&
          freeQty != null && freeQty > 0) {
        buyMinQuantityPieces = buyBoxes * existing.piecesPerBox;
        freeQuantityPieces = _supplierFreeQtyUnit == 'box'
            ? freeQty * existing.piecesPerBox
            : freeQty;
      }
    }
    final hasBuyXGetY = buyMinQuantityPieces != null && freeQuantityPieces != null;

    if ((priceBox == null || priceBox <= 0) && !hasBuyXGetY) {
      await ref
          .read(productSupplierPriceRepositoryProvider)
          .deleteForProduct(existing.id);
      setState(() => _existingSupplierPrice = null);
    } else {
      final newPrice = ProductSupplierPrice(
        id: _existingSupplierPrice?.id ?? const Uuid().v4(),
        productId: existing.id,
        priceBox: (priceBox != null && priceBox > 0)
            ? priceBox
            : (_existingSupplierPrice?.priceBox ?? 0),
        discountPercents: List<double>.from(_supplierDiscountPercents),
        vatEnabled: _supplierVatEnabled,
        buyMinQuantityPieces: buyMinQuantityPieces,
        freeQuantityPieces: freeQuantityPieces,
        freeQuantityUnit: _supplierFreeQtyUnit,
      );
      await ref.read(productSupplierPriceRepositoryProvider).upsert(newPrice);
      setState(() => _existingSupplierPrice = newPrice);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier price saved.')),
      );
    }
  }

  double? get _withdrawalPerPiece {
    final ppb = int.tryParse(_piecesCtrl.text) ?? _existing?.piecesPerBox ?? 1;
    final box = double.tryParse(_withdrawalBoxCtrl.text);
    return box != null && ppb > 0 ? box / ppb : null;
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
                      Tab(text: 'Supplier Pricing'),
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
                            _buildSupplierPricing(),
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
            TextFormField(
              controller: _productCodeCtrl,
              decoration: const InputDecoration(labelText: 'Product Code'),
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
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (int.tryParse(v) == null || int.parse(v) < 1) {
                  return 'Must be â‰¥ 1';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Reorder Settings',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Used by the Reports > Reorder tab to flag low stock. Leave '
              'blank to rely on sales velocity only.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _reorderPointCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Reorder Point (pcs)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _reorderQuantityCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Reorder Quantity (pcs)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Pricing',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Withdrawal price per piece is computed automatically from '
              'price per box.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _withdrawalBoxCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Withdrawal Price (Box)'),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'Withdrawal Price/pc (computed)'),
                    child: Text(_withdrawalPerPiece != null
                        ? '₱ ${_withdrawalPerPiece!.toStringAsFixed(2)}'
                        : '—'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sellingCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Selling Price/pc (GELs)'),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sellingOpCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Selling Price/pc (OP)'),
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
    final ppb = int.tryParse(_piecesCtrl.text) ?? _existing?.piecesPerBox ?? 1;

    Widget discountSection({
      required String title,
      required IconData icon,
      required bool enabled,
      required ValueChanged<bool?> onToggle,
      required TextEditingController minQtyCtrl,
      required TextEditingController valueCtrl,
      required String valueLabel,
      String? suffixText,
      String? prefixText,
    }) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            CheckboxListTile(
              value: enabled,
              onChanged: onToggle,
              title: Row(
                children: [
                  Icon(icon, size: 16),
                  const SizedBox(width: 6),
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (enabled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: minQtyCtrl,
                      enabled: enabled,
                      decoration: InputDecoration(
                        labelText: 'Minimum quantity (boxes)',
                        helperText: ppb > 0
                            ? '= ${(int.tryParse(minQtyCtrl.text) ?? 0) * ppb} pcs'
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: valueCtrl,
                      enabled: enabled,
                      decoration: InputDecoration(
                        labelText: valueLabel,
                        suffixText: suffixText,
                        prefixText: prefixText,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quantity Discount',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            'Enable one discount type. Enabling one disables the other.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 12),
          discountSection(
            title: 'Percentage Discount',
            icon: Icons.percent,
            enabled: _percentEnabled,
            onToggle: (val) => setState(() {
              _percentEnabled = val ?? false;
              if (_percentEnabled) {
                _amountEnabled = false;
                _buyXGetYEnabled = false;
                _discountType = 'percent';
              }
            }),
            minQtyCtrl: _percentMinQtyCtrl,
            valueCtrl: _percentValueCtrl,
            valueLabel: 'Discount %',
            suffixText: '%',
          ),
          discountSection(
            title: 'Fixed Amount Discount',
            icon: Icons.attach_money,
            enabled: _amountEnabled,
            onToggle: (val) => setState(() {
              _amountEnabled = val ?? false;
              if (_amountEnabled) {
                _percentEnabled = false;
                _buyXGetYEnabled = false;
                _discountType = 'amount';
              }
            }),
            minQtyCtrl: _amountMinQtyCtrl,
            valueCtrl: _amountValueCtrl,
            valueLabel: 'Discount Amount (₱)',
            prefixText: '₱ ',
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                CheckboxListTile(
                  value: _buyXGetYEnabled,
                  onChanged: (val) => setState(() {
                    _buyXGetYEnabled = val ?? false;
                    if (_buyXGetYEnabled) {
                      _percentEnabled = false;
                      _amountEnabled = false;
                      _discountType = 'buy_x_get_y';
                    }
                  }),
                  title: const Row(
                    children: [
                      Icon(Icons.card_giftcard, size: 16),
                      SizedBox(width: 6),
                      Text('Buy X Get Y Free',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (_buyXGetYEnabled)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _buyQtyCtrl,
                          decoration: InputDecoration(
                            labelText: 'Buy quantity (boxes)',
                            helperText: ppb > 0
                                ? '= ${(int.tryParse(_buyQtyCtrl.text) ?? 0) * ppb} pcs'
                                : null,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _freeQtyCtrl,
                                decoration: InputDecoration(
                                  labelText: _freeQtyUnit == 'box'
                                      ? 'Free quantity (boxes)'
                                      : 'Free quantity (pieces)',
                                  helperText: _freeQtyUnit == 'box' && ppb > 0
                                      ? '= ${(int.tryParse(_freeQtyCtrl.text) ?? 0) * ppb} pcs per cycle'
                                      : 'per cycle',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'box', label: Text('Box')),
                                ButtonSegment(value: 'piece', label: Text('Pcs')),
                              ],
                              selected: {_freeQtyUnit},
                              onSelectionChanged: (s) =>
                                  setState(() => _freeQtyUnit = s.first),
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_existingDiscount != null) ...[
            Text(
              _existingDiscount!.isBuyXGetY
                  ? () {
                      final freeQtyPieces = _existingDiscount!.freeQuantityPieces ?? 0;
                      final freeUnit = _existingDiscount!.freeQuantityUnit;
                      final freeDisplay = freeUnit == 'box'
                          ? '${freeQtyPieces ~/ ppb} box(es)'
                          : '$freeQtyPieces piece(s)';
                      return 'Active: Buy ${_existingDiscount!.minQuantityPieces ~/ ppb} box(es) → +$freeDisplay free (per cycle)';
                    }()
                  : _existingDiscount!.isPercent
                      ? 'Active: ${_existingDiscount!.minQuantityPieces ~/ ppb} boxes → ${_existingDiscount!.discountValue.toStringAsFixed(1)}% off'
                      : 'Active: ${_existingDiscount!.minQuantityPieces ~/ ppb} boxes → ₱${_existingDiscount!.discountValue.toStringAsFixed(2)} off',
              style: TextStyle(color: Colors.green.shade700, fontSize: 13),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
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
                    'Sell: ${formatCurrency(p.sellingPrice)}'
                    '${p.sellingPriceOp != null ? ' | OP: ${formatCurrency(p.sellingPriceOp!)}' : ''}'
                    ' | Withdraw: ${formatCurrency(p.withdrawalPrice)}'),
                subtitle: Text('Effective: ${dateFmt.format(p.effectiveFrom)}'),
                trailing: i == 0
                    ? const Chip(label: Text('Current'))
                    : null,
              );
            },
          );
  }

  /// Combined multiplier applying every discount in sequence (cascading,
  /// each discount taken off the previous net value), then VAT if enabled.
  double get _supplierPriceMultiplier {
    double m = 1.0;
    for (final d in _supplierDiscountPercents) {
      m *= (1 - d / 100);
    }
    if (_supplierVatEnabled) m *= 1.12;
    return m;
  }

  Future<void> _promptAddSupplierDiscount() async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Discount'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Discount %',
              isDense: true,
              suffixText: '%',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
            ],
            validator: (v) {
              final n = double.tryParse(v ?? '');
              if (n == null || n <= 0 || n > 100) {
                return 'Enter a value between 0 and 100';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx, double.parse(ctrl.text));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (value != null) {
      setState(() => _supplierDiscountPercents.add(value));
    }
  }

  Widget _buildSupplierPricing() {
    final ppb = int.tryParse(_piecesCtrl.text) ?? _existing?.piecesPerBox ?? 1;
    final priceBox = double.tryParse(_supplierPriceBoxCtrl.text);
    final pricePerPiece =
        priceBox != null && ppb > 0 ? priceBox / ppb : null;
    final netValueBox =
        priceBox != null ? priceBox * _supplierPriceMultiplier : null;
    final netValuePerPiece =
        netValueBox != null && ppb > 0 ? netValueBox / ppb : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Supplier Price',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            'Price per piece is computed automatically from price per box.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _supplierPriceBoxCtrl,
            decoration: const InputDecoration(
              labelText: 'Price per Box',
              prefixText: '₱ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Price per Piece (computed)',
            ),
            child: Text(
              pricePerPiece != null
                  ? '₱ ${pricePerPiece.toStringAsFixed(2)}'
                  : '—',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.percent, size: 16),
                label: const Text('Add Discount %'),
                onPressed: _promptAddSupplierDiscount,
              ),
              for (int i = 0; i < _supplierDiscountPercents.length; i++)
                Chip(
                  label:
                      Text('${formatNumber(_supplierDiscountPercents[i])}% off'),
                  onDeleted: () =>
                      setState(() => _supplierDiscountPercents.removeAt(i)),
                ),
              FilterChip(
                label: const Text('Add VAT (12%)'),
                selected: _supplierVatEnabled,
                onSelected: (v) => setState(() => _supplierVatEnabled = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Net Value (Box)',
            ),
            child: SelectableText(
              netValueBox != null ? '₱ ${netValueBox.toStringAsFixed(2)}' : '—',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Net Value (Piece)',
            ),
            child: SelectableText(
              netValuePerPiece != null
                  ? '₱ ${netValuePerPiece.toStringAsFixed(2)}'
                  : '—',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                CheckboxListTile(
                  value: _supplierBuyXGetYEnabled,
                  onChanged: (val) => setState(
                      () => _supplierBuyXGetYEnabled = val ?? false),
                  title: const Row(
                    children: [
                      Icon(Icons.card_giftcard, size: 16),
                      SizedBox(width: 6),
                      Text('Buy X Get Y Free (Supplier Term)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (_supplierBuyXGetYEnabled)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _supplierBuyQtyCtrl,
                          decoration: InputDecoration(
                            labelText: 'Buy quantity (boxes)',
                            helperText: ppb > 0
                                ? '= ${(int.tryParse(_supplierBuyQtyCtrl.text) ?? 0) * ppb} pcs'
                                : null,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _supplierFreeQtyCtrl,
                                decoration: InputDecoration(
                                  labelText: _supplierFreeQtyUnit == 'box'
                                      ? 'Free quantity (boxes)'
                                      : 'Free quantity (pieces)',
                                  helperText:
                                      _supplierFreeQtyUnit == 'box' && ppb > 0
                                          ? '= ${(int.tryParse(_supplierFreeQtyCtrl.text) ?? 0) * ppb} pcs per cycle'
                                          : 'per cycle',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'box', label: Text('Box')),
                                ButtonSegment(value: 'piece', label: Text('Pcs')),
                              ],
                              selected: {_supplierFreeQtyUnit},
                              onSelectionChanged: (s) => setState(
                                  () => _supplierFreeQtyUnit = s.first),
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_existingSupplierPrice?.hasBuyXGetY ?? false) ...[
            Builder(builder: (_) {
              final freeQtyPieces =
                  _existingSupplierPrice!.freeQuantityPieces ?? 0;
              final freeUnit = _existingSupplierPrice!.freeQuantityUnit;
              final freeDisplay = freeUnit == 'box'
                  ? '${freeQtyPieces ~/ ppb} box(es)'
                  : '$freeQtyPieces piece(s)';
              return Text(
                'Active: Buy ${_existingSupplierPrice!.buyMinQuantityPieces! ~/ ppb} '
                'box(es) → +$freeDisplay free (per cycle)',
                style: TextStyle(color: Colors.green.shade700, fontSize: 13),
              );
            }),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _saveSupplierPricingOnly,
              child: const Text('Save Supplier Price'),
            ),
          ),
        ],
      ),
    );
  }
}


