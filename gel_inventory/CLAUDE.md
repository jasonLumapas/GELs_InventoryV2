# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All commands run from `gel_inventory/` (the Flutter project root).

```bash
# Run on Windows (primary target)
flutter run -d windows

# Run in browser
flutter run -d chrome

# Static analysis (must pass before considering work done)
flutter analyze

# Regenerate Drift ORM code after any schema change in local_db.dart
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart
```

## Architecture

### Online / Offline routing

Every repository extends `BaseRepository` (`lib/repositories/base_repository.dart`), which exposes `isOnline` from `ConnectivityService`. Each repository method follows the same pattern:

```dart
if (isOnline) {
  // read/write via Supabase
} else {
  // read/write via local Drift SQLite
  // + enqueue write ops to sync_queue via SyncService
}
```

`SyncService` (`lib/core/services/sync_service.dart`) listens on `ConnectivityService.onlineStream` and drains the `sync_queue` table against Supabase whenever the app comes back online (last-write-wins, ordered by `created_at`).

### Data layer

- **Local DB** — Drift (SQLite), defined in `lib/core/database/local_db.dart`. Schema version is `1`. After any table change, run `build_runner` to regenerate `local_db.g.dart`. The SQLite file is stored in `getApplicationDocumentsDirectory()/gel_inventory.sqlite`.
- **Remote DB** — Supabase (PostgreSQL). Credentials in `lib/core/constants.dart` (`supabaseUrl` must be the bare project URL, e.g. `https://xyz.supabase.co` — no path suffix).
- **Models** (`lib/models/`) — plain Dart classes with `fromJson`/`toJson`. These are separate from Drift-generated row classes.

> **Important:** Drift generates row classes named after the singular of each table (e.g. `Clients` → `Client`). These clash with the identically named model classes. Every repository file that imports both must hide the Drift row class:
> ```dart
> import '../core/database/local_db.dart' hide Client;
> ```

### State management

Riverpod `Provider` / `FutureProvider`. List providers live in their repository files (e.g. `suppliersListProvider` in `supplier_repository.dart`) so both list screens and form screens can access them. After any mutation, the form screen calls `ref.invalidate(xyzListProvider)` to force a re-fetch.

### Navigation

`go_router` configured in `lib/app.dart`. Routes follow the pattern `/entity` (list) and `/entity/:id` (form, where `id = 'new'` means create).

### Inventory quantity model

All quantities are stored and computed in **pieces**. Boxes are derived at display time: `boxes = quantityPieces ~/ piecesPerBox`. A product with no inventory row is treated as 0 stock — the Inventory screen shows all products regardless of whether an inventory row exists.

### Price history

Adding a new price for a product always **inserts** a new row in `product_prices` (never updates). The current price is always the row with the latest `effective_from`. Old rows are preserved as history and shown in the product form's "Price History" tab.

### Invoice flow

1. Create (`invoice_create_screen.dart`) — validates stock before allowing Print. On Print: saves invoice + items to DB, deducts inventory, generates PDF via `lib/utils/pdf_generator.dart`.
2. `invoice_items.quantity` is always stored in **pieces**, regardless of whether the user selected box or piece units.
3. Status lifecycle: `draft` → `printed` → `cancelled`. Cancelled invoices are excluded from all list queries.
