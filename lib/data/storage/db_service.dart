import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/payment.dart';
import '../models/transaction.dart';
import '../models/store_profile.dart';
import 'hive_adapters.dart';

class DbService {
  static const String productsBox = 'products';
  static const String customersBox = 'customers';
  static const String transactionsBox = 'transactions';
  static const String paymentsBox = 'payments';
  static const String settingsBox = 'settings';
  static const String licenseBox = 'license';

  static DbService? _instance;
  static DbService get instance {
    _instance ??= DbService._();
    return _instance!;
  }

  DbService._();

  bool _initialized = false;

  /// Initialize Hive and open all boxes
  Future<void> init() async {
    if (_initialized) return;

    // Initialize Hive for Flutter (works on all platforms including web)
    await Hive.initFlutter();

    // Register adapters
    registerHiveAdapters();

    // Open all boxes
    await Future.wait([
      Hive.openBox<Product>(productsBox),
      Hive.openBox<Customer>(customersBox),
      Hive.openBox<Transaction>(transactionsBox),
      Hive.openBox<Payment>(paymentsBox),
      Hive.openBox(settingsBox),
      Hive.openBox(licenseBox),
    ]);

    _initialized = true;
  }

  /// Get a box by name
  Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  /// Get products box
  Box<Product> get products => getBox<Product>(productsBox);

  /// Get customers box
  Box<Customer> get customers => getBox<Customer>(customersBox);

  /// Get transactions box
  Box<Transaction> get transactions => getBox<Transaction>(transactionsBox);

  /// Get payments box
  Box<Payment> get payments => getBox<Payment>(paymentsBox);

  /// Get settings box
  Box get settings => getBox(settingsBox);

  /// Get license box
  Box get license => getBox(licenseBox);

  /// Close all boxes (useful for cleanup)
  Future<void> closeAll() async {
    await Hive.close();
    _initialized = false;
  }

  /// Clear all data (useful for testing or reset)
  Future<void> clearAll() async {
    await products.clear();
    await customers.clear();
    await transactions.clear();
    await payments.clear();
    await settings.clear();
    await license.clear();
  }

  /// Get store profile from settings
  StoreProfile? getStoreProfile() {
    return settings.get('store_profile') as StoreProfile?;
  }

  /// Save store profile to settings
  Future<void> saveStoreProfile(StoreProfile profile) async {
    await settings.put('store_profile', profile);
  }

  /// Check if app is licensed
  bool get isLicensed {
    return license.get('unlocked', defaultValue: false) as bool;
  }

  /// Set license status
  Future<void> setLicensed(bool value) async {
    await license.put('unlocked', value);
  }

  /// Get a setting value
  T? getSetting<T>(String key, {T? defaultValue}) {
    return settings.get(key, defaultValue: defaultValue) as T?;
  }

  /// Set a setting value
  Future<void> setSetting(String key, dynamic value) async {
    await settings.put(key, value);
  }
}
