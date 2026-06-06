import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class IncentivesSettingsService {
  static const _key = 'incentives_supplier_ids';

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
}
