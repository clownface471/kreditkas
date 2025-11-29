import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repo.dart';

class ProductsController extends GetxController {
  final ProductRepository _productRepo;

  ProductsController(this._productRepo);

  // State
  final products = <Product>[].obs;
  final filteredProducts = <Product>[].obs;
  final searchQuery = ''.obs;
  final selectedCategory = Rx<String?>(null);
  final showActiveOnly = true.obs;
  final isLoading = false.obs;

  // Categories
  final categories = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadCategories();
  }

  /// Load all products
  void loadProducts() {
    isLoading.value = true;
    try {
      products.value = _productRepo.getAll();
      _applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load categories
  void loadCategories() {
    categories.value = _productRepo.getCategories();
  }

  /// Search products
  void search(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  /// Filter by category
  void filterByCategory(String? category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  /// Toggle active only filter
  void toggleActiveOnly() {
    showActiveOnly.value = !showActiveOnly.value;
    _applyFilters();
  }

  /// Apply all filters
  void _applyFilters() {
    var result = products.toList();

    // Filter by active status
    if (showActiveOnly.value) {
      result = result.where((p) => p.active).toList();
    }

    // Filter by category
    if (selectedCategory.value != null) {
      result = result.where((p) => p.category == selectedCategory.value).toList();
    }

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((p) {
        return p.name.toLowerCase().contains(query) ||
            (p.sku?.toLowerCase().contains(query) ?? false) ||
            (p.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    filteredProducts.value = result;
  }

  /// Add a new product
  Future<void> addProduct(Product product) async {
    await _productRepo.add(product);
    loadProducts();
    loadCategories();
  }

  /// Update an existing product
  Future<void> updateProduct(Product product) async {
    await _productRepo.update(product);
    loadProducts();
    loadCategories();
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    await _productRepo.delete(id);
    loadProducts();
    loadCategories();
  }

  /// Create a new product with default values
  Product createNewProduct({
    required String name,
    String? sku,
    String? category,
    required double price,
    required int stock,
    String? imageUrl,
  }) {
    return Product(
      id: const Uuid().v4(),
      name: name,
      sku: sku,
      category: category,
      price: price,
      stock: stock,
      imageUrl: imageUrl,
      active: true,
    );
  }

  /// Import products from CSV or other source
  Future<void> importProducts(List<Product> newProducts) async {
    await _productRepo.importProducts(newProducts);
    loadProducts();
    loadCategories();
  }

  /// Export products
  List<Product> exportProducts() {
    return _productRepo.exportProducts();
  }

  /// Check stock availability
  bool checkStock(String productId, int qty) {
    return _productRepo.hasStock(productId, qty);
  }

  /// Refresh products list
  void refresh() {
    loadProducts();
    loadCategories();
  }
}
