import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../core/utils/currency.dart';
import '../core/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool showStock;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showStock = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasLowStock = product.stock < 10;
    final isOutOfStock = product.stock <= 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: product.active && !isOutOfStock ? onTap : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: AppColors.background,
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // SKU
                  if (product.sku != null)
                    Text(
                      product.sku!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    CurrencyUtils.format(product.price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  // Stock indicator
                  if (showStock) ...[
                    const SizedBox(height: 8),
                    _buildStockIndicator(hasLowStock, isOutOfStock),
                  ],

                  // Category
                  if (product.category != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.category!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 48,
        color: AppColors.textHint,
      ),
    );
  }

  Widget _buildStockIndicator(bool hasLowStock, bool isOutOfStock) {
    Color color;
    String text;
    IconData icon;

    if (isOutOfStock) {
      color = AppColors.error;
      text = 'Out of Stock';
      icon = Icons.error_outline;
    } else if (hasLowStock) {
      color = AppColors.warning;
      text = 'Low Stock: ${product.stock}';
      icon = Icons.warning_amber_outlined;
    } else {
      color = AppColors.success;
      text = 'Stock: ${product.stock}';
      icon = Icons.check_circle_outline;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
