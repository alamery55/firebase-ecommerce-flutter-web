import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';

/// A globally-fixed horizontal categories bar.
/// Placed at the top of AppShell — persists across all tabs.
/// Selecting a category filters the Home screen products.
class CategoriesBar extends StatelessWidget {
  const CategoriesBar({super.key});

  /// Category data with icons and accent colors - updated for minimal design
  static const List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps_rounded, 'color': Color(0xFF0D9488)},
    {
      'name': 'Electronics',
      'icon': Icons.devices_rounded,
      'color': Color(0xFF6366F1),
    },
    {
      'name': 'Fashion',
      'icon': Icons.checkroom_rounded,
      'color': Color(0xFFEC4899),
    },
    {'name': 'Home', 'icon': Icons.home_outlined, 'color': Color(0xFF0EA5E9)},
    {
      'name': 'Sports',
      'icon': Icons.sports_basketball_rounded,
      'color': Color(0xFFF59E0B),
    },
    {
      'name': 'Books',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF10B981),
    },
    {'name': 'Beauty', 'icon': Icons.spa_rounded, 'color': Color(0xFFA855F7)},
  ];

  @override
  Widget build(BuildContext context) {
    final shop = Provider.of<ShopProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final selectedCategory = shop.selectedCategory;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: SizedBox(
        height: 78,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: _categories.length,
          itemBuilder: (ctx, index) {
            final cat = _categories[index];
            final name = cat['name'] as String;
            final icon = cat['icon'] as IconData;
            final color = cat['color'] as Color;

            // "All" means no filter (null); otherwise match by name
            final isSelected =
                (name == 'All' && selectedCategory == null) ||
                (name != 'All' && selectedCategory == name);

            return GestureDetector(
              onTap: () {
                // Set category filter — null means "show all"
                shop.setSelectedCategory(name == 'All' ? null : name);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 72,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? color.withValues(alpha: 0.6)
                        : colors.outline.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.2)
                            : color.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? color
                            : color.withValues(alpha: 0.6),
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Label
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? color : colors.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
