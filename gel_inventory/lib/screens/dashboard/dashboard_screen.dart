import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/app_settings_service.dart';
import '../../widgets/common/app_scaffold.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showOffSiteLoading =
        ref.watch(showOffSiteLoadingProvider).valueOrNull ?? true;
    final showImportCsv =
        ref.watch(showImportCsvProvider).valueOrNull ?? true;

    return AppScaffold(
      title: "GEL's Inventory",
      body: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 1.4,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          _NavCard(
            icon: Icons.local_shipping,
            label: 'Suppliers',
            route: '/suppliers',
          ),
          _NavCard(
            icon: Icons.store,
            label: 'Clients',
            route: '/clients',
          ),
          _NavCard(
            icon: Icons.inventory_2,
            label: 'Products',
            route: '/products',
          ),
          _NavCard(
            icon: Icons.warehouse,
            label: 'Inventory',
            route: '/inventory',
          ),
          _NavCard(
            icon: Icons.move_to_inbox,
            label: 'Supplier Deliveries',
            route: '/supplier-deliveries',
          ),
          _NavCard(
            icon: Icons.shopping_cart,
            label: 'Purchase Orders',
            route: '/purchase-orders',
          ),
          _NavCard(
            icon: Icons.receipt_long,
            label: 'Invoices',
            route: '/invoices',
          ),
          _NavCard(
            icon: Icons.summarize,
            label: 'Layout',
            route: '/layout',
          ),
          _NavCard(
            icon: Icons.account_balance_wallet,
            label: 'Remittance',
            route: '/collectibles',
          ),
          _NavCard(
            icon: Icons.remove_shopping_cart,
            label: 'Returns/Bad Orders',
            route: '/bad-orders',
          ),
          _NavCard(
            icon: Icons.bar_chart,
            label: 'Reports',
            route: '/reports',
          ),
          _NavCard(
            icon: Icons.groups,
            label: 'Client Purchases',
            route: '/client-purchases',
          ),
          if (showOffSiteLoading)
            _NavCard(
              icon: Icons.local_shipping,
              label: 'Off-site Loading',
              route: '/van-selling',
            ),
          _NavCard(
            icon: Icons.star_rate,
            label: 'Incentives',
            route: '/incentives',
          ),
          if (showImportCsv)
            _NavCard(
              icon: Icons.upload_file,
              label: 'Import CSV',
              route: '/import-csv',
            ),
          _NavCard(
            icon: Icons.settings,
            label: 'Settings',
            route: '/settings',
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _NavCard({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
