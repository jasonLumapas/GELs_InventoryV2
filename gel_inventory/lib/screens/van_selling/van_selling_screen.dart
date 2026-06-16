import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/product.dart';
import '../../models/van_stock.dart';
import '../../models/van_area.dart';
import '../../models/van_stock_draft.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../repositories/van_area_repository.dart';
import '../../repositories/van_stock_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/search_picker.dart';

class _VanLineItem {
  final Product product;
  String unitType = 'box';
  int quantity = 0;

  _VanLineItem(this.product);

  int get pieces =>
      unitType == 'box' ? quantity * product.piecesPerBox : quantity;
}

class _ReportRow {
  final String productName;
  final int piecesPerBox;
  final int loadedPieces;
  final int returnedPieces;
  final double sellingPrice;

  const _ReportRow({
    required this.productName,
    required this.piecesPerBox,
    required this.loadedPieces,
    required this.returnedPieces,
    this.sellingPrice = 0,
  });

  int get soldPieces    => (loadedPieces - returnedPieces).clamp(0, 999999);
  String _fmt(int pcs)  =>
      '${pcs ~/ piecesPerBox} box${pcs ~/ piecesPerBox == 1 ? '' : 'es'}'
      '${pcs % piecesPerBox > 0 ? ' + ${pcs % piecesPerBox} pcs' : ''}';
  String get loadedFmt   => _fmt(loadedPieces);
  String get returnedFmt => _fmt(returnedPieces);
  String get soldFmt     => _fmt(soldPieces);
}

class VanSellingScreen extends ConsumerStatefulWidget {
  const VanSellingScreen({super.key});

  @override
  ConsumerState<VanSellingScreen> createState() => _VanSellingScreenState();
}

class _VanSellingScreenState extends ConsumerState<VanSellingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  // Shared data
  List<Product>       _products      = [];
  List<VanArea>       _areas         = [];
  Map<String, String> _supplierNames = {};
  Map<String, int>    _inventoryQty  = {};
  final Map<String, double> _sellingPrices = {};
  bool _loading = true;

  // Per-tab area filters
  String? _outAreaFilter;
  String? _inAreaFilter;

  // Loading tab search + inline editing
  final _outSearchCtrl = TextEditingController();
  String _outSearchQuery = '';
  final Map<String, int> _pendingEdits = {};

  // Persisted area selection for Loading dialog
  String? _lastOutAreaId;

  // Persisted supplier filter + scroll position for the "Add Product"
  // picker in the Loading dialog.
  final _outAddProductPickerState = SearchPickerState();

  // Van Stock tab — separate date-filtered Out / In lists
  DateTime _outDate   = DateTime.now();
  DateTime _inDate    = DateTime.now();
  // Persisted transaction date (carries over between dialog opens)
  DateTime _outTxDate = DateTime.now();
  DateTime _inTxDate  = DateTime.now();
  List<VanStock> _outItems = [];
  List<VanStock> _inItems  = [];
  bool _outLoading = false;
  bool _inLoading  = false;

  // Loading Report tab
  String?   _reportAreaId;
  DateTime  _reportReturnDate = DateTime.now();
  DateTime? _reportLoadingDate;
  List<_ReportRow> _reportRows = [];
  bool _reportLoading = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(_onTabChange);
    _load();
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChange);
    _tabs.dispose();
    _outSearchCtrl.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (_tabs.indexIsChanging) return;
    if (_tabs.index == 0) _loadOutItems();
    if (_tabs.index == 1) _loadInItems();
    if (_tabs.index == 2) _loadReport();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _products = await ref.read(productRepositoryProvider).getAll();
    _areas    = await ref.read(vanAreaRepositoryProvider).getAll();

    // Build productId → supplierName map
    final suppliers = await ref.read(supplierRepositoryProvider).getAll();
    final suppMap   = {for (final s in suppliers) s.id: s.name};
    final prodSupp  = <String, String>{};
    for (final p in _products) {
      prodSupp[p.id] = suppMap[p.supplierId] ?? 'Unknown';
    }
    _supplierNames = prodSupp;

    final invItems = await ref.read(inventoryRepositoryProvider).getAll();
    _inventoryQty  = {for (final i in invItems) i.productId: i.quantityPieces};

    // Load selling prices for grand total calculation
    for (final p in _products) {
      final price = await ref
          .read(productRepositoryProvider)
          .getCurrentPrice(p.id);
      if (price != null) _sellingPrices[p.id] = price.sellingPrice;
    }

    setState(() => _loading = false);

    _loadOutItems();
    _loadInItems();
    if (_tabs.index == 2) _loadReport();
  }

  Future<void> _loadOutItems() async {
    setState(() { _outLoading = true; _pendingEdits.clear(); });
    final all = await ref.read(vanStockRepositoryProvider).getAll(date: _outDate);
    _outItems = all.where((t) => t.type == 'out').toList();
    setState(() => _outLoading = false);
  }

  Future<void> _savePendingEdits() async {
    final repo = ref.read(vanStockRepositoryProvider);
    for (final entry in List.of(_pendingEdits.entries)) {
      final tx = _outItems.where((t) => t.id == entry.key).firstOrNull;
      if (tx == null || entry.value == tx.quantityPieces) continue;
      await repo.updateRecord(tx, entry.value);
    }
    _pendingEdits.clear();
    ref.invalidate(inventoryListProvider);
    await _loadOutItems();
  }

  Future<void> _loadInItems() async {
    setState(() => _inLoading = true);
    final all = await ref.read(vanStockRepositoryProvider).getAll(date: _inDate);
    _inItems = all.where((t) => t.type == 'in').toList();
    setState(() => _inLoading = false);
  }

  void _setOutDate(DateTime d) { setState(() => _outDate = d); _loadOutItems(); }
  void _setInDate(DateTime d)  { setState(() => _inDate  = d); _loadInItems(); }

  Future<void> _loadReport() async {
    if (_reportAreaId == null) {
      setState(() { _reportRows = []; _reportLoadingDate = null; });
      return;
    }
    setState(() => _reportLoading = true);

    // 1. Latest loaded products before return date for this area
    final (loadedQty, loadingDate) = await ref
        .read(vanStockRepositoryProvider)
        .getLatestLoadedProducts(
          areaId: _reportAreaId!,
          beforeDate: _reportReturnDate,
        );
    _reportLoadingDate = loadingDate;

    // 2. Returned items for this area on the return date
    final allTxs = await ref
        .read(vanStockRepositoryProvider)
        .getAll(date: _reportReturnDate);
    final returnedQty = <String, int>{};
    for (final tx in allTxs) {
      if (tx.type == 'in' && tx.areaId == _reportAreaId) {
        returnedQty[tx.productId] =
            (returnedQty[tx.productId] ?? 0) + tx.quantityPieces;
      }
    }

    // 3. Build report rows for every loaded product
    final productsById = {for (final p in _products) p.id: p};
    final rows = loadedQty.entries.map((e) {
      final p = productsById[e.key];
      return _ReportRow(
        productName:    p?.name ?? e.key,
        piecesPerBox:   p?.piecesPerBox ?? 1,
        loadedPieces:   e.value,
        returnedPieces: returnedQty[e.key] ?? 0,
        sellingPrice:   _sellingPrices[e.key] ?? 0,
      );
    }).toList()
      ..sort((a, b) => a.productName.compareTo(b.productName));

    setState(() {
      _reportRows    = rows;
      _reportLoading = false;
    });
  }

  void _setReportReturnDate(DateTime d) {
    setState(() { _reportReturnDate = d; _reportRows = []; });
    _loadReport();
  }

  // ── Transaction dialog ─────────────────────────────────────────────────

  Future<void> _manageAreas() async {
    final nameCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Manage Areas'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'New area name',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        final area = await ref
                            .read(vanAreaRepositoryProvider)
                            .add(name);
                        nameCtrl.clear();
                        setD(() => _areas = [..._areas, area]);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._areas.map((a) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(a.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                        onPressed: () async {
                          await ref
                              .read(vanAreaRepositoryProvider)
                              .delete(a.id);
                          setD(() => _areas =
                              _areas.where((x) => x.id != a.id).toList());
                        },
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
  }

  Future<void> _showTransactionDialog({
    required bool isOut,
    VanStockDraft? draft,
  }) async {
    if (!mounted) return;

    String? selectedAreaId = draft?.areaId ?? (isOut ? _lastOutAreaId : null);
    DateTime txDate = draft?.txDate ?? (isOut ? _outTxDate : _inTxDate);
    final lineItems = <_VanLineItem>[];
    if (draft != null) {
      final productsById = {for (final p in _products) p.id: p};
      for (final it in draft.items) {
        final product = productsById[it.productId];
        if (product == null) continue;
        lineItems.add(_VanLineItem(product)
          ..unitType = it.unitType
          ..quantity = it.quantity);
      }
    }
    var loadedQty   = <String, int>{};
    var loadedLabel = '';

    final draftId = draft?.id ?? const Uuid().v4();
    final draftCreatedAt = draft?.createdAt ?? DateTime.now();
    var draftPersisted = draft != null;
    var finalized = false;
    Timer? autoSaveTimer;

    Future<void> persistDraft() async {
      if (!isOut || !mounted) return;
      await ref.read(vanStockRepositoryProvider).saveDraft(VanStockDraft(
            id: draftId,
            type: 'out',
            areaId: selectedAreaId,
            txDate: txDate,
            items: lineItems
                .map((li) => VanStockDraftItem(
                      productId: li.product.id,
                      unitType: li.unitType,
                      quantity: li.quantity,
                    ))
                .toList(),
            createdAt: draftCreatedAt,
          ));
      draftPersisted = true;
      ref.invalidate(vanStockDraftsProvider('out'));
    }

    void scheduleAutoSave() {
      if (!isOut) return;
      autoSaveTimer?.cancel();
      autoSaveTimer = Timer(const Duration(seconds: 2), persistDraft);
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          int availFor(_VanLineItem li) => isOut
              ? (_inventoryQty[li.product.id] ?? 0)
              : (loadedQty[li.product.id] ?? 0);

          bool canSave() {
            if (isOut && _areas.isNotEmpty && selectedAreaId == null) return false;
            if (lineItems.isEmpty) return false;
            return lineItems
                .every((li) => li.quantity > 0 && li.pieces <= availFor(li));
          }

          Future<void> pickProducts() async {
            List<Product> visibleProducts;
            if (isOut) {
              visibleProducts = _products;
            } else if (selectedAreaId == null) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Select an area first.')));
              }
              return;
            } else {
              final (qtys, latestDay) = await ref
                  .read(vanStockRepositoryProvider)
                  .getLatestLoadedProducts(
                    areaId: selectedAreaId!,
                    beforeDate: txDate,
                  );
              loadedQty   = qtys;
              loadedLabel = latestDay != null
                  ? 'Loaded ${DateFormat('MMM dd, yyyy').format(latestDay)}'
                  : '';
              visibleProducts =
                  _products.where((p) => qtys.containsKey(p.id)).toList();
            }
            if (!ctx.mounted) return;

            // Build one chip per unique supplier present in visibleProducts
            final supplierChips = <String, String>{};
            for (final p in visibleProducts) {
              final name = _supplierNames[p.id];
              if (name != null) supplierChips[p.supplierId] = name;
            }
            final supplierFilters = (supplierChips.entries.toList()
                  ..sort((a, b) => a.value.compareTo(b.value)))
                .map((e) => SearchFilter<Product>(
                      label: e.value,
                      test: (p) => p.supplierId == e.key,
                    ))
                .toList();

            await showSearchPicker<Product>(
              context: ctx,
              title: isOut ? 'Select Products' : 'Select Products to Return',
              items: visibleProducts,
              labelOf: (p) => p.name,
              searchableOf: (p) => '${p.name} ${p.productCode ?? ''}',
              state: isOut ? _outAddProductPickerState : null,
              subtitleOf: (p) {
                if (!isOut) {
                  final ppb = p.piecesPerBox;
                  final ld  = loadedQty[p.id] ?? 0;
                  return '${loadedLabel.isNotEmpty ? "$loadedLabel  •  " : ""}'
                      '${ld ~/ ppb} box(es) + ${ld % ppb} pcs';
                }
                final qty = _inventoryQty[p.id] ?? 0;
                final ppb = p.piecesPerBox;
                return 'Stock: ${qty ~/ ppb} box(es) + ${qty % ppb} pcs';
              },
              subtitleStyleOf: (p) => isOut
                  ? TextStyle(
                      color: (_inventoryQty[p.id] ?? 0) > 0
                          ? Colors.green.shade700
                          : Colors.red)
                  : TextStyle(color: Colors.blue.shade700),
              isDisabledOf:
                  isOut ? (p) => (_inventoryQty[p.id] ?? 0) <= 0 : null,
              onSelected: (p) {
                if (lineItems.any((li) => li.product.id == p.id)) return;
                setD(() => lineItems.add(_VanLineItem(p)));
                scheduleAutoSave();
              },
              filters: supplierFilters,
            );
          }

          return AlertDialog(
            title: Text(isOut ? 'Loading' : 'Stocks Return'),
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            insetPadding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 24),
            content: SizedBox(
              width: 700,
              height: MediaQuery.of(ctx).size.height * 0.65,
              child: Column(
                children: [
                  // Date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: txDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        if (isOut) {
                          _outTxDate = picked;
                        } else {
                          _inTxDate = picked;
                          lineItems.clear();
                          loadedQty = {};
                        }
                        setD(() => txDate = picked);
                        scheduleAutoSave();
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today, size: 18),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text(DateFormat('MMM dd, yyyy').format(txDate)),
                    ),
                  ),

                  // Area
                  if (_areas.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Area:', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String?>(
                            value: selectedAreaId,
                            isExpanded: true,
                            isDense: true,
                            items: [
                              const DropdownMenuItem(
                                  value: null, child: Text('— None —')),
                              ..._areas.map((a) => DropdownMenuItem(
                                  value: a.id, child: Text(a.name))),
                            ],
                            onChanged: (v) {
                              if (isOut) _lastOutAreaId = v;
                              if (!isOut) {
                                lineItems.clear();
                                loadedQty = {};
                              }
                              setD(() => selectedAreaId = v);
                              scheduleAutoSave();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Add Product button + item count
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product'),
                          onPressed: pickProducts,
                        ),
                        const Spacer(),
                        if (lineItems.isNotEmpty)
                          Text('${lineItems.length} item(s)',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Line items
                  Expanded(
                    child: lineItems.isEmpty
                        ? const Center(
                            child: Text('Tap "Add Product" to add items',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: lineItems.length,
                            itemBuilder: (_, i) {
                              final li = lineItems[i];
                              final avail = availFor(li);
                              return _VanLineItemCard(
                                key: ValueKey(li.product.id),
                                item: li,
                                availPieces: avail,
                                isOut: isOut,
                                stockOk: li.quantity == 0 ||
                                    li.pieces <= avail,
                                onRemove: () {
                                  setD(() => lineItems.removeAt(i));
                                  scheduleAutoSave();
                                },
                                onChanged: () {
                                  setD(() {});
                                  scheduleAutoSave();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: canSave()
                    ? () async {
                        for (final li in lineItems) {
                          await ref.read(vanStockRepositoryProvider).record(
                                productId: li.product.id,
                                type: isOut ? 'out' : 'in',
                                quantityPieces: li.pieces,
                                notes: null,
                                date: txDate,
                                areaId: selectedAreaId,
                              );
                        }
                        finalized = true;
                        if (ctx.mounted) Navigator.pop(ctx);
                        ref.invalidate(inventoryListProvider);
                        _load();
                      }
                    : null,
                child: const Text('Save All'),
              ),
            ],
          );
        },
      ),
    );

    autoSaveTimer?.cancel();
    if (isOut) {
      if (finalized || lineItems.isEmpty) {
        if (draftPersisted) {
          await ref.read(vanStockRepositoryProvider).discardDraft(draftId);
        }
        ref.invalidate(vanStockDraftsProvider('out'));
      } else {
        await persistDraft();
      }
    }
  }

  // ── Print Loading / Stocks Return ─────────────────────────────────────

  Future<void> _printTab({required bool isOut}) async {
    final items    = isOut ? _outItems : _inItems;
    final date     = isOut ? _outDate  : _inDate;
    final filter   = isOut ? _outAreaFilter : _inAreaFilter;
    final filtered = filter == null
        ? items
        : items.where((t) => t.areaId == filter).toList();
    if (filtered.isEmpty) return;

    final productsById = {for (final p in _products) p.id: p};
    final areasById    = {for (final a in _areas) a.id: a.name};

    final rows = filtered.map((tx) {
      final p = productsById[tx.productId];
      return VanTransactionPrintRow(
        productName:   p?.name ?? tx.productId,
        areaId:        tx.areaId ?? '__none__',
        areaName:      areasById[tx.areaId] ?? 'No Area',
        quantityPieces: tx.quantityPieces,
        piecesPerBox:  p?.piecesPerBox ?? 1,
        sellingPrice:  _sellingPrices[tx.productId] ?? 0,
      );
    }).toList();

    await printVanTransactions(
      date:  date,
      title: isOut ? 'Loading' : 'Stocks Return',
      rows:  rows,
    );
  }

  // ── Export Loading tab to CSV ──────────────────────────────────────────

  Future<void> _exportOutItems() async {
    final productsById = {for (final p in _products) p.id: p};
    final areasById    = {for (final a in _areas) a.id: a.name};
    final rows = (_outAreaFilter == null
            ? _outItems
            : _outItems.where((t) => t.areaId == _outAreaFilter).toList())
        .where((t) {
      if (_outSearchQuery.isEmpty) return true;
      final name = (productsById[t.productId]?.name ?? '').toLowerCase();
      return name.contains(_outSearchQuery);
    }).toList();

    if (rows.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to export.')));
      }
      return;
    }

    final buf = StringBuffer();
    buf.writeln('Date,Product Code,Product Name,Supplier,Area,Boxes,Pieces,Total Pieces');
    final dateFmt = DateFormat('yyyy-MM-dd');
    for (final tx in rows) {
      final p   = productsById[tx.productId];
      final ppb = p?.piecesPerBox ?? 1;
      String csv(String? v) {
        final s = (v ?? '').replaceAll('"', '""');
        return s.contains(',') || s.contains('"') || s.contains('\n')
            ? '"$s"'
            : s;
      }
      buf.writeln([
        dateFmt.format(tx.date),
        csv(p?.productCode),
        csv(p?.name ?? tx.productId),
        csv(_supplierNames[tx.productId]),
        csv(areasById[tx.areaId]),
        '${tx.quantityPieces ~/ ppb}',
        '${tx.quantityPieces % ppb}',
        '${tx.quantityPieces}',
      ].join(','));
    }

    final home = (await getApplicationDocumentsDirectory()).parent.path;
    final dateStr = DateFormat('yyyy-MM-dd').format(_outDate);
    final file = File('$home\\Desktop\\off_site_loading_$dateStr.csv');
    await file.writeAsString(buf.toString());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported to ${file.path}'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ── Print Loading Report ───────────────────────────────────────────────

  Future<void> _printReport() async {
    if (_reportRows.isEmpty || _reportLoadingDate == null || _reportAreaId == null) return;
    final areaName = _areas.where((a) => a.id == _reportAreaId).map((a) => a.name).firstOrNull ?? '';
    await printLoadingReport(
      areaName:    areaName,
      loadingDate: _reportLoadingDate!,
      returnDate:  _reportReturnDate,
      rows: _reportRows.map((r) => LoadingReportRow(
        productName:    r.productName,
        piecesPerBox:   r.piecesPerBox,
        loadedPieces:   r.loadedPieces,
        returnedPieces: r.returnedPieces,
      )).toList(),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Off-site Loading',
      actions: [
        IconButton(
          icon: const Icon(Icons.location_on_outlined),
          tooltip: 'Manage Areas',
          onPressed: _manageAreas,
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
                  controller: _tabs,
                  tabs: const [
                    Tab(text: 'Loading'),
                    Tab(text: 'Stocks Return'),
                    Tab(text: 'Loading Report'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _buildOutPage(),
                      _buildInPage(),
                      _buildReportTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── Out page ───────────────────────────────────────────────────────────

  Widget _buildOutPage() => _buildTransactionPage(
        isOut: true,
        icon: Icons.arrow_upward,
        color: Colors.red,
        date: _outDate,
        items: _outItems,
        loading: _outLoading,
        areaFilter: _outAreaFilter,
        onAreaFilterChanged: (v) => setState(() => _outAreaFilter = v),
        onPrev:  () => _setOutDate(_outDate.subtract(const Duration(days: 1))),
        onNext:  () => _setOutDate(_outDate.add(const Duration(days: 1))),
        onToday: () => _setOutDate(DateTime.now()),
        onPickDate: () async {
          final p = await showDatePicker(
            context: context, initialDate: _outDate,
            firstDate: DateTime(2020), lastDate: DateTime(2100),
          );
          if (p != null) _setOutDate(p);
        },
        onExport: _exportOutItems,
      );

  // ── In page ────────────────────────────────────────────────────────────

  Widget _buildInPage() => _buildTransactionPage(
        isOut: false,
        icon: Icons.arrow_downward,
        color: Colors.green,
        date: _inDate,
        items: _inItems,
        loading: _inLoading,
        areaFilter: _inAreaFilter,
        onAreaFilterChanged: (v) => setState(() => _inAreaFilter = v),
        onPrev:  () => _setInDate(_inDate.subtract(const Duration(days: 1))),
        onNext:  () => _setInDate(_inDate.add(const Duration(days: 1))),
        onToday: () => _setInDate(DateTime.now()),
        onPickDate: () async {
          final p = await showDatePicker(
            context: context, initialDate: _inDate,
            firstDate: DateTime(2020), lastDate: DateTime(2100),
          );
          if (p != null) _setInDate(p);
        },
      );

  Widget _buildTransactionPage({
    required bool isOut,
    required IconData icon,
    required Color color,
    required DateTime date,
    required List<VanStock> items,
    required bool loading,
    required String? areaFilter,
    required void Function(String?) onAreaFilterChanged,
    required VoidCallback onPrev,
    required VoidCallback onNext,
    required VoidCallback onToday,
    required VoidCallback onPickDate,
    VoidCallback? onExport,
  }) {
    final dateFmt      = DateFormat('MMM dd, yyyy');
    final productsById = {for (final p in _products) p.id: p};
    final areaFiltered = areaFilter == null
        ? items
        : items.where((t) => t.areaId == areaFilter).toList();
    final filtered = (isOut && _outSearchQuery.isNotEmpty)
        ? areaFiltered.where((t) {
            final p = productsById[t.productId];
            return (p?.name ?? t.productId)
                .toLowerCase()
                .contains(_outSearchQuery);
          }).toList()
        : areaFiltered;
    final totalAmount  = filtered.fold(0.0,
        (s, t) => s + t.quantityPieces * (_sellingPrices[t.productId] ?? 0));

    return Column(
      children: [
        // ── Draft loadings banner ────────────────────────────────────────
        if (isOut)
          ref.watch(vanStockDraftsProvider('out')).when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (drafts) {
                  if (drafts.isEmpty) return const SizedBox.shrink();
                  return Container(
                    width: double.infinity,
                    color: Colors.amber.shade100,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${drafts.length} unfinished loading(s)',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        ...drafts.map((d) {
                          final area = _areas
                              .where((a) => a.id == d.areaId)
                              .firstOrNull;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.edit_note, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${area?.name ?? 'No area'}'
                                    '  •  ${dateFmt.format(d.txDate)}'
                                    '  •  ${d.items.length} item(s)',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _showTransactionDialog(
                                          isOut: true, draft: d),
                                  child: const Text('Resume'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red, size: 20),
                                  tooltip: 'Discard draft',
                                  onPressed: () async {
                                    final ok = await showConfirmDialog(
                                      context,
                                      title: 'Discard Draft',
                                      message:
                                          'Discard this unfinished loading? This cannot be undone.',
                                      confirmLabel: 'Discard',
                                    );
                                    if (ok) {
                                      await ref
                                          .read(vanStockRepositoryProvider)
                                          .discardDraft(d.id);
                                      ref.invalidate(
                                          vanStockDraftsProvider('out'));
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),

        // Action button + date navigation
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
          child: Row(
            children: [
              FilledButton.icon(
                icon: Icon(icon, size: 16),
                label: Text(isOut ? 'Loading' : 'Stocks Return'),
                style: FilledButton.styleFrom(backgroundColor: color),
                onPressed: () => _showTransactionDialog(isOut: isOut),
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.chevron_left),
                  visualDensity: VisualDensity.compact, onPressed: onPrev),
              GestureDetector(
                onTap: onPickDate,
                child: Text(dateFmt.format(date),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              IconButton(icon: const Icon(Icons.chevron_right),
                  visualDensity: VisualDensity.compact, onPressed: onNext),
              TextButton(
                onPressed: onToday,
                style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact),
                child: const Text('Today'),
              ),
              if (onExport != null)
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Export to CSV',
                  onPressed: _outItems.isEmpty ? null : onExport,
                ),
              IconButton(
                icon: const Icon(Icons.print),
                tooltip: 'Print',
                onPressed: (isOut ? _outItems : _inItems).isEmpty
                    ? null
                    : () => _printTab(isOut: isOut),
              ),
            ],
          ),
        ),

        // Area filter chips
        if (_areas.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _areaChip('All', null, areaFilter, onAreaFilterChanged),
                ..._areas.map((a) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _areaChip(
                          a.name, a.id, areaFilter, onAreaFilterChanged),
                    )),
              ],
            ),
          ),
        if (isOut)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
            child: TextField(
              controller: _outSearchCtrl,
              decoration: InputDecoration(
                hintText: 'Search products...',
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _outSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _outSearchCtrl.clear();
                          setState(() => _outSearchQuery = '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  setState(() => _outSearchQuery = v.toLowerCase()),
            ),
          ),
        const Divider(height: 1),

        // List
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? Center(
                      child: Text(
                          'No ${isOut ? 'out' : 'in'} transactions.',
                          style: const TextStyle(color: Colors.grey)))
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final tx  = filtered[i];
                        final p   = productsById[tx.productId];
                        final ppb = p?.piecesPerBox ?? 1;
                        final sub = [
                          _supplierNames[tx.productId],
                          _areas.where((a) => a.id == tx.areaId)
                              .map((a) => a.name).firstOrNull,
                        ].whereType<String>().join('  •  ');
                        if (isOut) {
                          return _EditableVanStockTile(
                            key: ValueKey(tx.id),
                            tx: tx,
                            productName: p?.name ?? tx.productId,
                            subtitle: sub,
                            piecesPerBox: ppb,
                            currentQtyPieces:
                                _pendingEdits[tx.id] ?? tx.quantityPieces,
                            onChanged: (newPcs) =>
                                setState(() => _pendingEdits[tx.id] = newPcs),
                            onDelete: () async {
                              await ref
                                  .read(vanStockRepositoryProvider)
                                  .delete(tx);
                              ref.invalidate(inventoryListProvider);
                              _loadOutItems();
                            },
                          );
                        }
                        return ListTile(
                          leading: Icon(icon, color: color, size: 22),
                          title: Text(p?.name ?? tx.productId),
                          subtitle: Text(sub),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${tx.quantityPieces ~/ ppb} box(es)'
                                ' + ${tx.quantityPieces % ppb} pcs',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 20),
                                onPressed: () async {
                                  await ref
                                      .read(vanStockRepositoryProvider)
                                      .delete(tx);
                                  ref.invalidate(inventoryListProvider);
                                  _loadInItems();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),

        // Save pending edits footer
        if (isOut && _pendingEdits.isNotEmpty)
          Container(
            color: Colors.blue.shade50,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('${_pendingEdits.length} item(s) edited',
                    style: TextStyle(color: Colors.blue.shade700)),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Save Changes'),
                  onPressed: _savePendingEdits,
                ),
              ],
            ),
          ),

        // Grand total footer
        if (!loading && filtered.isNotEmpty)
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Grand Total: ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(formatCurrency(totalAmount),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _areaChip(String label, String? value, String? current,
          void Function(String?) onChange) =>
      ChoiceChip(
        label: Text(label),
        selected: current == value,
        onSelected: (_) => onChange(value),
        visualDensity: VisualDensity.compact,
      );

  // ── Loading Report tab ─────────────────────────────────────────────────

  Widget _buildReportTab() {
    final dateFmt = DateFormat('MMM dd, yyyy');

    return Column(
      children: [
        // Controls: Area + Return Date + Print
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Area selector
              Row(
                children: [
                  const Text('Area:',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String?>(
                      value: _reportAreaId,
                      isDense: true,
                      isExpanded: true,
                      hint: const Text('Select area'),
                      items: _areas.map((a) => DropdownMenuItem(
                          value: a.id, child: Text(a.name))).toList(),
                      onChanged: (v) {
                        setState(() { _reportAreaId = v; _reportRows = []; });
                        _loadReport();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Return date picker
              Row(
                children: [
                  const Text('Return Date:',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _reportReturnDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) _setReportReturnDate(picked);
                    },
                    child: Text(dateFmt.format(_reportReturnDate),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.print),
                    tooltip: 'Print report',
                    onPressed: _reportRows.isEmpty ? null : _printReport,
                  ),
                ],
              ),
              // Loading date (left-aligned)
              if (_reportLoadingDate != null)
                Row(
                  children: [
                    const Text('Loading Date:',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Text(dateFmt.format(_reportLoadingDate!),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Table
        Expanded(
          child: _reportLoading
              ? const Center(child: CircularProgressIndicator())
              : _reportAreaId == null
                  ? const Center(child: Text('Select an area to view the report.'))
                  : _reportRows.isEmpty
                      ? const Center(child: Text('No loading data found.'))
                      : Column(
                          children: [
                            // Header row
                            Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: const Row(
                                children: [
                                  Expanded(flex: 4,
                                      child: Text('ITEM',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12))),
                                  Expanded(flex: 3,
                                      child: Text('Loading',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12))),
                                  Expanded(flex: 3,
                                      child: Text('Return',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12))),
                                  Expanded(flex: 3,
                                      child: Text('Sold',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12))),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            // Data rows
                            Expanded(
                              child: ListView.separated(
                                itemCount: _reportRows.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (ctx, i) {
                                  final r = _reportRows[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 4,
                                            child: Text(r.productName,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500))),
                                        Expanded(flex: 3,
                                            child: Text(r.loadedFmt,
                                                textAlign: TextAlign.center)),
                                        Expanded(flex: 3,
                                            child: Text(r.returnedFmt,
                                                textAlign: TextAlign.center)),
                                        Expanded(flex: 3,
                                            child: Text(r.soldFmt,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Grand total for Sold
                            const Divider(height: 1, thickness: 2),
                            Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  const Expanded(flex: 4,
                                      child: Text('Grand Total',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Expanded(flex: 3, child: const SizedBox()),
                                  Expanded(flex: 3, child: const SizedBox()),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      formatCurrency(_reportRows.fold(
                                          0.0,
                                          (s, r) => s +
                                              r.soldPieces * r.sellingPrice)),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
        ),
      ],
    );
  }
}

// ── Editable van-stock tile (Loading tab list) ────────────────────────────────

class _EditableVanStockTile extends StatefulWidget {
  final VanStock tx;
  final String productName;
  final String subtitle;
  final int piecesPerBox;
  final int currentQtyPieces;
  final void Function(int newQtyPieces) onChanged;
  final VoidCallback onDelete;

  const _EditableVanStockTile({
    super.key,
    required this.tx,
    required this.productName,
    required this.subtitle,
    required this.piecesPerBox,
    required this.currentQtyPieces,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_EditableVanStockTile> createState() => _EditableVanStockTileState();
}

class _EditableVanStockTileState extends State<_EditableVanStockTile> {
  late final TextEditingController _boxCtrl;
  late final TextEditingController _pcCtrl;

  @override
  void initState() {
    super.initState();
    final ppb = widget.piecesPerBox;
    _boxCtrl =
        TextEditingController(text: '${widget.currentQtyPieces ~/ ppb}');
    _pcCtrl =
        TextEditingController(text: '${widget.currentQtyPieces % ppb}');
  }

  @override
  void dispose() {
    _boxCtrl.dispose();
    _pcCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    final boxes = int.tryParse(_boxCtrl.text) ?? 0;
    final pcs   = int.tryParse(_pcCtrl.text) ?? 0;
    widget.onChanged(boxes * widget.piecesPerBox + pcs);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.arrow_upward, color: Colors.red, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.productName,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                if (widget.subtitle.isNotEmpty)
                  Text(widget.subtitle,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            child: TextField(
              controller: _boxCtrl,
              decoration:
                  const InputDecoration(labelText: 'Boxes', isDense: true),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _notify(),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 52,
            child: TextField(
              controller: _pcCtrl,
              decoration:
                  const InputDecoration(labelText: 'Pcs', isDense: true),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _notify(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.red, size: 20),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}

// ── Van line-item card (used inside Loading / Stocks Return dialog) ────────────

class _VanLineItemCard extends StatefulWidget {
  final _VanLineItem item;
  final int availPieces;
  final bool isOut;
  final bool stockOk;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _VanLineItemCard({
    super.key,
    required this.item,
    required this.availPieces,
    required this.isOut,
    required this.stockOk,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_VanLineItemCard> createState() => _VanLineItemCardState();
}

class _VanLineItemCardState extends State<_VanLineItemCard> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.item.quantity > 0 ? '${widget.item.quantity}' : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _availLabel() {
    final ppb   = widget.item.product.piecesPerBox;
    final avail = widget.availPieces;
    if (widget.isOut) {
      if (avail <= 0) return 'No stock';
      final b = avail ~/ ppb;
      final p = avail % ppb;
      if (b > 0 && p > 0) return 'Available: $b box(es) + $p pcs';
      if (b > 0) return 'Available: $b box(es)';
      return 'Available: $avail pcs';
    } else {
      final b = avail ~/ ppb;
      final p = avail % ppb;
      if (b > 0 && p > 0) return 'Loaded: $b box(es) + $p pcs';
      if (b > 0) return 'Loaded: $b box(es)';
      return 'Loaded: $avail pcs';
    }
  }

  @override
  Widget build(BuildContext context) {
    final item  = widget.item;
    final avail = widget.availPieces;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: widget.stockOk ? null : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    _availLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isOut
                          ? (avail > 0
                              ? Colors.green.shade700
                              : Colors.red)
                          : Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'piece', label: Text('Pcs')),
                ButtonSegment(value: 'box',   label: Text('Box')),
              ],
              selected: {item.unitType},
              onSelectionChanged: (s) {
                setState(() => item.unitType = s.first);
                widget.onChanged();
              },
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _ctrl,
                enabled: avail > 0,
                decoration:
                    const InputDecoration(labelText: 'Qty', isDense: true),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  item.quantity = int.tryParse(v) ?? 0;
                  widget.onChanged();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: widget.onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
