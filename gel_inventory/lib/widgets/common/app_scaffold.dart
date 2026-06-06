import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/connectivity_service.dart';

class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineAsync = ref.watch(isOnlineProvider);
    final isOnline = onlineAsync.valueOrNull ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: isOnline ? Colors.green : Colors.orange,
            ),
          ),
          ...?actions,
        ],
      ),
      drawer: _AppDrawer(),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer),
            child: const Text("GEL's Inventory",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          _tile(context, Icons.dashboard, 'Dashboard', '/'),
          _tile(context, Icons.local_shipping, 'Suppliers', '/suppliers'),
          _tile(context, Icons.store, 'Clients', '/clients'),
          _tile(context, Icons.inventory_2, 'Products', '/products'),
          _tile(context, Icons.warehouse, 'Inventory', '/inventory'),
          _tile(context, Icons.receipt_long, 'Invoices', '/invoices'),
          _tile(context, Icons.summarize, 'Layout', '/layout'),
          _tile(context, Icons.account_balance_wallet, 'Remittance', '/collectibles'),
          _tile(context, Icons.remove_shopping_cart, 'Returns/Bad Orders', '/bad-orders'),
          _tile(context, Icons.bar_chart, 'Reports', '/reports'),
          _tile(context, Icons.local_shipping, 'Off-site Loading', '/van-selling'),
          _tile(context, Icons.star_rate, 'Incentives', '/incentives'),
          
        ],
      ),
    );
  }

  ListTile _tile(
          BuildContext ctx, IconData icon, String label, String route) =>
      ListTile(
        leading: Icon(icon),
        title: Text(label),
        onTap: () {
          Navigator.pop(ctx);
          ctx.go(route);
        },
      );
}
