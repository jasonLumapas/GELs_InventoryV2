import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists app-wide visibility toggles, gated behind a settings password.
class AppSettingsService {
  static const String settingsPassword = 'g3l\$';

  static const _keyShowCapitalProfit  = 'settings_show_capital_profit';
  static const _keyShowOffSiteLoading = 'settings_show_offsite_loading';
  static const _keyShowImportCsv      = 'settings_show_import_csv';
  static const _keyInventoryReportShowSelling =
      'settings_inventory_report_show_selling';

  static Future<bool> _getFlag(String key, {bool defaultValue = true}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<void> _setFlag(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool> getShowCapitalProfit() => _getFlag(_keyShowCapitalProfit);
  static Future<void> setShowCapitalProfit(bool value) =>
      _setFlag(_keyShowCapitalProfit, value);

  static Future<bool> getShowOffSiteLoading() =>
      _getFlag(_keyShowOffSiteLoading);
  static Future<void> setShowOffSiteLoading(bool value) =>
      _setFlag(_keyShowOffSiteLoading, value);

  static Future<bool> getShowImportCsv() => _getFlag(_keyShowImportCsv);
  static Future<void> setShowImportCsv(bool value) =>
      _setFlag(_keyShowImportCsv, value);

  /// When true, the inventory report's grand total shows the ending
  /// inventory's selling value instead of its capital (withdrawal) value.
  static Future<bool> getInventoryReportShowSelling() =>
      _getFlag(_keyInventoryReportShowSelling, defaultValue: false);
  static Future<void> setInventoryReportShowSelling(bool value) =>
      _setFlag(_keyInventoryReportShowSelling, value);
}

final showCapitalProfitProvider =
    FutureProvider<bool>((ref) => AppSettingsService.getShowCapitalProfit());

final showOffSiteLoadingProvider =
    FutureProvider<bool>((ref) => AppSettingsService.getShowOffSiteLoading());

final showImportCsvProvider =
    FutureProvider<bool>((ref) => AppSettingsService.getShowImportCsv());

final inventoryReportShowSellingProvider = FutureProvider<bool>(
    (ref) => AppSettingsService.getInventoryReportShowSelling());
