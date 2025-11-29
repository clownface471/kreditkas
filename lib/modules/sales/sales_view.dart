import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/sidebar_nav.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/product_card.dart';
import '../../data/models/payment.dart';
import '../../core/utils/currency.dart';
import '../../core/theme/app_colors.dart';
import 'sales_controller.dart';
import '../products/products_controller.dart';

class SalesView extends GetView<SalesController> {
  const SalesView({super.key});

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
                  title: 'Sales',
                  actions: [
                    AppBarAction(
                      icon: Icons.clear_all,
                      tooltip: 'Clear Cart',
                      onPressed: controller.clearCart,
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      // Left: Product selection
                      Expanded(
                        flex: 2,
                        child: _buildProductGrid(),
                      ),

                      // Right: Cart and checkout
                      SizedBox(
                        width: 400,
                        child: _buildCart(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final productsController = Get.find<ProductsController>();

    return Obx(() {
      final products = productsController.filteredProducts;

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => controller.addToCart(product),
            showStock: true,
          );
        },
      );
    });
  }

  Widget _buildCart() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        children: [
          // Cart items
          Expanded(
            child: Obx(() {
              if (controller.cart.isEmpty) {
                return const Center(
                  child: Text('Cart is empty\nAdd products to start'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.cart.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = controller.cart[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('${CurrencyUtils.format(item.unitPrice)} x ${item.qty}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyUtils.format(item.lineTotal),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => controller.removeFromCart(item.productId),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          // Totals and payment
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', controller.subtotal),
                _buildSummaryRow('Discount', -controller.discountAmount),
                _buildSummaryRow('Tax', controller.taxAmount),
                const Divider(),
                _buildSummaryRow('Total', controller.total, isBold: true),
                const SizedBox(height: 16),

                // Payment method toggle
                Obx(() => SegmentedButton<PaymentMethod>(
                      segments: const [
                        ButtonSegment(
                          value: PaymentMethod.cash,
                          label: Text('Cash'),
                          icon: Icon(Icons.money),
                        ),
                        ButtonSegment(
                          value: PaymentMethod.credit,
                          label: Text('Credit'),
                          icon: Icon(Icons.credit_card),
                        ),
                      ],
                      selected: {controller.paymentMethod.value},
                      onSelectionChanged: (Set<PaymentMethod> selected) {
                        controller.setPaymentMethod(selected.first);
                      },
                    )),
                const SizedBox(height: 16),

                // Checkout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.checkout,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Complete Sale', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                CurrencyUtils.format(value),
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ));
  }
}
