import 'package:hive/hive.dart';
import '../models/product.dart';
import '../storage/db_service.dart';

class ProductRepository {
  final DbService _db = DbService.instance;

  Box<Product> get _box => _db.products;

  /// Get all products
  List<Product> getAll() {
    return _box.values.toList();
  }

  /// Get active products only
  List<Product> getActive() {
    return _box.values.where((p) => p.active).toList();
  }

  /// Get product by ID
  Product? getById(String id) {
    return _box.values.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Product not found'),
    );
  }

  /// Search products by name or SKU
  List<Product> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          (p.sku?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Filter products by category
  List<Product> filterByCategory(String category) {
    return _box.values.where((p) => p.category == category).toList();
  }

  /// Get all unique categories
  List<String> getCategories() {
    final categories = <String>{};
    for (final product in _box.values) {
      if (product.category != null && product.category!.isNotEmpty) {
        categories.add(product.category!);
      }
    }
    return categories.toList()..sort();
  }

  /// Add a new product
  Future<void> add(Product product) async {
    await _box.put(product.id, product);
  }

  /// Update an existing product
  Future<void> update(Product product) async {
    await _box.put(product.id, product);
  }

  /// Delete a product
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Update stock for a product
  Future<void> updateStock(String id, int newStock) async {
    final product = getById(id);
    if (product != null) {
      final updated = product.copyWith(stock: newStock);
      await update(updated);
    }
  }

  /// Decrement stock (for sales)
  Future<bool> decrementStock(String id, int qty) async {
    final product = getById(id);
    if (product == null) return false;

    final newStock = product.stock - qty;
    if (newStock < 0) {
      // Check if oversell is allowed
      final allowOversell = _db.getSetting<bool>('allowOversell', defaultValue: false) ?? false;
      if (!allowOversell) return false;
    }

    product.stock = newStock;
    await product.save();
    return true;
  }

  /// Increment stock (for returns/restocking)
  Future<void> incrementStock(String id, int qty) async {
    final product = getById(id);
    if (product != null) {
      product.stock += qty;
      await product.save();
    }
  }

  /// Check if product has sufficient stock
  bool hasStock(String id, int qty) {
    final product = getById(id);
    if (product == null) return false;

    final allowOversell = _db.getSetting<bool>('allowOversell', defaultValue: false) ?? false;
    if (allowOversell) return true;

    return product.stock >= qty;
  }

  /// Import products from list (bulk operation)
  Future<void> importProducts(List<Product> products) async {
    final map = {for (var p in products) p.id: p};
    await _box.putAll(map);
  }

  /// Export all products
  List<Product> exportProducts() {
    return getAll();
  }
}
