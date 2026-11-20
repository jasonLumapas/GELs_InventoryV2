import 'dart:io';

import 'package:excel/excel.dart' as xlsx;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/services/incentives_settings_service.dart';
import '../../core/services/instance_config_service.dart';
import '../../repositories/bad_order_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class _SupplierCol {
  final String id;
  final String name;
  const _SupplierCol({required this.id, required this.name});
}

class _DayData {
  final int day;
  double grandTotal = 0;
  // RAM (fixed column — always present, has Sales + BO)
  double ramSales = 0;
  double ramBoAmount = 0;
  // Additional configured suppliers (Sales only)
  final Map<String, double> additionalSales = {};
  _DayData(this.day);
}

class _MonthData {
  final List<_DayData> days;
  final String ramName; // displayed name for the RAM column header
  final List<_SupplierCol> additional; // extra configured supplier columns

  _MonthData({
    required this.days,
    required this.ramName,
    required this.additional,
  });

  double get totalGrand => days.fold(0.0, (s, d) => s + d.grandTotal);
  double get totalRamSales => days.fold(0.0, (s, d) => s + d.ramSales);
  double get totalRamBoAmount => days.fold(0.0, (s, d) => s + d.ramBoAmount);
  double totalAdditionalSales(String sid) =>
      days.fold(0.0, (s, d) => s + (d.additionalSales[sid] ?? 0.0));
}

// ── Screen ────────────────────────────────────────────────────────────────────

class IncentivesScreen extends ConsumerStatefulWidget {
  const IncentivesScreen({super.key});

  @override
  ConsumerState<IncentivesScreen> createState() => _IncentivesScreenState();
}

class _IncentivesScreenState extends ConsumerState<IncentivesScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<String> _configuredIds = []; // additional supplier IDs (not RAM)
  late Future<_MonthData> _future;
  late TabController _tabs;

  final TextEditingController _targetCtrl = TextEditingController(text: '0');
  final TextEditingController _percentCtrl = TextEditingController(text: '90');
  _MonthData? _lastData;

  @override
  void dispose() {
    _targetCtrl.dispose();
    _percentCtrl.dispose();
    _tabs.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
    _future = _loadSettingsThenMonth();
  }

  Future<_MonthData> _loadSettingsThenMonth() async {
    _configuredIds = await IncentivesSettingsService.loadSupplierIds();
    return _loadMonth(_selectedMonth);
  }

  void _setMonth(DateTime m) => setState(() {
    _selectedMonth = DateTime(m.year, m.month);
    _future = _loadMonth(_selectedMonth);
  });

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedMonth.year, _selectedMonth.month, 15),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) _setMonth(DateTime(picked.year, picked.month));
  }

  Future<void> _openSettings() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _SettingsDialog(
        configuredIds: List.from(_configuredIds),
        onSave: (newIds) async {
          await IncentivesSettingsService.saveSupplierIds(newIds);
          setState(() {
            _configuredIds = newIds;
            _future = _loadMonth(_selectedMonth);
          });
        },
      ),
    );
  }

  Future<_MonthData> _loadMonth(DateTime month) async {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final suppliers = await ref.read(supplierRepositoryProvider).getAll();
    final products = await ref.read(productRepositoryProvider).getAll();

    // ── Find RAM supplier ─────────────────────────────────────────────────────
    String? ramId;
    String ramName = 'RAM';
    for (final s in suppliers) {
      if (s.name.trim().toLowerCase() == 'ram') {
        ramId = s.id;
        ramName = s.name;
        break;
      }
    }

    // ── Build additional supplier columns (preserving order) ─────────────────
    final suppById = {for (final s in suppliers) s.id: s.name};
    final additional = _configuredIds
        .where((id) => suppById.containsKey(id) && id != ramId)
        .map((id) => _SupplierCol(id: id, name: suppById[id]!))
        .toList();

    // ── Product → supplier lookup ─────────────────────────────────────────────
    final productSupplier = <String, String>{
      for (final p in products) p.id: p.supplierId,
    };
    final piecesPerBoxById = <String, int>{
      for (final p in products) p.id: p.piecesPerBox,
    };

    final additionalSet = {for (final c in additional) c.id};

    final days = List.generate(daysInMonth, (i) => _DayData(i + 1));

    // ── Invoices ──────────────────────────────────────────────────────────────
    // Every total below is priced at each product's current GELs selling
    // price (Selling Price/pc (GELs)), not whatever price (GELs or OP) was
    // actually charged on the invoice — so incentive targets stay stable
    // regardless of the "Use OP Selling Price on Invoices" setting.
    final gelsPrices =
        await ref.read(productRepositoryProvider).getAllCurrentPrices();
    final invoices = await ref
        .read(invoiceRepositoryProvider)
        .getAll(startDate: monthStart, endDate: monthEnd);

    for (final inv in invoices) {
      final d = inv.invoiceDate.day - 1;
      if (d < 0 || d >= daysInMonth) continue;

      final items =
          await ref.read(invoiceRepositoryProvider).getItems(inv.id);
      for (final item in items) {
        if (item.isFree) continue;
        final gelsAmount = item.quantity * (gelsPrices[item.productId] ?? 0.0);
        days[d].grandTotal += gelsAmount;

        final sid = productSupplier[item.productId];
        if (sid == null) continue;
        if (sid == ramId) {
          days[d].ramSales += gelsAmount;
        } else if (additionalSet.contains(sid)) {
          days[d].additionalSales[sid] =
              (days[d].additionalSales[sid] ?? 0.0) + gelsAmount;
        }
      }
    }

    // ── Bad orders — RAM only ─────────────────────────────────────────────────
    if (ramId != null) {
      final allBo = await ref.read(badOrderRepositoryProvider).getAll();
      for (final bo in allBo) {
        if (bo.type != 'bad_order') continue;
        if (bo.date.isBefore(monthStart) || !bo.date.isBefore(monthEnd)) {
          continue;
        }
        final d = bo.date.day - 1;
        if (d < 0 || d >= daysInMonth) continue;
        final items = await ref
            .read(badOrderRepositoryProvider)
            .getItems(bo.id);
        for (final item in items) {
          if (productSupplier[item.productId] == ramId) {
            final ppb = piecesPerBoxById[item.productId] ?? 1;
            final pieces = item.unitType == 'box'
                ? item.quantity * ppb
                : item.quantity;
            final price = await ref
                .read(productRepositoryProvider)
                .getCurrentPrice(item.productId);
            final unitPrice = price?.sellingPrice ?? 0.0;
            days[d].ramBoAmount += pieces * unitPrice;
          }
        }
      }
    }

    return _MonthData(days: days, ramName: ramName, additional: additional);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Incentives',
      actions: [
        if (_tabs.index == 0) ...[
          if (_lastData != null) ...[
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'Download as Excel',
              onPressed: () => _downloadIncentives(_lastData!),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configure additional supplier columns',
            onPressed: _openSettings,
          ),
        ],
      ],
      body: Column(
        children: [
          TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Summary'),
              Tab(text: 'Per-Supplier'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildOverviewTab(),
                const _PerSupplierIncentivesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                visualDensity: VisualDensity.compact,
                onPressed: () => _setMonth(
                  DateTime(_selectedMonth.year, _selectedMonth.month - 1),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _pickMonth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        monthLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                visualDensity: VisualDensity.compact,
                onPressed: () => _setMonth(
                  DateTime(_selectedMonth.year, _selectedMonth.month + 1),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: FutureBuilder<_MonthData>(
            future: _future,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              }
              return _buildTable(snap.data!);
            },
          ),
        ),
      ],
    );
  }

  // ── Colors ────────────────────────────────────────────────────────────────
  // RAM is always purple. Additional suppliers cycle through the rest.
  static const _ramDark = Colors.purple;
  static const _ramMid = Colors.purple;
  static const _ramLight = Colors.purple;

  static Color _addDark(int i) {
    const palette = [
      Colors.teal,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.pink,
    ];
    return palette[i % palette.length].shade200;
  }

  static Color _addMid(int i) {
    const palette = [
      Colors.teal,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.pink,
    ];
    return palette[i % palette.length].shade100;
  }

  static Color _addLight(int i) {
    const palette = [
      Colors.teal,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.pink,
    ];
    return palette[i % palette.length].shade50;
  }

  // Column layout:
  //   0 Date(3)  1 GrandTotal(4)  2 RamSales(4)  3 RamBO(3)
  //   4+i  AdditionalSales(4) for i in 0..n-1
  Map<int, TableColumnWidth> _buildColWidths(int n) {
    return {
      0: const FlexColumnWidth(3),
      1: const FlexColumnWidth(4),
      2: const FlexColumnWidth(4),
      3: const FlexColumnWidth(3),
      for (int i = 0; i < n; i++) 4 + i: const FlexColumnWidth(4),
    };
  }

  Widget _buildTable(_MonthData data) {
    final wasNull = _lastData == null;
    _lastData = data;
    if (wasNull) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
    final dateFmt = DateFormat('MMM d');
    final n = data.additional.length;
    final colWidths = _buildColWidths(n);

    final dataBorder = TableBorder(
      left: BorderSide(color: Colors.grey.shade400),
      right: BorderSide(color: Colors.grey.shade400),
      bottom: BorderSide(color: Colors.grey.shade400),
      horizontalInside: BorderSide(color: Colors.grey.shade400),
      verticalInside: BorderSide(color: Colors.grey.shade400),
    );
    final headerBorder = TableBorder(
      left: BorderSide(color: Colors.grey.shade400),
      right: BorderSide(color: Colors.grey.shade400),
      bottom: BorderSide(color: Colors.grey.shade400),
      verticalInside: BorderSide(color: Colors.grey.shade400),
    );
    final totalBorder = TableBorder(
      top: BorderSide(color: Colors.grey.shade600, width: 1.5),
      left: BorderSide(color: Colors.grey.shade400),
      right: BorderSide(color: Colors.grey.shade400),
      bottom: BorderSide(color: Colors.grey.shade400),
      verticalInside: BorderSide(color: Colors.grey.shade400),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Sticky headers ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Group header row
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: const Text(''),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          'Grand Total',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // RAM — fixed, flex 7 (Sales 4 + BO 3)
                    Expanded(
                      flex: 7,
                      child: Container(
                        color: _ramDark.shade200,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          data.ramName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Additional suppliers — each flex 4 (Sales only)
                    for (int i = 0; i < n; i++)
                      Expanded(
                        flex: 4,
                        child: Container(
                          color: _addDark(i),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            data.additional[i].name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Column labels row
              Table(
                border: headerBorder,
                columnWidths: colWidths,
                children: [
                  TableRow(
                    children: [
                      _cell(
                        'Date',
                        Colors.grey.shade200,
                        bold: true,
                        center: true,
                      ),
                      _cell(
                        'Amount',
                        Colors.grey.shade200,
                        bold: true,
                        center: true,
                      ),
                      _cell(
                        'Sales',
                        _ramMid.shade100,
                        bold: true,
                        center: true,
                      ),
                      _cell('BO', _ramMid.shade100, bold: true, center: true),
                      for (int i = 0; i < n; i++)
                        _cell('Sales', _addMid(i), bold: true, center: true),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // ── Scrollable data rows + totals ───────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Data rows
                Table(
                  border: dataBorder,
                  columnWidths: colWidths,
                  children: data.days.map((d) {
                    final date = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month,
                      d.day,
                    );
                    final hasData =
                        d.grandTotal > 0 ||
                        d.ramSales > 0 ||
                        d.ramBoAmount > 0 ||
                        d.additionalSales.values.any((v) => v > 0);
                    return TableRow(
                      children: [
                        _cell(dateFmt.format(date), null),
                        _cell(
                          hasData ? formatCurrency(d.grandTotal) : '—',
                          null,
                          center: true,
                        ),
                        _cell(
                          d.ramSales > 0 ? formatCurrency(d.ramSales) : '—',
                          _ramLight.shade50,
                          center: true,
                        ),
                        _cell(
                          d.ramBoAmount > 0
                              ? formatCurrency(d.ramBoAmount)
                              : '—',
                          _ramLight.shade50,
                          center: true,
                        ),
                        for (int i = 0; i < n; i++)
                          _cell(
                            (d.additionalSales[data.additional[i].id] ?? 0) > 0
                                ? formatCurrency(
                                    d.additionalSales[data.additional[i].id]!,
                                  )
                                : '—',
                            _addLight(i),
                            center: true,
                          ),
                      ],
                    );
                  }).toList(),
                ),
                // Totals row
                Table(
                  border: totalBorder,
                  columnWidths: colWidths,
                  children: [
                    TableRow(
                      children: [
                        _cell('Total', Colors.grey.shade200, bold: true),
                        _cell(
                          formatCurrency(data.totalGrand),
                          Colors.grey.shade200,
                          bold: true,
                          center: true,
                        ),
                        _cell(
                          formatCurrency(data.totalRamSales),
                          _ramMid.shade100,
                          bold: true,
                          center: true,
                        ),
                        _cell(
                          data.totalRamBoAmount > 0
                              ? formatCurrency(data.totalRamBoAmount)
                              : '—',
                          _ramMid.shade100,
                          bold: true,
                          center: true,
                        ),
                        for (int i = 0; i < n; i++)
                          _cell(
                            formatCurrency(
                              data.totalAdditionalSales(data.additional[i].id),
                            ),
                            _addMid(i),
                            bold: true,
                            center: true,
                          ),
                      ],
                    ),
                  ],
                ),
                // ── Monthly Target ───────────────────────────────────────────
                const SizedBox(height: 16),
                _editableRow('Monthly Target', _targetCtrl),
                const SizedBox(height: 8),
                _editableRow(
                  'Percent of the target for incentive eligibility',
                  _percentCtrl,
                  suffix: '%',
                ),
                const SizedBox(height: 4),
                ListenableBuilder(
                  listenable: Listenable.merge([_targetCtrl, _percentCtrl]),
                  builder: (_, _) {
                    final target = double.tryParse(_targetCtrl.text) ?? 0.0;
                    final percent = double.tryParse(_percentCtrl.text) ?? 90.0;
                    return _summaryRow(
                      'Target Amount',
                      formatCurrency(target * percent / 100),
                      bold: true,
                    );
                  },
                ),
                // ── BO Allowance ────────────────────────────────────────────
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              'BO Allowance (1% of the monthly RAM sales)',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 2),
                            child: Text(
                              'Total RAM BO for the month',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: const Text(
                              'Net BO Allowance',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              formatCurrency(data.totalRamSales * 0.01),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              formatCurrency(data.totalRamBoAmount),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Text(
                              formatCurrency(
                                data.totalRamSales * 0.01 -
                                    data.totalRamBoAmount,
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ── Net Sales computation ────────────────────────────────────
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Builder(
                    builder: (_) {
                      final netBo =
                          data.totalRamSales * 0.01 - data.totalRamBoAmount;
                      final netSales =
                          data.totalGrand -
                          data.additional.fold(
                            0.0,
                            (s, c) => s + data.totalAdditionalSales(c.id),
                          );
                      final eligible = netBo < 0 ? netSales + netBo : netSales;
                      const ts = TextStyle(fontSize: 13);
                      const tsBold = TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      );
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Labels
                          IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Total Gross Sales', style: tsBold),
                                const SizedBox(height: 4),
                                const Text('less:', style: ts),
                                for (final c in data.additional) ...[
                                  const SizedBox(height: 2),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(c.name, style: ts),
                                  ),
                                ],
                                Container(
                                  padding: const EdgeInsets.only(top: 4),
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: const Text('Total', style: ts),
                                ),
                                if (netBo < 0) ...[
                                  const SizedBox(height: 2),
                                  const Text('Net BO Allowance', style: ts),
                                ],
                                Container(
                                  padding: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: const Text('Net Sales', style: tsBold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Values
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatCurrency(data.totalGrand),
                                style: tsBold,
                              ),
                              const SizedBox(height: 4),
                              const Text('', style: ts),
                              for (final c in data.additional) ...[
                                const SizedBox(height: 2),
                                Text(
                                  formatCurrency(
                                    data.totalAdditionalSales(c.id),
                                  ),
                                  style: ts,
                                ),
                              ],
                              Container(
                                padding: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  formatCurrency(
                                    data.additional.fold(
                                      0.0,
                                      (s, c) =>
                                          s + data.totalAdditionalSales(c.id),
                                    ),
                                  ),
                                  style: ts,
                                ),
                              ),
                              if (netBo < 0) ...[
                                const SizedBox(height: 2),
                                Text(formatCurrency(netBo), style: ts),
                              ],
                              Container(
                                padding: const EdgeInsets.only(top: 6),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  formatCurrency(eligible),
                                  style: tsBold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // ── Eligibility status ───────────────────────────────────────
                const SizedBox(height: 16),
                ListenableBuilder(
                  listenable: Listenable.merge([_targetCtrl, _percentCtrl]),
                  builder: (ctx, _) {
                    final target = double.tryParse(_targetCtrl.text) ?? 0.0;
                    final percent = double.tryParse(_percentCtrl.text) ?? 90.0;
                    final targetAmount = target * percent / 100;
                    final netBo =
                        data.totalRamSales * 0.01 - data.totalRamBoAmount;
                    final netSales =
                        data.totalGrand -
                        data.additional.fold(
                          0.0,
                          (s, c) => s + data.totalAdditionalSales(c.id),
                        );
                    final eligibleAmt = netBo < 0 ? netSales + netBo : netSales;
                    final isEligible = eligibleAmt >= targetAmount;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isEligible
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isEligible
                              ? Colors.green.shade300
                              : Colors.red.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEligible ? Icons.check_circle : Icons.cancel,
                            color: isEligible
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEligible
                                ? 'Eligible for Incentive'
                                : 'Not Eligible for Incentive',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isEligible
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell(
    String text,
    Color? bg, {
    bool bold = false,
    bool center = false,
  }) => Container(
    color: bg,
    padding: const EdgeInsets.all(8),
    child: Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
    ),
  );

  // ── PDF / Print ─────────────────────────────────────────────────────────────

  Future<void> _printIncentives(_MonthData data) async {
    final doc = await _buildIncentivesDoc(data);
    final bytes = await doc.save();
    await Printing.layoutPdf(onLayout: (_) => bytes, format: PdfPageFormat.a4);
  }

  Future<void> _downloadIncentives(_MonthData data) async {
    final bytes = _buildIncentivesExcel(data);
    final home =
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '.';
    final monthTag = DateFormat('yyyyMM').format(_selectedMonth);
    final file = File('$home\\Desktop\\incentives_report_$monthTag.xlsx');
    await file.writeAsBytes(bytes);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
  }

  List<int> _buildIncentivesExcel(_MonthData data) {
    final target = double.tryParse(_targetCtrl.text) ?? 0.0;
    final percent = double.tryParse(_percentCtrl.text) ?? 90.0;
    final targetAmt = target * percent / 100;
    final netBo = data.totalRamSales * 0.01 - data.totalRamBoAmount;
    final netSales =
        data.totalGrand -
        data.additional.fold(
          0.0,
          (s, c) => s + data.totalAdditionalSales(c.id),
        );
    final eligible = netBo < 0 ? netSales + netBo : netSales;
    final isEligible = eligible >= targetAmt;
    final dateFmt = DateFormat('MMM d');

    final numFmt = NumberFormat('#,##0.00');
    String numPlain(double v) {
      if (v == 0) return '';
      return v < 0 ? '-${numFmt.format(-v)}' : numFmt.format(v);
    }

    String numBare(double v) =>
        v < 0 ? '-${numFmt.format(-v)}' : numFmt.format(v);

    final book = xlsx.Excel.createExcel();
    final sheet = book[book.sheets.keys.first];

    final thinBorder = xlsx.Border(
      borderStyle: xlsx.BorderStyle.Thin,
      borderColorHex: '#000000',
    );

    int r = 0;
    void addRow(
      List<String> cells, {
      bool bold = false,
      Set<int> rightAlign = const {},
      bool border = false,
    }) {
      for (int c = 0; c < cells.length; c++) {
        final cell = sheet.cell(
          xlsx.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
        );
        cell.value = cells[c];
        // Column 0 is always the date/label column; every other column
        // holds a currency (or percentage) value, so right-align it to
        // keep decimals lined up.
        final alignRight = c >= 1 || rightAlign.contains(c);
        if (bold || alignRight || border) {
          cell.cellStyle = xlsx.CellStyle(
            bold: bold,
            horizontalAlign: alignRight
                ? xlsx.HorizontalAlign.Right
                : xlsx.HorizontalAlign.Left,
            leftBorder: border ? thinBorder : null,
            rightBorder: border ? thinBorder : null,
            topBorder: border ? thinBorder : null,
            bottomBorder: border ? thinBorder : null,
          );
        }
      }
      r++;
    }

    void addBlankRow() => r++;

    addRow([
      'Date',
      'Grand Total',
      '${data.ramName} Sales',
      '${data.ramName} BO',
      for (final c in data.additional) '${c.name} Sales',
    ], border: true);
    for (final d in data.days) {
      addRow([
        dateFmt.format(
          DateTime(_selectedMonth.year, _selectedMonth.month, d.day),
        ),
        numPlain(d.grandTotal),
        numPlain(d.ramSales),
        numPlain(d.ramBoAmount),
        for (final c in data.additional)
          numPlain(d.additionalSales[c.id] ?? 0.0),
      ], border: true);
    }
    addRow([
      'Total',
      numBare(data.totalGrand),
      numBare(data.totalRamSales),
      numBare(data.totalRamBoAmount),
      for (final c in data.additional) numBare(data.totalAdditionalSales(c.id)),
    ], border: true);

    addBlankRow();
    addRow(['Monthly Target', '', '', numBare(target)]);
    addRow(['% for incentive eligibility', '${percent.toStringAsFixed(0)}%']);
    addRow(['Target Amount', '', '', numBare(targetAmt)]);
    addBlankRow();
    addRow([
      'BO Allowance (1% of RAM sales)',
      numBare(data.totalRamSales * 0.01),
    ]);
    addRow(['Total RAM BO for the month', numBare(data.totalRamBoAmount)]);
    addRow(['Net BO Allowance', numBare(netBo)]);
    addBlankRow();
    addRow(['Total Gross Sales', '', numBare(data.totalGrand)]);
    addRow(['less:']);
    for (final c in data.additional) {
      addRow([c.name, numBare(data.totalAdditionalSales(c.id))]);
    }
    addRow(
      [
        'Total',
        '',
        numBare(
          data.additional.fold(
            0.0,
            (s, c) => s + data.totalAdditionalSales(c.id),
          ),
        ),
      ],
      rightAlign: {0},
    );
    addBlankRow();
    if (netBo < 0) {
      addRow(['Net BO Allowance', numBare(netBo)]);
    }
    addRow(['Net Sales', '', numBare(eligible)], bold: true);
    addBlankRow();
    addRow([
      isEligible ? 'ELIGIBLE FOR INCENTIVE' : 'NOT ELIGIBLE FOR INCENTIVE',
    ]);

    return book.encode()!;
  }

  Future<pw.Document> _buildIncentivesDoc(_MonthData data) async {
    final headerTitle = await ref.read(headerTitleProvider.future) ?? '';
    final target = double.tryParse(_targetCtrl.text) ?? 0.0;
    final percent = double.tryParse(_percentCtrl.text) ?? 90.0;
    final targetAmt = target * percent / 100;
    final netBo = data.totalRamSales * 0.01 - data.totalRamBoAmount;
    final netSales =
        data.totalGrand -
        data.additional.fold(
          0.0,
          (s, c) => s + data.totalAdditionalSales(c.id),
        );
    final eligible = netBo < 0 ? netSales + netBo : netSales;
    final isEligible = eligible >= targetAmt;
    final numFmt = NumberFormat('#,##0.00');

    pw.Font loadF(String path, pw.Font fallback) {
      try {
        return pw.Font.ttf(File(path).readAsBytesSync().buffer.asByteData());
      } catch (_) {
        return fallback;
      }
    }

    final font = loadF('C:\\Windows\\Fonts\\arial.ttf', pw.Font.helvetica());
    final fontBold = loadF(
      'C:\\Windows\\Fonts\\arialbd.ttf',
      pw.Font.helveticaBold(),
    );

    String fc(double v) => numFmt.format(v);
    String fcPhp(double v) => 'Php ${numFmt.format(v)}';
    String fsignPhp(double v) =>
        v < 0 ? '-Php ${numFmt.format(-v)}' : 'Php ${numFmt.format(v)}';

    const double fs = 8.5;
    pw.TextStyle ts({bool bold = false}) =>
        pw.TextStyle(font: bold ? fontBold : font, fontSize: fs);

    // ── Page format & column widths ──────────────────────────────────────────
    final fmt = PdfPageFormat.a4;
    final marg = const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 28);
    final usableW = fmt.width - marg.left - marg.right;

    final n = data.additional.length;
    const double dateW = 52, amtW = 72, ramSalesW = 72, ramBoW = 62;
    final fixedW = dateW + amtW + ramSalesW + ramBoW;
    final addW = n > 0 ? (usableW - fixedW) / n : 0.0;

    Map<int, pw.TableColumnWidth> colWidths = {
      0: const pw.FixedColumnWidth(dateW),
      1: const pw.FixedColumnWidth(amtW),
      2: const pw.FixedColumnWidth(ramSalesW),
      3: const pw.FixedColumnWidth(ramBoW),
      for (int i = 0; i < n; i++) 4 + i: pw.FixedColumnWidth(addW),
    };

    // ── Cell helpers ─────────────────────────────────────────────────────────
    const hPad = pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3);

    pw.Widget hCell(String t, {PdfColor? bg}) => pw.Container(
      color: bg ?? PdfColors.grey300,
      padding: hPad,
      child: pw.Text(t, style: ts(bold: true), textAlign: pw.TextAlign.center),
    );

    pw.Widget dCell(String t, {bool bold = false, PdfColor? bg}) =>
        pw.Container(
          color: bg,
          padding: hPad,
          child: pw.Text(
            t,
            style: ts(bold: bold),
            textAlign: pw.TextAlign.right,
          ),
        );

    pw.Widget lCell(String t, {bool bold = false, PdfColor? bg}) =>
        pw.Container(
          color: bg,
          padding: hPad,
          child: pw.Text(t, style: ts(bold: bold)),
        );

    // ── Summary row helper — fixed-width columns so values align ────────────
    const double labelW = 205, valW = 90;

    pw.Widget sumRow(
      String label,
      String value, {
      bool bold = false,
      double indent = 0,
      bool labelRight = false,
    }) => pw.Row(
      children: [
        pw.SizedBox(
          width: labelW - indent,
          child: pw.Padding(
            padding: pw.EdgeInsets.only(left: indent),
            child: pw.Text(
              label,
              style: ts(bold: bold),
              textAlign: labelRight ? pw.TextAlign.right : pw.TextAlign.left,
            ),
          ),
        ),
        pw.SizedBox(
          width: valW,
          child: pw.Text(
            value,
            style: ts(bold: bold),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );

    // ── Build document ───────────────────────────────────────────────────────
    final doc = pw.Document();
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedMonth);
    final todayLabel = DateFormat('MMMM d, yyyy').format(DateTime.now());
    final rowDateFmt = DateFormat('MM/dd');

    doc.addPage(
      pw.MultiPage(
        pageFormat: fmt,
        margin: marg,
        build: (ctx) => [
          // Title
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "GEL'S CONSUMER GOODS TRADING",
                    style: pw.TextStyle(font: fontBold, fontSize: 13),
                  ),
                  if (headerTitle.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text('Area: $headerTitle', style: ts()),
                  ],
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Incentives Report — $monthLabel',
                    style: pw.TextStyle(font: fontBold, fontSize: 10),
                  ),
                ],
              ),
              pw.Text('Date: $todayLabel', style: ts()),
            ],
          ),
          pw.SizedBox(height: 10),

          // Daily table
          pw.Table(
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey500),
            columnWidths: colWidths,
            children: [
              // Header
              pw.TableRow(
                children: [
                  hCell('Date'),
                  hCell('Amount'),
                  hCell('RAM Sales'),
                  hCell('RAM BO'),
                  for (final c in data.additional) hCell(c.name),
                ],
              ),
              // Data rows
              for (final d in data.days)
                pw.TableRow(
                  children: [
                    lCell(
                      rowDateFmt.format(
                        DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month,
                          d.day,
                        ),
                      ),
                    ),
                    dCell(d.grandTotal > 0 ? fc(d.grandTotal) : '—'),
                    dCell(d.ramSales > 0 ? fc(d.ramSales) : '—'),
                    dCell(d.ramBoAmount > 0 ? fc(d.ramBoAmount) : '—'),
                    for (final c in data.additional)
                      dCell(
                        (d.additionalSales[c.id] ?? 0) > 0
                            ? fc(d.additionalSales[c.id]!)
                            : '—',
                      ),
                  ],
                ),
              // Totals
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  lCell('Total', bold: true),
                  dCell(fc(data.totalGrand), bold: true),
                  dCell(fc(data.totalRamSales), bold: true),
                  dCell(
                    data.totalRamBoAmount > 0 ? fc(data.totalRamBoAmount) : '—',
                    bold: true,
                  ),
                  for (final c in data.additional)
                    dCell(fc(data.totalAdditionalSales(c.id)), bold: true),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 14),
          pw.Divider(thickness: 0.5),
          pw.SizedBox(height: 8),

          // Summary
          sumRow('Monthly Target', fcPhp(target)),
          pw.SizedBox(height: 3),
          sumRow(
            '% for incentive eligibility',
            '${percent.toStringAsFixed(0)}%',
          ),
          pw.SizedBox(height: 3),
          sumRow('Target Amount', fcPhp(targetAmt), bold: true),

          pw.SizedBox(height: 10),
          sumRow(
            'BO Allowance (1% of RAM sales)',
            fcPhp(data.totalRamSales * 0.01),
          ),
          pw.SizedBox(height: 3),
          sumRow('Total RAM BO for the month', fcPhp(data.totalRamBoAmount)),
          pw.SizedBox(height: 3),
          sumRow('Net BO Allowance', fsignPhp(netBo), bold: true),

          pw.SizedBox(height: 10),
          sumRow('Total Gross Sales', fcPhp(data.totalGrand), bold: true),
          pw.SizedBox(height: 3),
          pw.Text('less:', style: ts()),
          for (final c in data.additional) ...[
            pw.SizedBox(height: 2),
            sumRow(c.name, fcPhp(data.totalAdditionalSales(c.id)), indent: 12),
          ],
          pw.SizedBox(height: 3),
          sumRow(
            'Total',
            fcPhp(
              data.additional.fold(
                0.0,
                (s, c) => s + data.totalAdditionalSales(c.id),
              ),
            ),
            labelRight: true,
          ),
          if (netBo < 0) ...[
            pw.SizedBox(height: 3),
            sumRow('Net BO Allowance', fsignPhp(netBo)),
          ],
          pw.SizedBox(height: 3),
          sumRow('Net Sales', fcPhp(eligible), bold: true),

          pw.SizedBox(height: 12),
          pw.Text(
            isEligible
                ? 'ELIGIBLE FOR INCENTIVE'
                : 'NOT ELIGIBLE FOR INCENTIVE',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 11,
              color: isEligible ? PdfColors.green800 : PdfColors.red800,
            ),
          ),
        ],
      ),
    );

    return doc;
  }

  Widget _editableRow(
    String label,
    TextEditingController ctrl, {
    String? suffix,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        const Text(': ', style: TextStyle(fontSize: 13)),
        SizedBox(
          width: 110,
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 6,
              ),
              border: const OutlineInputBorder(),
              suffixText: suffix,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    ),
  );

  Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
    double indent = 0,
    bool expand = false,
  }) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: EdgeInsets.only(left: 4 + indent, right: 4),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (expand)
            Expanded(child: Text(label, style: style))
          else
            Text(label, style: style),
          if (!expand) Text(': ', style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

// ── Settings dialog ───────────────────────────────────────────────────────────
// Manages only the additional supplier columns. RAM is always present.

class _SettingsDialog extends ConsumerStatefulWidget {
  final List<String> configuredIds;
  final Future<void> Function(List<String>) onSave;

  const _SettingsDialog({required this.configuredIds, required this.onSave});

  @override
  ConsumerState<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<_SettingsDialog> {
  late List<String> _ids;
  String? _selectedToAdd;

  @override
  void initState() {
    super.initState();
    _ids = List.from(widget.configuredIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Additional Supplier Columns'),
      content: SizedBox(
        width: 340,
        child: ref
            .watch(suppliersListProvider)
            .maybeWhen(
              data: (suppliers) {
                // Drop configured IDs that no longer match any supplier
                // (e.g. left over after the local database was reset).
                final knownIds = {for (final s in suppliers) s.id};
                final stale = _ids
                    .where((id) => !knownIds.contains(id))
                    .toList();
                if (stale.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(
                        () => _ids.removeWhere((id) => !knownIds.contains(id)),
                      );
                    }
                  });
                }

                // Exclude RAM (always shown) and already-configured suppliers
                final nonRam = suppliers
                    .where((s) => s.name.trim().toLowerCase() != 'ram')
                    .toList();
                final suppById = {for (final s in nonRam) s.id: s.name};
                final available = nonRam
                    .where((s) => !_ids.contains(s.id))
                    .toList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'The RAM column is always shown. Configure extra supplier columns (Sales only) below.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Additional columns:',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    if (_ids.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'None configured.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ..._ids.asMap().entries.map(
                        (e) => ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          leading: CircleAvatar(
                            radius: 11,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Text(
                              '${e.key + 1}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          title: Text(suppById[e.value] ?? e.value),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 20,
                            ),
                            color: Colors.red.shade300,
                            tooltip: 'Remove',
                            onPressed: () =>
                                setState(() => _ids.removeAt(e.key)),
                          ),
                        ),
                      ),
                    const Divider(height: 20),
                    if (available.isNotEmpty) ...[
                      const Text(
                        'Add supplier:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: DropdownButton<String>(
                                value: _selectedToAdd,
                                hint: const Text('Select supplier...'),
                                isExpanded: true,
                                isDense: true,
                                underline: const SizedBox(),
                                items: available
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s.id,
                                        child: Text(s.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedToAdd = v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add'),
                            onPressed: _selectedToAdd == null
                                ? null
                                : () => setState(() {
                                    _ids.add(_selectedToAdd!);
                                    _selectedToAdd = null;
                                  }),
                          ),
                        ],
                      ),
                    ] else if (_ids.isNotEmpty)
                      Text(
                        'All non-RAM suppliers are already added.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      )
                    else
                      Text(
                        'No suppliers found besides RAM. '
                        'Add a supplier first to configure extra columns.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                );
              },
              orElse: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await widget.onSave(_ids);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ── Per-Supplier Incentives tab ─────────────────────────────────────────────
// Lets the user add any supplier and assign it an incentive percentage,
// computed against that supplier's total sales for the selected month.
// Independent of the Summary tab's month, RAM column, and BO/target logic.

class _PerSupplierIncentivesTab extends ConsumerStatefulWidget {
  const _PerSupplierIncentivesTab();

  @override
  ConsumerState<_PerSupplierIncentivesTab> createState() =>
      _PerSupplierIncentivesTabState();
}

class _PerSupplierIncentivesTabState
    extends ConsumerState<_PerSupplierIncentivesTab> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Map<String, double> _percents = {}; // supplierId -> percent, insertion order
  Map<String, double> _salesBySupplier = {};
  final Map<String, TextEditingController> _percentCtrls = {};
  bool _loading = true;
  String? _selectedToAdd;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _percentCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrlFor(String supplierId) {
    return _percentCtrls.putIfAbsent(
      supplierId,
      () =>
          TextEditingController(text: formatNumber(_percents[supplierId] ?? 0)),
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _percents = await IncentivesSettingsService.loadSupplierPercents();
    await _loadSales();
  }

  Future<void> _loadSales() async {
    final monthStart = DateTime(_selectedMonth.year, _selectedMonth.month);
    final monthEnd = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    final supplierIds = _percents.keys.toSet();

    final sales = <String, double>{for (final id in supplierIds) id: 0.0};
    if (supplierIds.isNotEmpty) {
      final products = await ref.read(productRepositoryProvider).getAll();
      final productSupplier = <String, String>{
        for (final p in products) p.id: p.supplierId,
      };
      // Priced at each product's current GELs selling price, not whatever
      // price (GELs or OP) was actually charged on the invoice.
      final gelsPrices =
          await ref.read(productRepositoryProvider).getAllCurrentPrices();
      final invoices = await ref
          .read(invoiceRepositoryProvider)
          .getAll(startDate: monthStart, endDate: monthEnd);
      for (final inv in invoices) {
        final items = await ref
            .read(invoiceRepositoryProvider)
            .getItems(inv.id);
        for (final item in items) {
          if (item.isFree) continue;
          final sid = productSupplier[item.productId];
          if (sid != null && supplierIds.contains(sid)) {
            sales[sid] = (sales[sid] ?? 0.0) +
                item.quantity * (gelsPrices[item.productId] ?? 0.0);
          }
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _salesBySupplier = sales;
      _loading = false;
    });
  }

  void _setMonth(DateTime m) {
    setState(() => _selectedMonth = DateTime(m.year, m.month));
    _loadSales();
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedMonth.year, _selectedMonth.month, 15),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) _setMonth(DateTime(picked.year, picked.month));
  }

  Future<void> _addSupplier(String id) async {
    setState(() {
      _percents = {..._percents, id: 0.0};
      _selectedToAdd = null;
    });
    await IncentivesSettingsService.saveSupplierPercents(_percents);
    await _loadSales();
  }

  Future<void> _removeSupplier(String id) async {
    setState(() {
      _percents = Map.from(_percents)..remove(id);
      _percentCtrls.remove(id)?.dispose();
      _salesBySupplier = Map.from(_salesBySupplier)..remove(id);
    });
    await IncentivesSettingsService.saveSupplierPercents(_percents);
  }

  Future<void> _updatePercent(String id, String text) async {
    final value = double.tryParse(text) ?? 0.0;
    _percents = {..._percents, id: value};
    await IncentivesSettingsService.saveSupplierPercents(_percents);
    setState(() {});
  }

  Future<pw.Document> _buildPerSupplierDoc() async {
    final suppliers = await ref.read(supplierRepositoryProvider).getAll();
    final suppById = {for (final s in suppliers) s.id: s.name};
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedMonth);
    final numFmt = NumberFormat('#,##0.00');

    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    const double fs = 9.5;
    const double fsHead = 13;

    pw.TextStyle ts({bool bold = false, double? size}) =>
        pw.TextStyle(font: bold ? fontBold : font, fontSize: size ?? fs);

    final pageFormat = PdfPageFormat.a4.copyWith(
      marginTop: 72,
      marginBottom: 40,
      marginLeft: 40,
      marginRight: 40,
    );
    final usableW = pageFormat.availableWidth;
    final nameW = usableW * 0.34;
    final salesW = usableW * 0.26;
    final pctW = usableW * 0.14;
    final incentiveW = usableW * 0.26;

    pw.Widget col(
      String text,
      double width, {
      bool bold = false,
      pw.TextAlign align = pw.TextAlign.left,
    }) => pw.SizedBox(
      width: width,
      child: pw.Text(
        text,
        style: ts(bold: bold),
        textAlign: align,
      ),
    );

    String fc(double v) => 'Php ${numFmt.format(v)}';
    String fcPlain(double v) => numFmt.format(v);

    final configuredIds = _percents.keys.toList();
    double totalIncentive = 0;

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        build: (ctx) => [
          pw.Text(
            'Per-Supplier Incentives',
            style: ts(bold: true, size: fsHead),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Month: $monthLabel', style: ts()),
          pw.SizedBox(height: 10),

          pw.Row(
            children: [
              col('Supplier', nameW, bold: true),
              col('Total Sales', salesW, bold: true, align: pw.TextAlign.right),
              col('Incentive %', pctW, bold: true, align: pw.TextAlign.right),
              col(
                'Incentive Amount',
                incentiveW,
                bold: true,
                align: pw.TextAlign.right,
              ),
            ],
          ),
          pw.Divider(height: 6, thickness: 0.5),

          for (int i = 0; i < configuredIds.length; i++) ...[
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Row(
                children: [
                  col(suppById[configuredIds[i]] ?? configuredIds[i], nameW),
                  col(
                    i == 0
                        ? fc(_salesBySupplier[configuredIds[i]] ?? 0)
                        : fcPlain(_salesBySupplier[configuredIds[i]] ?? 0),
                    salesW,
                    align: pw.TextAlign.right,
                  ),
                  col(
                    '${(_percents[configuredIds[i]] ?? 0).toStringAsFixed(1)}%',
                    pctW,
                    align: pw.TextAlign.right,
                  ),
                  col(
                    () {
                      final amt =
                          (_salesBySupplier[configuredIds[i]] ?? 0) *
                          (_percents[configuredIds[i]] ?? 0) /
                          100;
                      totalIncentive += amt;
                      return i == 0 ? fc(amt) : fcPlain(amt);
                    }(),
                    incentiveW,
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
            ),
            pw.Divider(height: 1, thickness: 0.3),
          ],

          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total Incentive: ${fc(totalIncentive)}',
              style: ts(bold: true, size: fsHead - 1),
            ),
          ),
        ],
      ),
    );
    return doc;
  }

  Future<void> _print() async {
    final doc = await _buildPerSupplierDoc();
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  Future<void> _download() async {
    final doc = await _buildPerSupplierDoc();
    final bytes = await doc.save();
    final home =
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '.';
    final tag = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('$home\\Desktop\\per_supplier_incentives_$tag.pdf');
    await file.writeAsBytes(bytes);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedMonth);
    final suppliersAsync = ref.watch(suppliersListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                visualDensity: VisualDensity.compact,
                onPressed: () => _setMonth(
                  DateTime(_selectedMonth.year, _selectedMonth.month - 1),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _pickMonth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        monthLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                visualDensity: VisualDensity.compact,
                onPressed: () => _setMonth(
                  DateTime(_selectedMonth.year, _selectedMonth.month + 1),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.print),
                tooltip: 'Print',
                visualDensity: VisualDensity.compact,
                onPressed: _percents.isNotEmpty && !_loading ? _print : null,
              ),
              IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: 'Download as PDF',
                visualDensity: VisualDensity.compact,
                onPressed: _percents.isNotEmpty && !_loading ? _download : null,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : suppliersAsync.maybeWhen(
                  data: (suppliers) {
                    final suppById = {for (final s in suppliers) s.id: s.name};
                    final configuredIds = _percents.keys.toList();
                    final available = suppliers
                        .where((s) => !_percents.containsKey(s.id))
                        .toList();
                    final totalIncentive = configuredIds.fold<double>(0.0, (
                      sum,
                      id,
                    ) {
                      final sales = _salesBySupplier[id] ?? 0.0;
                      final pct = _percents[id] ?? 0.0;
                      return sum + sales * pct / 100;
                    });

                    return ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        if (available.isNotEmpty) ...[
                          const Text(
                            'Add supplier:',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedToAdd,
                                    hint: const Text('Select supplier...'),
                                    isExpanded: true,
                                    isDense: true,
                                    underline: const SizedBox(),
                                    items: available
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s.id,
                                            child: Text(s.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedToAdd = v),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add'),
                                onPressed: _selectedToAdd == null
                                    ? null
                                    : () => _addSupplier(_selectedToAdd!),
                              ),
                            ],
                          ),
                        ] else if (configuredIds.isNotEmpty)
                          Text(
                            'All suppliers are already added.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          )
                        else
                          Text(
                            'No suppliers found. Add a supplier first.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (configuredIds.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No suppliers configured yet. Add one above.',
                              ),
                            ),
                          )
                        else
                          ...configuredIds.map((id) {
                            final sales = _salesBySupplier[id] ?? 0.0;
                            final pct = _percents[id] ?? 0.0;
                            final incentive = sales * pct / 100;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            suppById[id] ?? id,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            size: 20,
                                          ),
                                          color: Colors.red.shade300,
                                          tooltip: 'Remove',
                                          onPressed: () => _removeSupplier(id),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Total Sales: ${formatCurrency(sales)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: TextField(
                                            controller: _ctrlFor(id),
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            decoration: const InputDecoration(
                                              labelText: 'Incentive %',
                                              isDense: true,
                                              suffixText: '%',
                                            ),
                                            onChanged: (v) =>
                                                _updatePercent(id, v),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 16),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'Incentive Amount: ${formatCurrency(incentive)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        if (configuredIds.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Incentive',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  formatCurrency(totalIncentive),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                  orElse: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
        ),
      ],
    );
  }
}
