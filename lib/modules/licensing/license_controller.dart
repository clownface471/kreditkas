import 'package:get/get.dart';
import '../../services/license_service.dart';

class LicenseController extends GetxController {
  final LicenseService _licenseService;

  LicenseController(this._licenseService);

  // State
  final isLicensed = false.obs;
  final licenseKey = ''.obs;
  final isValidating = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLicenseStatus();
  }

  /// Check current license status
  void checkLicenseStatus() {
    isLicensed.value = _licenseService.isLicensed;
  }

  /// Validate and activate license
  Future<void> activateLicense(String key) async {
    if (key.isEmpty) {
      Get.snackbar('Error', 'Please enter a license key');
      return;
    }

    isValidating.value = true;
    try {
      final success = await _licenseService.activateLicense(key);
      if (success) {
        isLicensed.value = true;
        Get.snackbar('Success', 'License activated successfully!');

        // Navigate to dashboard
        Get.offAllNamed('/dashboard');
      } else {
        Get.snackbar(
          'Error',
          'Invalid license key. Please check and try again.',
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to activate license: $e');
    } finally {
      isValidating.value = false;
    }
  }

  /// Deactivate license (for testing)
  Future<void> deactivateLicense() async {
    try {
      await _licenseService.deactivateLicense();
      isLicensed.value = false;
      Get.snackbar('Info', 'License deactivated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to deactivate license: $e');
    }
  }

  /// Get trial key (for testing)
  String getTrialKey() {
    return _licenseService.generateTrialKey();
  }

  /// Get license info
  Map<String, dynamic> getLicenseInfo() {
    return _licenseService.getLicenseInfo();
  }

  /// Copy trial key to clipboard (simulated)
  void copyTrialKey() {
    final trialKey = getTrialKey();
    licenseKey.value = trialKey;
    Get.snackbar(
      'Trial Key',
      'Use this key to unlock: $trialKey',
      duration: const Duration(seconds: 10),
    );
  }
}
