import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/product_card.dart';

/// Categories Screen — sticky horizontal category card + filtered product grid.
/// The category card stays fixed at the top while products scroll below.
/// Clean minimal design without large image blocks.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  /// Currently selected category in this screen (local state).
  /// Null means "All" products.
  String? _selectedCategory;

  /// Modern category data with icons and colors matching the requested design
  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'Electronics',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFF0D9488), // Teal
    },
    {
      'name': 'Accessories',
      'icon': Icons.person_outline_rounded,
      'color': Color(0xFF8B5CF6), // Purple
    },
    {
      'name': 'Fashion',
      'icon': Icons.checkroom_rounded,
      'color': Color(0xFFEC4899), // Pink
    },
    {
      'name': 'Furniture',
      'icon': Icons.business_center_rounded,
      'color': Color(0xFF0EA5E9), // Blue
    },
    {
      'name': 'Sports',
      'icon': Icons.phone_enabled_rounded,
      'color': Color(0xFFF59E0B), // Orange
    },
  ];

  @override
  Widget build(BuildContext context) {
    final shop = Provider.of<ShopProvider>(context);
    final colors = Theme.of(context).colorScheme;

    // Get products based on selected category
    final products = _selectedCategory == null
        ? shop.products
        : shop.getProductsByCategory(_selectedCategory!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          // Cart icon with badge
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: colors.onSurface,
                  size: 26,
                ),
                if (shop.cartTotalItems > 0)
                  Positioned(
                    top: 6,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${shop.cartTotalItems}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false, // AppBar handles the top safe area
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Modern Minimalist Categories Card ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Card Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'All Categories',
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Row(
                              children: [
                                // Show items count
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${products.length} items',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (_selectedCategory != null) ...[
                                  const SizedBox(width: 8),
                                  // Clear filter button
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.error.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.close_rounded,
                                            size: 11,
                                            color: colors.error,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            'Clear',
                                            style: TextStyle(
                                              color: colors.error,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Thin modern divider
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: colors.outline.withValues(alpha: 0.08),
                      ),

                      // Categories Row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _categories.map((cat) {
                            final name = cat['name'] as String;
                            final icon = cat['icon'] as IconData;
                            final color = cat['color'] as Color;
                            final isSelected = _selectedCategory == name;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Toggle selection: if already selected, clear it
                                    _selectedCategory = isSelected ? null : name;
                                  });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: AnimatedScale(
                                  scale: isSelected ? 1.05 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutBack,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Animated Icon container
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? color.withValues(alpha: 0.12)
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? color.withValues(alpha: 0.3)
                                                : Colors.transparent,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Icon(
                                          icon,
                                          color: isSelected
                                              ? color
                                              : color.withValues(alpha: 0.75),
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Category Label
                                      Text(
                                        name,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isSelected
                                              ? colors.onSurface
                                              : colors.onSurface.withValues(alpha: 0.7),
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: colors.outline.withValues(alpha: 0.08),
            ),

            // ─── Product Grid (scrollable) with smooth transition ────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: products.isEmpty
                    ? _buildEmptyState(colors)
                    : LayoutBuilder(
                        key: ValueKey(_selectedCategory ?? 'all'),
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          int crossAxisCount = 2;
                          double aspectRatio = 0.65;

                          if (width > 1200) {
                            crossAxisCount = 5;
                            aspectRatio = 0.7;
                          } else if (width > 900) {
                            crossAxisCount = 4;
                            aspectRatio = 0.68;
                          } else if (width > 600) {
                            crossAxisCount = 3;
                            aspectRatio = 0.65;
                          }

                          return GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(14),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: aspectRatio,
                            ),
                            itemCount: products.length,
                            itemBuilder: (ctx, index) =>
                                ProductCard(product: products[index]),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state widget for filtered results
  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 40,
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No products found',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different category to explore more products',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCategory = null; // Reset to "All"
                });
              },
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: colors.primary,
              ),
              label: Text(
                'Show All Products',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
