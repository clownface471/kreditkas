import '../data/repositories/settings_repo.dart';
import '../core/constants.dart';

class LicenseService {
  final SettingsRepository _settingsRepo;

  LicenseService(this._settingsRepo);

  /// Check if the app is licensed
  bool get isLicensed => _settingsRepo.isLicensed;

  /// Validate and activate license key
  Future<bool> activateLicense(String key) async {
    // Simple validation for MVP (local-only)
    // In production, this would validate against a server or use cryptographic verification
    if (_validateKey(key)) {
      await _settingsRepo.setLicensed(true);
      return true;
    }
    return false;
  }

  /// Deactivate license (for testing/reset)
  Future<void> deactivateLicense() async {
    await _settingsRepo.setLicensed(false);
  }

  /// Validate license key format and value
  bool _validateKey(String key) {
    // Basic validation
    if (key.isEmpty) return false;

    // Check against hardcoded key for MVP
    // In production, use proper cryptographic validation
    if (key.trim().toUpperCase() == AppConstants.licenseKey) {
      return true;
    }

    // Alternative: Check key format (e.g., XXXX-XXXX-XXXX-XXXX)
    final keyPattern = RegExp(r'^[A-Z0-9]{4,}-[A-Z0-9]{4,}-[A-Z0-9]{4,}(-[A-Z0-9]{4,})?$');
    if (keyPattern.hasMatch(key.toUpperCase())) {
      // Additional validation logic here
      return _checkKeyChecksum(key);
    }

    return false;
  }

  /// Simple checksum validation (placeholder for real crypto)
  bool _checkKeyChecksum(String key) {
    // This is a very basic implementation
    // In production, use proper cryptographic signing
    final parts = key.split('-');
    if (parts.length < 3) return false;

    // Simple sum-based checksum (not secure, just for demo)
    int sum = 0;
    for (final part in parts.take(parts.length - 1)) {
      for (final char in part.codeUnits) {
        sum += char;
      }
    }

    // Check if last part matches some function of the sum
    // This is just a placeholder - use real crypto in production
    return true; // Accept for MVP
  }

  /// Generate a trial key (for testing)
  String generateTrialKey() {
    // For testing purposes only
    return AppConstants.licenseKey;
  }

  /// Get license status info
  Map<String, dynamic> getLicenseInfo() {
    return {
      'isLicensed': isLicensed,
      'licenseType': isLicensed ? 'Full' : 'Trial',
      'features': {
        'unlimitedTransactions': isLicensed,
        'creditManagement': isLicensed,
        'reports': isLicensed,
        'export': isLicensed,
      },
    };
  }
}
