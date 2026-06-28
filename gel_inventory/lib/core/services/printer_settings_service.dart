import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists a printer name per document-type slot.
/// When no printer is saved for a slot, callers should fall back to the
/// system print dialog (Printing.layoutPdf).
class PrinterSettingsService {
  // ── Slot keys ─────────────────────────────────────────────────────────────
  static const invoice     = 'printer_invoice';
  static const invoiceList = 'printer_invoice_list';
  static const layout      = 'printer_layout';
  static const remittance  = 'printer_remittance';
  static const loading     = 'printer_loading';
  static const supplierDelivery = 'printer_supplier_delivery';
  static const purchaseOrder = 'printer_purchase_order';
  static const clientPurchases = 'printer_client_purchases';

  /// Human-readable label for each slot (used in the settings UI).
  static const Map<String, String> slotLabels = {
    invoice:     'Delivery Receipt',
    invoiceList: 'Invoice List',
    layout:      'Layout',
    remittance:  'Remittance',
    loading:     'Loading Report',
    supplierDelivery: 'Supplier Delivery Receipt',
    purchaseOrder: 'Purchase Order',
    clientPurchases: 'Client Purchases',
  };

  // ── API ───────────────────────────────────────────────────────────────────

  static Future<List<Printer>> listPrinters() =>
      Printing.listPrinters();

  /// Saves [printerName] for [slot].  Pass null to clear the slot (revert to
  /// dialog).
  static Future<void> save(String slot, String? printerName) async {
    final prefs = await SharedPreferences.getInstance();
    if (printerName == null) {
      await prefs.remove(slot);
    } else {
      await prefs.setString(slot, printerName);
    }
  }

  /// Returns the saved [Printer] for [slot], or null if:
  ///   • no printer has been saved, OR
  ///   • the saved printer is no longer installed.
  static Future<Printer?> load(String slot) async {
    final prefs = await SharedPreferences.getInstance();
    final name  = prefs.getString(slot);
    if (name == null) return null;
    final all = await Printing.listPrinters();
    return all.where((p) => p.name == name).firstOrNull;
  }

  /// Returns the saved printer name string (not the Printer object) for
  /// populating dropdowns without needing to call listPrinters.
  static Future<String?> loadName(String slot) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(slot);
  }
}
