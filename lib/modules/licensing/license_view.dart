import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import 'license_controller.dart';

class LicenseView extends GetView<LicenseController> {
  const LicenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App icon/logo
                  const Icon(
                    Icons.point_of_sale,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),

                  // App name
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Multi-platform POS System',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // License key input
                  Obx(() => TextField(
                        decoration: const InputDecoration(
                          labelText: 'License Key',
                          hintText: 'Enter your license key',
                          prefixIcon: Icon(Icons.vpn_key),
                        ),
                        onChanged: (value) => controller.licenseKey.value = value,
                        enabled: !controller.isValidating.value,
                      )),
                  const SizedBox(height: 24),

                  // Activate button
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isValidating.value
                              ? null
                              : () => controller.activateLicense(controller.licenseKey.value),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: controller.isValidating.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    'Activate License',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),

                  // Trial key button
                  TextButton(
                    onPressed: controller.copyTrialKey,
                    child: const Text('Get Trial Key'),
                  ),

                  const SizedBox(height: 16),

                  // Info text
                  const Text(
                    'Enter your license key to unlock all features',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
