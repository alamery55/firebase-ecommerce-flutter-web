import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/common_widgets.dart';
import '../widgets/connectivity_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final shop = Provider.of<ShopProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final products = shop.products;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── App Bar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 110,
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.storefront, color: colors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'ShopVibe',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary.withValues(alpha: 0.15),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // Connection status indicator
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ConnectivityIndicator(),
              ),
              IconButton(
                onPressed: () => themeProvider.toggleTheme(),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      RotationTransition(turns: anim, child: child),
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    key: ValueKey(themeProvider.isDarkMode),
                    color: colors.onSurface,
                  ),
                ),
                tooltip: themeProvider.isDarkMode
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
              ),
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

          // ─── Connectivity Banner ──────────────────────────
          SliverToBoxAdapter(child: const ConnectivityBanner()),

          // ─── Data Source Indicator ────────────────────────
          if (shop.dataSourceDescription != null &&
              shop.state == ShopState.loaded)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: shop.fromCache
                        ? Colors.orange.withValues(alpha: 0.15)
                        : colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: shop.fromCache
                          ? Colors.orange.withValues(alpha: 0.3)
                          : colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        shop.fromCache
                            ? Icons.history_rounded
                            : Icons.cloud_rounded,
                        size: 14,
                        color: shop.fromCache
                            ? Colors.orange.shade700
                            : colors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        shop.dataSourceDescription!,
                        style: TextStyle(
                          fontSize: 12,
                          color: shop.fromCache
                              ? Colors.orange.shade700
                              : colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ─── Section Header ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Trending Now 🔥',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (shop.state == ShopState.loaded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${products.length} items',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── Content States ─────────────────────────────────
          _buildContent(shop, products, colors),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildContent(ShopProvider shop, List products, ColorScheme colors) {
    if (shop.state == ShopState.loading || shop.state == ShopState.initial) {
      return SliverToBoxAdapter(child: ProductGridSkeleton(itemCount: 6));
    }

    if (shop.state == ShopState.error) {
      return SliverFillRemaining(
        child: ErrorStateWidget(
          message: shop.errorMessage ?? 'Unable to load products',
          onRetry: () => shop.retry(),
        ),
      );
    }

    if (shop.state == ShopState.empty || products.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          message: 'No products available',
          icon: Icons.inventory_2_outlined,
          action: ElevatedButton.icon(
            onPressed: () => shop.retry(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate(
          (ctx, index) => ProductCard(product: products[index]),
          childCount: products.length,
        ),
      ),
    );
  }
}
