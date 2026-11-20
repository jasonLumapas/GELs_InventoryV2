import 'package:flutter/gestures.dart';
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
import 'screens/invoicing/cancelled_invoices_list_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/reports/order_summary_screen.dart';
import 'screens/reports/client_purchases_screen.dart';
import 'screens/reports/client_purchase_detail_screen.dart';
import 'screens/bad_orders/bad_order_list_screen.dart';
import 'screens/bad_orders/bad_order_form_screen.dart';
import 'screens/van_selling/van_selling_screen.dart';
import 'screens/invoicing/collectibles_screen.dart';
import 'screens/admin/csv_import_screen.dart';
import 'screens/admin/printer_settings_screen.dart';
import 'screens/admin/app_settings_screen.dart';
import 'screens/incentives/incentives_screen.dart';
import 'screens/supplier_deliveries/supplier_received_invoice_list_screen.dart';
import 'screens/supplier_deliveries/supplier_received_invoice_form_screen.dart';
import 'screens/purchase_orders/purchase_order_list_screen.dart';
import 'screens/purchase_orders/purchase_order_form_screen.dart';
import 'screens/invoicing/pre_order_list_screen.dart';
import 'screens/invoicing/pre_order_form_screen.dart';
import 'screens/invoicing/pre_order_import_screen.dart';
import 'screens/van_selling/stocks_for_sale_loading_screen.dart';

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
        builder: (ctx, s) =>
            InvoiceCreateScreen(draftId: s.uri.queryParameters['draft'])),
    GoRoute(
        path: '/invoices/cancelled',
        builder: (ctx, s) => const CancelledInvoicesListScreen()),
    GoRoute(
      path: '/invoices/:id',
      builder: (_, state) =>
          InvoiceDetailScreen(invoiceId: state.pathParameters['id']!),
    ),

    // Reports + Layout
    GoRoute(path: '/reports', builder: (ctx, s) => const ReportsScreen()),
    GoRoute(path: '/layout', builder: (ctx, s) => const OrderSummaryScreen()),

    // Client Purchases (by supplier)
    GoRoute(
        path: '/client-purchases',
        builder: (ctx, s) => const ClientPurchasesScreen()),
    GoRoute(
      path: '/client-purchases/:clientId',
      builder: (_, state) => ClientPurchaseDetailScreen(
        clientId: state.pathParameters['clientId']!,
        supplierId: state.uri.queryParameters['supplierId']!,
        productId: state.uri.queryParameters['productId'],
        fromDate: DateTime.parse(state.uri.queryParameters['from']!),
        toDate: DateTime.parse(state.uri.queryParameters['to']!),
      ),
    ),

    // Bad Orders
    GoRoute(
        path: '/bad-orders',
        builder: (ctx, s) => const BadOrderListScreen()),
    GoRoute(
        path: '/bad-orders/new',
        builder: (ctx, s) =>
            BadOrderFormScreen(draftId: s.uri.queryParameters['draft'])),

    // Van Selling
    GoRoute(
        path: '/van-selling',
        builder: (ctx, s) => const VanSellingScreen()),

    // Stocks for Sale Loading
    GoRoute(
        path: '/stocks-loading',
        builder: (ctx, s) => const StocksForSaleLoadingScreen()),

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

    // App Settings
    GoRoute(
        path: '/settings',
        builder: (ctx, s) => const AppSettingsScreen()),

    // Incentives
    GoRoute(
        path: '/incentives',
        builder: (ctx, s) => const IncentivesScreen()),

    // Supplier Deliveries
    GoRoute(
        path: '/supplier-deliveries',
        builder: (ctx, s) => const SupplierReceivedInvoiceListScreen()),
    GoRoute(
        path: '/supplier-deliveries/new',
        builder: (ctx, s) => SupplierReceivedInvoiceFormScreen(
            draftId: s.uri.queryParameters['draft'])),
    GoRoute(
      path: '/supplier-deliveries/:id',
      builder: (_, state) => SupplierReceivedInvoiceFormScreen(
          invoiceId: state.pathParameters['id']),
    ),

    // Pre-Order Drafts
    GoRoute(
        path: '/pre-orders',
        builder: (ctx, s) => const PreOrderListScreen()),
    GoRoute(
        path: '/pre-order-import',
        builder: (ctx, s) => const PreOrderImportScreen()),
    GoRoute(
        path: '/pre-orders/new',
        builder: (ctx, s) => const PreOrderFormScreen()),
    GoRoute(
      path: '/pre-orders/:id',
      builder: (_, state) =>
          PreOrderFormScreen(draftId: state.pathParameters['id']),
    ),

    // Purchase Orders
    GoRoute(
        path: '/purchase-orders',
        builder: (ctx, s) => const PurchaseOrderListScreen()),
    GoRoute(
        path: '/purchase-orders/new',
        builder: (ctx, s) => PurchaseOrderFormScreen(
            draftId: s.uri.queryParameters['draft'])),
    GoRoute(
      path: '/purchase-orders/:id',
      builder: (_, state) => PurchaseOrderFormScreen(
          orderId: state.pathParameters['id']),
    ),
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
      scrollBehavior: _AppScrollBehavior(),
      routerConfig: _router,
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}
