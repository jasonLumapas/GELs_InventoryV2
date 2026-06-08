import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists app-wide visibility toggles, gated behind a settings password.
class AppSettingsService {
  static const String settingsPassword = 'g3l\$';

  static const _keyShowCapitalProfit  = 'settings_show_capital_profit';
  static const _keyShowOffSiteLoading = 'settings_show_offsite_loading';
  static const _keyShowImportCsv      = 'settings_show_import_csv';

  static Future<bool> _getFlag(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? true;
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
}

final showCapitalProfitProvider =
    FutureProvider<bool>((ref) => AppSettingsService.getShowCapitalProfit());

final showOffSiteLoadingProvider =
    FutureProvider<bool>((ref) => AppSettingsService.getShowOffSiteLoading());

final showImportCsvProvider =
    FutureProvider<bool>((ref) => AppSettingsService.getShowImportCsv());
