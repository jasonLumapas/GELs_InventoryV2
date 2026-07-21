import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/app_settings_service.dart';
import '../../widgets/common/app_scaffold.dart';

/// Prompts for the settings password. Returns true if the correct password
/// was entered, false if the user cancelled or entered the wrong password.
Future<bool> _promptPassword(BuildContext context) async {
  final ctrl = TextEditingController();
  String? error;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Settings Password'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            errorText: error,
          ),
          onSubmitted: (_) {
            if (ctrl.text == AppSettingsService.settingsPassword) {
              Navigator.pop(ctx, true);
            } else {
              setState(() => error = 'Incorrect password');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text == AppSettingsService.settingsPassword) {
                Navigator.pop(ctx, true);
              } else {
                setState(() => error = 'Incorrect password');
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    ),
  );
  return ok ?? false;
}

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  bool _checking = true;
  bool _unlocked = false;
  bool _showCapitalProfit = true;
  bool _showOffSiteLoading = true;
  bool _showImportCsv = true;
  bool _inventoryReportShowSelling = false;
  bool _allowBadOrderNoClient = false;
  bool _inventoryAllowAddStock    = true;
  bool _inventoryAllowRemoveStock = true;
  bool _inventoryShowHistory      = true;
  bool _allowDeleteCancelledInvoices = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    final ok = await _promptPassword(context);
    if (!mounted) return;
    if (!ok) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
      return;
    }
    _showCapitalProfit  = await AppSettingsService.getShowCapitalProfit();
    _showOffSiteLoading = await AppSettingsService.getShowOffSiteLoading();
    _showImportCsv      = await AppSettingsService.getShowImportCsv();
    _inventoryReportShowSelling =
        await AppSettingsService.getInventoryReportShowSelling();
    _allowBadOrderNoClient =
        await AppSettingsService.getAllowBadOrderNoClient();
    _inventoryAllowAddStock =
        await AppSettingsService.getInventoryAllowAddStock();
    _inventoryAllowRemoveStock =
        await AppSettingsService.getInventoryAllowRemoveStock();
    _inventoryShowHistory =
        await AppSettingsService.getInventoryShowHistory();
    _allowDeleteCancelledInvoices =
        await AppSettingsService.getAllowDeleteCancelledInvoices();
    if (!mounted) return;
    setState(() {
      _unlocked = true;
      _checking = false;
    });
  }

  Future<void> _toggleCapitalProfit(bool value) async {
    setState(() => _showCapitalProfit = value);
    await AppSettingsService.setShowCapitalProfit(value);
    ref.invalidate(showCapitalProfitProvider);
  }

  Future<void> _toggleOffSiteLoading(bool value) async {
    setState(() => _showOffSiteLoading = value);
    await AppSettingsService.setShowOffSiteLoading(value);
    ref.invalidate(showOffSiteLoadingProvider);
  }

  Future<void> _toggleImportCsv(bool value) async {
    setState(() => _showImportCsv = value);
    await AppSettingsService.setShowImportCsv(value);
    ref.invalidate(showImportCsvProvider);
  }

  Future<void> _toggleInventoryReportShowSelling(bool value) async {
    setState(() => _inventoryReportShowSelling = value);
    await AppSettingsService.setInventoryReportShowSelling(value);
    ref.invalidate(inventoryReportShowSellingProvider);
  }

  Future<void> _toggleAllowBadOrderNoClient(bool value) async {
    setState(() => _allowBadOrderNoClient = value);
    await AppSettingsService.setAllowBadOrderNoClient(value);
    ref.invalidate(allowBadOrderNoClientProvider);
  }

  Future<void> _toggleInventoryAllowAddStock(bool value) async {
    setState(() => _inventoryAllowAddStock = value);
    await AppSettingsService.setInventoryAllowAddStock(value);
    ref.invalidate(inventoryAllowAddStockProvider);
  }

  Future<void> _toggleInventoryAllowRemoveStock(bool value) async {
    setState(() => _inventoryAllowRemoveStock = value);
    await AppSettingsService.setInventoryAllowRemoveStock(value);
    ref.invalidate(inventoryAllowRemoveStockProvider);
  }

  Future<void> _toggleInventoryShowHistory(bool value) async {
    setState(() => _inventoryShowHistory = value);
    await AppSettingsService.setInventoryShowHistory(value);
    ref.invalidate(inventoryShowHistoryProvider);
  }

  Future<void> _toggleAllowDeleteCancelledInvoices(bool value) async {
    setState(() => _allowDeleteCancelledInvoices = value);
    await AppSettingsService.setAllowDeleteCancelledInvoices(value);
    ref.invalidate(allowDeleteCancelledInvoicesProvider);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      body: _checking
          ? const Center(child: CircularProgressIndicator())
          : !_unlocked
              ? const Center(child: Text('Locked'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SwitchListTile(
                      title: const Text('Show Capital & Profit'),
                      subtitle: const Text(
                          'Display capital and profit figures on the Invoices page'),
                      value: _showCapitalProfit,
                      onChanged: _toggleCapitalProfit,
                    ),
                    SwitchListTile(
                      title: const Text('Show Off-site Loading menu'),
                      subtitle: const Text(
                          'Display the Off-site Loading entry in the navigation menu and dashboard'),
                      value: _showOffSiteLoading,
                      onChanged: _toggleOffSiteLoading,
                    ),
                    SwitchListTile(
                      title: const Text('Show Import CSV menu'),
                      subtitle: const Text(
                          'Display the Import CSV entry in the navigation menu and dashboard'),
                      value: _showImportCsv,
                      onChanged: _toggleImportCsv,
                    ),
                    SwitchListTile(
                      title: const Text('Inventory Report: Show Selling Value'),
                      subtitle: const Text(
                          'Show the ending inventory grand total as selling value instead of capital value'),
                      value: _inventoryReportShowSelling,
                      onChanged: _toggleInventoryReportShowSelling,
                    ),
                    SwitchListTile(
                      title: const Text('Allow Bad Order / Return without a Client'),
                      subtitle: const Text(
                          'When enabled, Bad Orders and Returns can be saved without selecting a client (saved as "No Client Specified")'),
                      value: _allowBadOrderNoClient,
                      onChanged: _toggleAllowBadOrderNoClient,
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text('Inventory Page',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                    ),
                    SwitchListTile(
                      title: const Text('Allow Add Stock'),
                      subtitle: const Text(
                          'Show the Add Stock button on the Inventory page'),
                      value: _inventoryAllowAddStock,
                      onChanged: _toggleInventoryAllowAddStock,
                    ),
                    SwitchListTile(
                      title: const Text('Allow Remove Stock'),
                      subtitle: const Text(
                          'Show the Remove Stock button on the Inventory page'),
                      value: _inventoryAllowRemoveStock,
                      onChanged: _toggleInventoryAllowRemoveStock,
                    ),
                    SwitchListTile(
                      title: const Text('Show Transaction History'),
                      subtitle: const Text(
                          'Show the Transaction History button on the Inventory page'),
                      value: _inventoryShowHistory,
                      onChanged: _toggleInventoryShowHistory,
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text('Invoices',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                    ),
                    SwitchListTile(
                      title: const Text('Allow Permanently Deleting Cancelled Invoices'),
                      subtitle: const Text(
                          'Show the "Delete Permanently" action for cancelled invoices'),
                      value: _allowDeleteCancelledInvoices,
                      onChanged: _toggleAllowDeleteCancelledInvoices,
                    ),
                  ],
                ),
    );
  }
}
