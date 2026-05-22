import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/product_card.dart';

/// Category Products Screen — displays products filtered by category.
/// Navigated to when user taps a category tile or chip.
class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryProductsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final shop = Provider.of<ShopProvider>(context);
    final filteredProducts = shop.getProductsByCategory(categoryName);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Show count of products in this category
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${filteredProducts.length} items',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: filteredProducts.isEmpty
          // ─── Empty State ────────────────────────────────
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 72,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products in $categoryName',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new arrivals!',
                    style: TextStyle(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          // ─── Product Grid ──────────────────────────────
          : GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(14),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.65,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (ctx, index) =>
                  ProductCard(product: filteredProducts[index]),
            ),
    );
  }
}
