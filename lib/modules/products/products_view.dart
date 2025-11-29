import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/sidebar_nav.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/product_card.dart';
import 'products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

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
                  title: 'Products',
                  actions: [
                    AppBarAction(
                      icon: Icons.add,
                      tooltip: 'Add Product',
                      onPressed: () {
                        // TODO: Open add product dialog
                        Get.snackbar('Info', 'Add product dialog not implemented yet');
                      },
                    ),
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

                    return Column(
                      children: [
                        // Search and filters
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Search products...',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: controller.search,
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 200,
                                child: DropdownButtonFormField<String?>(
                                  value: controller.selectedCategory.value,
                                  decoration: const InputDecoration(
                                    labelText: 'Category',
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('All Categories'),
                                    ),
                                    ...controller.categories.map((cat) {
                                      return DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat),
                                      );
                                    }),
                                  ],
                                  onChanged: controller.filterByCategory,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Product grid
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 250,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: controller.filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = controller.filteredProducts[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  // TODO: Open product details
                                  Get.snackbar('Info', 'Clicked ${product.name}');
                                },
                              );
                            },
                          ),
                        ),
                      ],
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
}
