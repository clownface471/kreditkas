import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? sku;

  @HiveField(3)
  final String? category;

  @HiveField(4)
  final double price; // tax excl. by default

  @HiveField(5)
  int stock;

  @HiveField(6)
  final String? imageUrl;

  @HiveField(7)
  final bool active;

  Product({
    required this.id,
    required this.name,
    this.sku,
    this.category,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.active = true,
  });

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? price,
    int? stock,
    String? imageUrl,
    bool? active,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'active': active,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      category: json['category'] as String?,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      imageUrl: json['imageUrl'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }
}
