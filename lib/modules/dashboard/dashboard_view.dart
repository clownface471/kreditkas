import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/sidebar_nav.dart';
import '../../widgets/app_bar.dart';
import '../../core/utils/currency.dart';
import '../../core/theme/app_colors.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SidebarNav(),
          Expanded(
            child: Column(
              children: [
                CustomAppBar(
                  title: 'Dashboard',
                  actions: [
                    AppBarAction(
                      icon: Icons.refresh,
                      tooltip: 'Refresh',
                      onPressed: controller.refresh,
                    ),
                  ],
                ),
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
                          // Filter buttons
                          _buildFilterButtons(),
                          const SizedBox(height: 24),

                          // Stats cards
                          _buildStatsCards(),
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

  Widget _buildFilterButtons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: controller.loadTodayStats,
          child: const Text('Today'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: controller.loadWeekStats,
          child: const Text('This Week'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: controller.loadMonthStats,
          child: const Text('This Month'),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Obx(() => Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              'Daily Sales',
              CurrencyUtils.format(controller.dailySales.value),
              Icons.attach_money,
              AppColors.success,
            ),
            _buildStatCard(
              'Outstanding Receivables',
              CurrencyUtils.format(controller.outstandingReceivables.value),
              Icons.account_balance_wallet,
              AppColors.warning,
            ),
            _buildStatCard(
              'Cash in Drawer',
              CurrencyUtils.format(controller.cashInDrawer.value),
              Icons.point_of_sale,
              AppColors.info,
            ),
            _buildStatCard(
              'Transactions',
              controller.transactionCount.value.toString(),
              Icons.receipt,
              AppColors.primary,
            ),
          ],
        ));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 32),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
