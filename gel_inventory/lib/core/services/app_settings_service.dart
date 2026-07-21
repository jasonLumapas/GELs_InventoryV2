import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'instance_config_service.dart';

/// Persists app-wide visibility toggles, gated behind a settings password.
///
/// Keys are namespaced by [resolveInstanceId] so that separate copies of the
/// app running side by side on the same machine (see instance_config_service)
/// don't share these settings — SharedPreferences storage is otherwise keyed
/// by app identity alone, not by which folder the copy was launched from.
class AppSettingsService {
  static const String settingsPassword = 'gels_g3l\$';

  static String? _instanceIdCache;
  static Future<String> _instanceKeyPrefix() async {
    _instanceIdCache ??= await resolveInstanceId();
    return _instanceIdCache!.isEmpty ? '' : 'inst_${_instanceIdCache}_';
  }

  static const _keyShowCapitalProfit  = 'settings_show_capital_profit';
  static const _keyShowOffSiteLoading = 'settings_show_offsite_loading';
  static const _keyShowImportCsv      = 'settings_show_import_csv';
  static const _keyShowPreOrderDrafts = 'settings_show_pre_order_drafts';
  static const _keyShowVerifyPreOrder = 'settings_show_verify_pre_order';
  static const _keyInventoryReportShowSelling =
      'settings_inventory_report_show_selling';
  static const _keyAllowBadOrderNoClient =
      'settings_allow_bad_order_no_client';
  static const _keyInventoryAllowAddStock    = 'settings_inventory_allow_add_stock';
  static const _keyInventoryAllowRemoveStock = 'settings_inventory_allow_remove_stock';
  static const _keyInventoryShowHistory      = 'settings_inventory_show_history';
  static const _keyAllowDeleteCancelledInvoices =
      'settings_allow_delete_cancelled_invoices';

  static Future<bool> _getFlag(String key, {bool defaultValue = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final prefixedKey = '${await _instanceKeyPrefix()}$key';
    return prefs.getBool(prefixedKey) ?? defaultValue;
  }

  static Future<void> _setFlag(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final prefixedKey = '${await _instanceKeyPrefix()}$key';
    await prefs.setBool(prefixedKey, value);
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

  static Future<bool> getShowPreOrderDrafts() =>
      _getFlag(_keyShowPreOrderDrafts);
  static Future<void> setShowPreOrderDrafts(bool value) =>
      _setFlag(_keyShowPreOrderDrafts, value);

  static Future<bool> getShowVerifyPreOrder() =>
      _getFlag(_keyShowVerifyPreOrder);
  static Future<void> setShowVerifyPreOrder(bool value) =>
      _setFlag(_keyShowVerifyPreOrder, value);

  /// When true, the inventory report's grand total shows the ending
  /// inventory's selling value instead of its capital (withdrawal) value.
  static Future<bool> getInventoryReportShowSelling() =>
      _getFlag(_keyInventoryReportShowSelling, defaultValue: false);
  static Future<void> setInventoryReportShowSelling(bool value) =>
      _setFlag(_keyInventoryReportShowSelling, value);

  /// When true, Bad Order / Return entries can be saved without specifying
  /// a client — saved with a placeholder "No Client Specified" client.
  static Future<bool> getAllowBadOrderNoClient() =>
      _getFlag(_keyAllowBadOrderNoClient, defaultValue: false);
  static Future<void> setAllowBadOrderNoClient(bool value) =>
      _setFlag(_keyAllowBadOrderNoClient, value);

  static Future<bool> getInventoryAllowAddStock() =>
      _getFlag(_keyInventoryAllowAddStock);
  static Future<void> setInventoryAllowAddStock(bool value) =>
      _setFlag(_keyInventoryAllowAddStock, value);

  static Future<bool> getInventoryAllowRemoveStock() =>
      _getFlag(_keyInventoryAllowRemoveStock);
  static Future<void> setInventoryAllowRemoveStock(bool value) =>
      _setFlag(_keyInventoryAllowRemoveStock, value);

  static Future<bool> getInventoryShowHistory() =>
      _getFlag(_keyInventoryShowHistory);
  static Future<void> setInventoryShowHistory(bool value) =>
      _setFlag(_keyInventoryShowHistory, value);

  /// When true, cancelled invoices can be permanently deleted.
  static Future<bool> getAllowDeleteCancelledInvoices() =>
      _getFlag(_keyAllowDeleteCancelledInvoices);
  static Future<void> setAllowDeleteCancelledInvoices(bool value) =>
      _setFlag(_keyAllowDeleteCancelledInvoices, value);
}

final showCapitalProfitProvider =
    FutureProvider<bool>((ref) => AppSettingsService.getShowCapitalProfit());

final showOffSiteLoadingProvider =
    FutureProvider<bool>((ref) => AppSettingsService.getShowOffSiteLoading());

final showImportCsvProvider =
    FutureProvider<bool>((ref) => AppSettingsService.getShowImportCsv());

final showPreOrderDraftsProvider = FutureProvider<bool>(
    (ref) => AppSettingsService.getShowPreOrderDrafts());

final showVerifyPreOrderProvider = FutureProvider<bool>(
    (ref) => AppSettingsService.getShowVerifyPreOrder());

final inventoryReportShowSellingProvider = FutureProvider<bool>(
    (ref) => AppSettingsService.getInventoryReportShowSelling());

final allowBadOrderNoClientProvider = FutureProvider<bool>(
    (ref) => AppSettingsService.getAllowBadOrderNoClient());

final inventoryAllowAddStockProvider = FutureProvider<bool>(
    (ref) => AppSettingsService.getInventoryAllowAddStock());

final inventoryAllowRemoveStockProvider = FutureProvider<bool>(
    (ref) => AppSettingsService.getInventoryAllowRemoveStock());

final inventoryShowHistoryProvider = FutureProvider<bool>(
    (ref) => AppSettingsService.getInventoryShowHistory());

final allowDeleteCancelledInvoicesProvider = FutureProvider<bool>(
    (ref) => AppSettingsService.getAllowDeleteCancelledInvoices());
