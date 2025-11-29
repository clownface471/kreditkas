import '../models/store_profile.dart';
import '../models/credit_plan.dart';
import '../storage/db_service.dart';

class SettingsRepository {
  final DbService _db = DbService.instance;

  /// Get store profile
  StoreProfile getStoreProfile() {
    return _db.getStoreProfile() ?? StoreProfile.defaultProfile();
  }

  /// Save store profile
  Future<void> saveStoreProfile(StoreProfile profile) async {
    await _db.saveStoreProfile(profile);
  }

  /// Get default credit plans
  List<CreditPlan> getDefaultCreditPlans() {
    final plans = _db.getSetting<List>('credit_plans');
    if (plans == null || plans.isEmpty) {
      return [
        CreditPlan(tenorMonths: 3, interestRate: 2.0),
        CreditPlan(tenorMonths: 6, interestRate: 1.5),
        CreditPlan(tenorMonths: 12, interestRate: 1.0),
      ];
    }
    return plans
        .map((p) => CreditPlan.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Save default credit plans
  Future<void> saveDefaultCreditPlans(List<CreditPlan> plans) async {
    await _db.setSetting('credit_plans', plans.map((p) => p.toJson()).toList());
  }

  /// Get drawer settings (Windows only)
  Map<String, dynamic> getDrawerSettings() {
    return {
      'enabled': _db.getSetting<bool>('drawer_enabled', defaultValue: false),
      'port': _db.getSetting<String>('drawer_port', defaultValue: 'COM1'),
    };
  }

  /// Save drawer settings
  Future<void> saveDrawerSettings({
    required bool enabled,
    required String port,
  }) async {
    await _db.setSetting('drawer_enabled', enabled);
    await _db.setSetting('drawer_port', port);
  }

  /// Check if licensed
  bool get isLicensed => _db.isLicensed;

  /// Set licensed status
  Future<void> setLicensed(bool value) async {
    await _db.setLicensed(value);
  }

  /// Get a generic setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _db.getSetting<T>(key, defaultValue: defaultValue);
  }

  /// Set a generic setting
  Future<void> setSetting(String key, dynamic value) async {
    await _db.setSetting(key, value);
  }
}
