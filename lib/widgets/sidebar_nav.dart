import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/constants.dart';

class SidebarNav extends StatelessWidget {
  const SidebarNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.sidebarBackground,
      child: Column(
        children: [
          // Logo and app name
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.point_of_sale,
                  size: 48,
                  color: AppColors.sidebarText,
                ),
                const SizedBox(height: 8),
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    color: AppColors.sidebarText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.sidebarText, height: 1),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: AppConstants.dashboardRoute,
                ),
                _NavItem(
                  icon: Icons.inventory,
                  title: 'Products',
                  route: AppConstants.productsRoute,
                ),
                _NavItem(
                  icon: Icons.shopping_cart,
                  title: 'Sales',
                  route: AppConstants.salesRoute,
                ),
                _NavItem(
                  icon: Icons.analytics,
                  title: 'Reports',
                  route: AppConstants.reportsRoute,
                ),
                _NavItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  route: AppConstants.settingsRoute,
                ),
              ],
            ),
          ),

          // Version info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'v${AppConstants.appVersion}',
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = Get.currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.sidebarActiveItem : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.sidebarText,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.sidebarText,
            fontSize: 16,
          ),
        ),
        onTap: () {
          if (!isActive) {
            Get.toNamed(route);
          }
        },
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
