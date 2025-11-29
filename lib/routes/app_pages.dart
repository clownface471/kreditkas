import 'package:get/get.dart';
import '../modules/dashboard/dashboard_view.dart';
import '../modules/dashboard/dashboard_controller.dart';
import '../modules/products/products_view.dart';
import '../modules/products/products_controller.dart';
import '../modules/sales/sales_view.dart';
import '../modules/sales/sales_controller.dart';
import '../modules/reports/reports_view.dart';
import '../modules/reports/reports_controller.dart';
import '../modules/settings/settings_view.dart';
import '../modules/settings/settings_controller.dart';
import '../modules/licensing/license_view.dart';
import '../modules/licensing/license_controller.dart';
import '../data/repositories/product_repo.dart';
import '../data/repositories/customer_repo.dart';
import '../data/repositories/transaction_repo.dart';
import '../data/repositories/settings_repo.dart';
import '../services/receipt_service.dart';
import '../services/print_service.dart';
import '../services/export_service.dart';
import '../services/license_service.dart';
import '../core/constants.dart';

class AppPages {
  static const initial = AppConstants.licenseRoute;

  static final routes = [
    GetPage(
      name: AppConstants.licenseRoute,
      page: () => const LicenseView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SettingsRepository());
        Get.lazyPut(() => LicenseService(Get.find()));
        Get.lazyPut(() => LicenseController(Get.find()));
      }),
    ),
    GetPage(
      name: AppConstants.dashboardRoute,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TransactionRepository());
        Get.lazyPut(() => DashboardController(Get.find()));
      }),
      middlewares: [LicenseMiddleware()],
    ),
    GetPage(
      name: AppConstants.productsRoute,
      page: () => const ProductsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProductRepository());
        Get.lazyPut(() => ProductsController(Get.find()));
      }),
      middlewares: [LicenseMiddleware()],
    ),
    GetPage(
      name: AppConstants.salesRoute,
      page: () => const SalesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProductRepository());
        Get.lazyPut(() => CustomerRepository());
        Get.lazyPut(() => TransactionRepository());
        Get.lazyPut(() => SettingsRepository());
        Get.lazyPut(() => ReceiptService());
        Get.lazyPut(() => PrintService());
        Get.lazyPut(() => ProductsController(Get.find()));
        Get.lazyPut(() => SalesController(
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
            ));
      }),
      middlewares: [LicenseMiddleware()],
    ),
    GetPage(
      name: AppConstants.reportsRoute,
      page: () => const ReportsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TransactionRepository());
        Get.lazyPut(() => ExportService());
        Get.lazyPut(() => PrintService());
        Get.lazyPut(() => ReportsController(Get.find(), Get.find(), Get.find()));
      }),
      middlewares: [LicenseMiddleware()],
    ),
    GetPage(
      name: AppConstants.settingsRoute,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SettingsRepository());
        Get.lazyPut(() => SettingsController(Get.find()));
      }),
      middlewares: [LicenseMiddleware()],
    ),
  ];
}

class LicenseMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final settingsRepo = SettingsRepository();
    final isLicensed = settingsRepo.isLicensed;

    if (!isLicensed) {
      return const RouteSettings(name: AppConstants.licenseRoute);
    }

    return null;
  }
}
