import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/suppliers/supplier_list_screen.dart';
import 'screens/suppliers/supplier_form_screen.dart';
import 'screens/clients/client_list_screen.dart';
import 'screens/clients/client_form_screen.dart';
import 'screens/products/product_list_screen.dart';
import 'screens/products/product_form_screen.dart';
import 'screens/inventory/inventory_screen.dart';
import 'screens/invoicing/invoice_list_screen.dart';
import 'screens/invoicing/invoice_create_screen.dart';
import 'screens/invoicing/invoice_detail_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/reports/order_summary_screen.dart';
import 'screens/bad_orders/bad_order_list_screen.dart';
import 'screens/bad_orders/bad_order_form_screen.dart';
import 'screens/van_selling/van_selling_screen.dart';
import 'screens/invoicing/collectibles_screen.dart';
import 'screens/admin/csv_import_screen.dart';
import 'screens/admin/printer_settings_screen.dart';
import 'screens/incentives/incentives_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (ctx, s) => const DashboardScreen()),

    // Suppliers
    GoRoute(
        path: '/suppliers',
        builder: (ctx, s) => const SupplierListScreen()),
    GoRoute(
      path: '/suppliers/:id',
      builder: (_, state) =>
          SupplierFormScreen(supplierId: state.pathParameters['id']),
    ),

    // Clients
    GoRoute(path: '/clients', builder: (ctx, s) => const ClientListScreen()),
    GoRoute(
      path: '/clients/:id',
      builder: (_, state) =>
          ClientFormScreen(clientId: state.pathParameters['id']),
    ),

    // Products
    GoRoute(
        path: '/products', builder: (ctx, s) => const ProductListScreen()),
    GoRoute(
      path: '/products/:id',
      builder: (_, state) =>
          ProductFormScreen(productId: state.pathParameters['id']),
    ),

    // Inventory
    GoRoute(
        path: '/inventory', builder: (ctx, s) => const InventoryScreen()),

    // Invoices
    GoRoute(
        path: '/invoices', builder: (ctx, s) => const InvoiceListScreen()),
    GoRoute(
        path: '/invoices/new',
        builder: (ctx, s) => const InvoiceCreateScreen()),
    GoRoute(
      path: '/invoices/:id',
      builder: (_, state) =>
          InvoiceDetailScreen(invoiceId: state.pathParameters['id']!),
    ),

    // Reports + Layout
    GoRoute(path: '/reports', builder: (ctx, s) => const ReportsScreen()),
    GoRoute(path: '/layout', builder: (ctx, s) => const OrderSummaryScreen()),

    // Bad Orders
    GoRoute(
        path: '/bad-orders',
        builder: (ctx, s) => const BadOrderListScreen()),
    GoRoute(
        path: '/bad-orders/new',
        builder: (ctx, s) => const BadOrderFormScreen()),

    // Van Selling
    GoRoute(
        path: '/van-selling',
        builder: (ctx, s) => const VanSellingScreen()),

    // Collectibles
    GoRoute(
        path: '/collectibles',
        builder: (ctx, s) => const CollectiblesScreen()),

    // CSV Import
    GoRoute(
        path: '/import-csv',
        builder: (ctx, s) => const CsvImportScreen()),

    // Printer Settings
    GoRoute(
        path: '/printer-settings',
        builder: (ctx, s) => const PrinterSettingsScreen()),

    // Incentives
    GoRoute(
        path: '/incentives',
        builder: (ctx, s) => const IncentivesScreen()),
  ],
);

class GelInventoryApp extends StatelessWidget {
  const GelInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "GEL's Inventory",
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
