import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
  TextColumn get address => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
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
  // discount_type: 'percent' | 'amount'
  TextColumn get discountType =>
      text().withDefault(const Constant('percent'))();

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
  // invoice_type: 'delivery' | 'walk_in'
  TextColumn get invoiceType =>
      text().withDefault(const Constant('delivery'))();

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

/// Van selling stock transactions.
class VanStocks extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  // type: 'out' | 'in'
  TextColumn get type => text()();
  IntColumn get quantityPieces => integer()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();

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
  VanStocks,
  SyncQueue,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

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
    final file = File(p.join(dbFolder.path, 'gel_inventory.sqlite'));
    return NativeDatabase(file);
  });
}
