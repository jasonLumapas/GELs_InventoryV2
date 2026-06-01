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

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (ctx, s) => const DashboardScreen()),

    // Suppliers
    GoRoute(path: '/suppliers', builder: (ctx, s) => const SupplierListScreen()),
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
    GoRoute(path: '/products', builder: (ctx, s) => const ProductListScreen()),
    GoRoute(
      path: '/products/:id',
      builder: (_, state) =>
          ProductFormScreen(productId: state.pathParameters['id']),
    ),

    // Inventory
    GoRoute(path: '/inventory', builder: (ctx, s) => const InventoryScreen()),

    // Invoices
    GoRoute(path: '/invoices', builder: (ctx, s) => const InvoiceListScreen()),
    GoRoute(
        path: '/invoices/new',
        builder: (ctx, s) => const InvoiceCreateScreen()),
    GoRoute(
      path: '/invoices/:id',
      builder: (_, state) =>
          InvoiceDetailScreen(invoiceId: state.pathParameters['id']!),
    ),

    // Reports
    GoRoute(path: '/reports', builder: (ctx, s) => const ReportsScreen()),
    GoRoute(
        path: '/layout',
        builder: (ctx, s) => const OrderSummaryScreen()),
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
