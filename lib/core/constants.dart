class AppConstants {
  // App info
  static const String appName = 'KreditKas';
  static const String appVersion = '1.0.0';

  // Hive boxes
  static const String productsBox = 'products';
  static const String customersBox = 'customers';
  static const String transactionsBox = 'transactions';
  static const String paymentsBox = 'payments';
  static const String settingsBox = 'settings';
  static const String licenseBox = 'license';

  // Settings keys
  static const String storeProfileKey = 'store_profile';
  static const String creditPlansKey = 'credit_plans';
  static const String drawerEnabledKey = 'drawer_enabled';
  static const String drawerPortKey = 'drawer_port';
  static const String licenseUnlockedKey = 'unlocked';

  // Routes
  static const String dashboardRoute = '/dashboard';
  static const String productsRoute = '/products';
  static const String salesRoute = '/sales';
  static const String reportsRoute = '/reports';
  static const String settingsRoute = '/settings';
  static const String licenseRoute = '/license';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const double minPrice = 0.01;
  static const double maxPrice = 999999999.99;

  // Credit defaults
  static const List<int> defaultTenors = [3, 6, 12];
  static const double defaultInterestRate = 2.0;
  static const double minInterestRate = 0.0;
  static const double maxInterestRate = 100.0;

  // Performance targets
  static const int uiUpdateDelay = 100; // ms
  static const int dashboardLoadDelay = 200; // ms
  static const int pdfGenerationTimeout = 500; // ms

  // Export formats
  static const String csvExtension = '.csv';
  static const String pdfExtension = '.pdf';

  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Receipt settings
  static const String defaultReceiptFooter = 'Thank you for your business!';
  static const String defaultReturnPolicy = 'Items can be returned within 7 days with receipt.';

  // Licensing
  static const String licenseKey = 'KREDITKAS-2024-FULL';

  // Asset paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String defaultLogoPath = '${imagesPath}logo.png';
  static const String placeholderImagePath = '${imagesPath}placeholder.png';
}
