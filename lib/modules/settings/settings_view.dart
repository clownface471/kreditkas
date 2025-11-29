import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/sidebar_nav.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/form_fields.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SidebarNav(),
          Expanded(
            child: Column(
              children: [
                const CustomAppBar(title: 'Settings'),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStoreInfoSection(),
                          const SizedBox(height: 32),
                          _buildTaxDiscountSection(),
                          const SizedBox(height: 32),
                          _buildBehaviorSection(),
                          const SizedBox(height: 32),
                          _buildCreditPlansSection(),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfoSection() {
    return Obx(() => FormSection(
          title: 'Store Information',
          children: [
            CustomTextField(
              label: 'Store Name',
              controller: TextEditingController(
                text: controller.storeProfile.value.name,
              ),
              onChanged: (value) {
                // Auto-save on change
                controller.updateStoreName(value);
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Address',
              controller: TextEditingController(
                text: controller.storeProfile.value.address ?? '',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Phone',
              controller: TextEditingController(
                text: controller.storeProfile.value.phone ?? '',
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email',
              controller: TextEditingController(
                text: controller.storeProfile.value.email ?? '',
              ),
            ),
          ],
        ));
  }

  Widget _buildTaxDiscountSection() {
    return Obx(() => FormSection(
          title: 'Tax & Discount Defaults',
          children: [
            CustomNumberField(
              label: 'Tax Rate (%)',
              controller: TextEditingController(
                text: controller.storeProfile.value.defaultTaxRate.toString(),
              ),
              allowDecimals: true,
            ),
            const SizedBox(height: 16),
            CustomCheckbox(
              label: 'Tax Inclusive',
              value: controller.storeProfile.value.taxInclusive,
              onChanged: (value) {
                // TODO: Update tax inclusive setting
              },
            ),
            const SizedBox(height: 16),
            CustomNumberField(
              label: 'Default Discount',
              controller: TextEditingController(
                text: controller.storeProfile.value.defaultDiscount.toString(),
              ),
              allowDecimals: true,
            ),
          ],
        ));
  }

  Widget _buildBehaviorSection() {
    return Obx(() => FormSection(
          title: 'Behavior Settings',
          children: [
            CustomCheckbox(
              label: 'Allow Oversell',
              value: controller.storeProfile.value.allowOversell,
              onChanged: (value) {
                // TODO: Update allow oversell setting
              },
            ),
            CustomCheckbox(
              label: 'Require Customer for Credit',
              value: controller.storeProfile.value.requireCustomerForCredit,
              onChanged: (value) {
                // TODO: Update require customer setting
              },
            ),
            CustomCheckbox(
              label: 'Auto-open Receipt Preview',
              value: controller.storeProfile.value.autoOpenReceiptPreview,
              onChanged: (value) {
                // TODO: Update auto-open setting
              },
            ),
          ],
        ));
  }

  Widget _buildCreditPlansSection() {
    return Obx(() => FormSection(
          title: 'Credit Plans',
          children: [
            ...controller.creditPlans.asMap().entries.map((entry) {
              final index = entry.key;
              final plan = entry.value;
              return Card(
                child: ListTile(
                  title: Text('${plan.tenorMonths} Months'),
                  subtitle: Text('Interest: ${plan.interestRate}% per month'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => controller.removeCreditPlan(index),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Open add credit plan dialog
                Get.snackbar('Info', 'Add credit plan dialog not implemented yet');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Credit Plan'),
            ),
          ],
        ));
  }
}
