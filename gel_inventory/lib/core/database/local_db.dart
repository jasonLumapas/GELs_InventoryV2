import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../services/instance_config_service.dart';

part 'local_db.g.dart';

// ── Existing tables ──────────────────────────────────────────────────────────

class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get contact => text().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Clients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get contact => text().nullable()();
  TextColumn get address => text().nullable()();
  BoolColumn get isBlacklisted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get productCode => text().nullable()();
  TextColumn get supplierId => text().references(Suppliers, #id)();
  IntColumn get piecesPerBox => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ProductPrices extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  RealColumn get withdrawalPrice => real()();
  RealColumn get sellingPrice => real()();
  DateTimeColumn get effectiveFrom =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-product quantity discount rule.
/// Discount is applied when quantity_pieces >= min_quantity_pieces.
class ProductDiscounts extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get minQuantityPieces => integer()();
  RealColumn get discountPercent => real()(); // value: percent (0-100) or fixed amount
  // discount_type: 'percent' | 'amount' | 'buy_x_get_y'
  TextColumn get discountType =>
      text().withDefault(const Constant('percent'))();
  // Free quantity (in pieces) granted per cycle when discount_type == 'buy_x_get_y'.
  IntColumn get freeQuantityPieces => integer().nullable()();
  // Whether the free quantity is expressed in 'piece' or 'box' units.
  TextColumn get freeQuantityUnit =>
      text().withDefault(const Constant('box'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Inventory extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantityPieces => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text().references(Clients, #id)();
  DateTimeColumn get invoiceDate =>
      dateTime().withDefault(currentDateAndTime)();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  // status: draft | printed | cancelled
  TextColumn get status => text().withDefault(const Constant('draft'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get invoiceNumber => text().nullable()();
  // Permanent sequential display number (0, 1, 2, ...), assigned once at
  // creation/backfill time. Displayed zero-padded to 8 digits.
  IntColumn get sequenceNumber => integer().nullable()();
  // invoice_type: 'delivery' | 'walk_in'
  TextColumn get invoiceType =>
      text().withDefault(const Constant('delivery'))();
  // payment_type: 'cash' | 'check' | 'credit' | 'partial'
  TextColumn get paymentType =>
      text().withDefault(const Constant('cash'))();
  RealColumn get partialAmount => real().nullable()();
  DateTimeColumn get partialDate => dateTime().nullable()();
  TextColumn get checkReference => text().nullable()();
  RealColumn get checkAmount  => real().nullable()();
  DateTimeColumn get checkDueDate => dateTime().nullable()();
  // Internal note — never included on the printed invoice.
  TextColumn get notes => text().nullable()();
  // Optional: the actual amount shown on the referenced (physical) receipt.
  RealColumn get actualAmount => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().references(Invoices, #id)();
  TextColumn get productId => text().references(Products, #id)();
  // unitType: 'box' | 'piece'
  TextColumn get unitType => text()();
  IntColumn get quantity => integer()();
  RealColumn get pricePerPiece => real()();
  RealColumn get subtotal => real()();
  BoolColumn get isFree => boolean().withDefault(const Constant(false))();
  RealColumn get discountPercent =>
      real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Bad orders (defective) and returned goods.
class BadOrders extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text().references(Clients, #id)();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  // type: 'bad_order' | 'return'
  TextColumn get type => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class BadOrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get badOrderId => text().references(BadOrders, #id)();
  TextColumn get productId => text().references(Products, #id)();
  // unitType: 'box' | 'piece'
  TextColumn get unitType => text()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Delivery areas for van selling.
class VanAreas extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Van selling stock transactions.
class VanStocks extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  // type: 'out' | 'in'
  TextColumn get type => text()();
  IntColumn get quantityPieces => integer()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
  TextColumn get areaId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Unfinished Loading / Stocks Return popups, auto-saved so they can be
/// resumed later.
class VanStockDrafts extends Table {
  TextColumn get id => text()();
  // type: 'out' (Loading) | 'in' (Stocks Return)
  TextColumn get type => text()();
  TextColumn get areaId => text().nullable()();
  DateTimeColumn get txDate => dateTime().withDefault(currentDateAndTime)();
  // JSON-encoded list of {product_id, unit_type, quantity}
  TextColumn get itemsJson => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Manual stock-in/out movements with optional references.
class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  // movementType: 'in' | 'out'
  TextColumn get movementType => text()();
  IntColumn get quantityPieces => integer()();
  DateTimeColumn get referenceDate => dateTime().nullable()();
  TextColumn get invoiceNumber => text().nullable()();
  TextColumn get comments => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Individual payment records for partial-payment invoices.
class InvoicePayments extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().references(Invoices, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get paymentDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stock received from a supplier (delivery / receiving record).
class SupplierReceivedInvoices extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId => text().references(Suppliers, #id)();
  DateTimeColumn get receivedDate =>
      dateTime().withDefault(currentDateAndTime)();
  // Supplier's own DR/invoice number.
  TextColumn get referenceNumber => text().nullable()();
  RealColumn get totalAmountSystem =>
      real().withDefault(const Constant(0.0))();
  RealColumn get totalAmountSupplier =>
      real().withDefault(const Constant(0.0))();
  // status: 'received' | 'cancelled'
  TextColumn get status => text().withDefault(const Constant('received'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SupplierReceivedInvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get receivedInvoiceId =>
      text().references(SupplierReceivedInvoices, #id)();
  TextColumn get productId => text().references(Products, #id)();
  // unitType: 'box' | 'piece'
  TextColumn get unitType => text()();
  IntColumn get quantity => integer()(); // pieces
  // Product's withdrawal price at the time of receiving.
  RealColumn get systemPrice => real()();
  // Price entered from the supplier's invoice.
  RealColumn get supplierPrice => real()();
  RealColumn get subtotalSystem => real()();
  RealColumn get subtotalSupplier => real()();
  BoolColumn get isFree => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A request for stock to be ordered from a supplier (before delivery).
class PurchaseOrders extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId => text().references(Suppliers, #id)();
  DateTimeColumn get orderDate =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get referenceNumber => text().nullable()();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  // status: 'open' | 'cancelled'
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseOrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseOrderId =>
      text().references(PurchaseOrders, #id)();
  TextColumn get productId => text().references(Products, #id)();
  // Product's withdrawal price at the time the item was added.
  RealColumn get price => real()();
  // "# of case", editable.
  RealColumn get cases => real()();
  RealColumn get amount => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get targetTable => text()();
  TextColumn get recordId => text()();
  // operation: insert | update | delete
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database class ───────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Suppliers,
  Clients,
  Products,
  ProductPrices,
  ProductDiscounts,
  Inventory,
  Invoices,
  InvoiceItems,
  BadOrders,
  BadOrderItems,
  VanAreas,
  VanStocks,
  VanStockDrafts,
  StockMovements,
  InvoicePayments,
  SupplierReceivedInvoices,
  SupplierReceivedInvoiceItems,
  PurchaseOrders,
  PurchaseOrderItems,
  SyncQueue,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 24;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await _addColumnIfMissing(
                m.database, 'invoices', 'invoice_number', 'TEXT');
          }
          if (from < 3) {
            await _addColumnIfMissing(m.database, 'products', 'is_deleted',
                'INTEGER NOT NULL DEFAULT 0');
          }
          if (from < 4) {
            await _addColumnIfMissing(m.database, 'invoices', 'invoice_type',
                "TEXT NOT NULL DEFAULT 'delivery'");
            await _addColumnIfMissing(m.database, 'invoice_items', 'is_free',
                'INTEGER NOT NULL DEFAULT 0');
            await _addColumnIfMissing(m.database, 'invoice_items',
                'discount_percent', 'REAL NOT NULL DEFAULT 0');
            await m.createTable(productDiscounts);
            await m.createTable(badOrders);
            await m.createTable(badOrderItems);
            await m.createTable(vanStocks);
          }
          if (from < 5) {
            await _addColumnIfMissing(m.database, 'product_discounts',
                'discount_type', "TEXT NOT NULL DEFAULT 'percent'");
          }
          if (from < 6) {
            await m.createTable(stockMovements);
          }
          if (from < 7) {
            await _addColumnIfMissing(m.database, 'invoices', 'payment_type',
                "TEXT NOT NULL DEFAULT 'cash'");
          }
          if (from < 8) {
            await _addColumnIfMissing(
                m.database, 'invoices', 'partial_amount', 'REAL');
            await _addColumnIfMissing(
                m.database, 'invoices', 'partial_date', 'INTEGER');
          }
          if (from < 9) {
            await _addColumnIfMissing(
                m.database, 'invoices', 'check_reference', 'TEXT');
          }
          if (from < 10) {
            await _addColumnIfMissing(
                m.database, 'invoices', 'check_amount', 'REAL');
            await _addColumnIfMissing(
                m.database, 'invoices', 'check_due_date', 'INTEGER');
          }
          if (from < 11) {
            await m.createTable(invoicePayments);
          }
          if (from < 12) {
            await m.createTable(vanAreas);
            await _addColumnIfMissing(
                m.database, 'van_stocks', 'area_id', 'TEXT');
          }
          if (from < 13) {
            await _addColumnIfMissing(
                m.database, 'products', 'product_code', 'TEXT');
          }
          if (from < 14) {
            await _addColumnIfMissing(
                m.database, 'invoices', 'notes', 'TEXT');
          }
          if (from < 15) {
            await _addColumnIfMissing(m.database, 'product_discounts',
                'free_quantity_pieces', 'INTEGER');
          }
          if (from < 16) {
            await _addColumnIfMissing(m.database, 'product_discounts',
                'free_quantity_unit', "TEXT NOT NULL DEFAULT 'box'");
          }
          if (from < 17) {
            await m.createTable(supplierReceivedInvoices);
            await m.createTable(supplierReceivedInvoiceItems);
          }
          if (from < 18) {
            await m.createTable(purchaseOrders);
            await m.createTable(purchaseOrderItems);
          }
          if (from < 19) {
            await _addColumnIfMissing(
                m.database, 'invoices', 'sequence_number', 'INTEGER');
          }
          if (from < 20) {
            await _addColumnIfMissing(
                m.database, 'invoices', 'actual_amount', 'REAL');
          }
          if (from < 21) {
            await _addColumnIfMissing(
                m.database, 'clients', 'contact', 'TEXT');
          }
          if (from < 22) {
            await _addColumnIfMissing(m.database, 'supplier_received_invoice_items',
                'is_free', 'INTEGER NOT NULL DEFAULT 0');
          }
          if (from < 23) {
            await m.createTable(vanStockDrafts);
          }
          if (from < 24) {
            await _addColumnIfMissing(
                m.database, 'clients', 'is_blacklisted',
                'INTEGER NOT NULL DEFAULT 0');
          }
        },
      );

  static Future<void> _addColumnIfMissing(
    DatabaseConnectionUser db,
    String table,
    String column,
    String definition,
  ) async {
    final rows =
        await db.customSelect('PRAGMA table_info($table)').get();
    final exists = rows.any((r) => r.read<String>('name') == column);
    if (!exists) {
      await db.customStatement(
          'ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, await resolveDbName()));
    return NativeDatabase(file);
  });
}
