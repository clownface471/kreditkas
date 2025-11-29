import 'package:get/get.dart';
import '../../data/models/store_profile.dart';
import '../../data/models/credit_plan.dart';
import '../../data/repositories/settings_repo.dart';

class SettingsController extends GetxController {
  final SettingsRepository _settingsRepo;

  SettingsController(this._settingsRepo);

  // Store profile
  final Rx<StoreProfile> storeProfile = StoreProfile.defaultProfile().obs;

  // Credit plans
  final creditPlans = <CreditPlan>[].obs;

  // Drawer settings (Windows only)
  final drawerEnabled = false.obs;
  final drawerPort = 'COM1'.obs;

  // Loading state
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  /// Load all settings
  void loadSettings() {
    isLoading.value = true;
    try {
      storeProfile.value = _settingsRepo.getStoreProfile();
      creditPlans.value = _settingsRepo.getDefaultCreditPlans();

      final drawerSettings = _settingsRepo.getDrawerSettings();
      drawerEnabled.value = drawerSettings['enabled'] as bool;
      drawerPort.value = drawerSettings['port'] as String;
    } finally {
      isLoading.value = false;
    }
  }

  /// Save store profile
  Future<void> saveStoreProfile(StoreProfile profile) async {
    try {
      await _settingsRepo.saveStoreProfile(profile);
      storeProfile.value = profile;
      Get.snackbar('Success', 'Store profile saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save store profile: $e');
    }
  }

  /// Update store name
  Future<void> updateStoreName(String name) async {
    final updated = storeProfile.value.copyWith(name: name);
    await saveStoreProfile(updated);
  }

  /// Update store contact
  Future<void> updateStoreContact({
    String? address,
    String? phone,
    String? email,
  }) async {
    final updated = storeProfile.value.copyWith(
      address: address,
      phone: phone,
      email: email,
    );
    await saveStoreProfile(updated);
  }

  /// Update tax settings
  Future<void> updateTaxSettings({
    required double taxRate,
    required bool taxInclusive,
  }) async {
    final updated = storeProfile.value.copyWith(
      defaultTaxRate: taxRate,
      taxInclusive: taxInclusive,
    );
    await saveStoreProfile(updated);
  }

  /// Update discount default
  Future<void> updateDefaultDiscount(double discount) async {
    final updated = storeProfile.value.copyWith(defaultDiscount: discount);
    await saveStoreProfile(updated);
  }

  /// Update behavior settings
  Future<void> updateBehaviorSettings({
    required bool allowOversell,
    required bool requireCustomerForCredit,
    required bool autoOpenReceiptPreview,
  }) async {
    final updated = storeProfile.value.copyWith(
      allowOversell: allowOversell,
      requireCustomerForCredit: requireCustomerForCredit,
      autoOpenReceiptPreview: autoOpenReceiptPreview,
    );
    await saveStoreProfile(updated);
  }

  /// Update receipt settings
  Future<void> updateReceiptSettings({
    String? footerNote,
    String? returnPolicy,
  }) async {
    final updated = storeProfile.value.copyWith(
      footerNote: footerNote,
      returnPolicy: returnPolicy,
    );
    await saveStoreProfile(updated);
  }

  /// Save credit plans
  Future<void> saveCreditPlans(List<CreditPlan> plans) async {
    try {
      await _settingsRepo.saveDefaultCreditPlans(plans);
      creditPlans.value = plans;
      Get.snackbar('Success', 'Credit plans saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save credit plans: $e');
    }
  }

  /// Add credit plan
  void addCreditPlan(CreditPlan plan) {
    final updated = [...creditPlans, plan];
    saveCreditPlans(updated);
  }

  /// Remove credit plan
  void removeCreditPlan(int index) {
    final updated = [...creditPlans];
    updated.removeAt(index);
    saveCreditPlans(updated);
  }

  /// Update credit plan
  void updateCreditPlan(int index, CreditPlan plan) {
    final updated = [...creditPlans];
    updated[index] = plan;
    saveCreditPlans(updated);
  }

  /// Save drawer settings
  Future<void> saveDrawerSettings({
    required bool enabled,
    required String port,
  }) async {
    try {
      await _settingsRepo.saveDrawerSettings(enabled: enabled, port: port);
      drawerEnabled.value = enabled;
      drawerPort.value = port;
      Get.snackbar('Success', 'Drawer settings saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save drawer settings: $e');
    }
  }

  /// Test drawer (Windows only)
  Future<void> testDrawer() async {
    if (!drawerEnabled.value) {
      Get.snackbar('Info', 'Drawer is not enabled');
      return;
    }

    // Placeholder for actual drawer testing
    Get.snackbar('Info', 'Drawer test command sent to ${drawerPort.value}');
  }

  /// Refresh settings
  void refresh() {
    loadSettings();
  }
}
