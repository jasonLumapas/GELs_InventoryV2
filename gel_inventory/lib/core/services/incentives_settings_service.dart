import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class IncentivesSettingsService {
  static const _key = 'incentives_supplier_ids';
  static const _percentKey = 'incentives_supplier_percents';

  static Future<List<String>> loadSupplierIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSupplierIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(ids));
  }

  /// Per-supplier incentive percentages for the "Per-Supplier" tab.
  /// Map of supplierId -> percent (e.g. 5.0 = 5%). Insertion order is
  /// preserved so the configured rows display in the order they were added.
  static Future<Map<String, double>> loadSupplierPercents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_percentKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveSupplierPercents(Map<String, double> percents) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_percentKey, jsonEncode(percents));
  }
}
