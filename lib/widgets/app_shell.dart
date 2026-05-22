import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../screens/home_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/profile_screen.dart';
import 'connectivity_banner.dart';

/// Main app shell — 5 tab bottom navigation with page content.
/// Connectivity banner is overlaid at the top of the entire app.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // All 5 main screens
  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    CartScreen(),
    CategoriesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final shop = Provider.of<ShopProvider>(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      // Use a Stack so the connectivity banner floats above all content
      body: Stack(
        children: [
          // ─── Page Content ────────────────────────────────────
          IndexedStack(index: _currentIndex, children: _screens),

          // ─── Connectivity Banner (overlay at top) ────────────
          Positioned(top: 0, left: 0, right: 0, child: ConnectivityBanner()),
        ],
      ),

      // ─── 5-Tab Bottom Navigation Bar ──────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: colors.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => _switchTab(0),
                ),
                _NavItem(
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  label: 'Favorites',
                  isActive: _currentIndex == 1,
                  onTap: () => _switchTab(1),
                  badgeCount: shop.favorites.length,
                ),
                _NavItem(
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  label: 'Cart',
                  isActive: _currentIndex == 2,
                  onTap: () => _switchTab(2),
                  // ✅ Dynamic cart badge
                  badgeCount: shop.cartTotalItems,
                ),
                _NavItem(
                  icon: Icons.category_outlined,
                  activeIcon: Icons.category,
                  label: 'Categories',
                  isActive: _currentIndex == 3,
                  onTap: () => _switchTab(3),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: _currentIndex == 4,
                  onTap: () => _switchTab(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }
}

/// Custom navigation item with animated active state and optional badge.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? colors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? colors.primary : colors.onSurfaceVariant,
                  size: 24,
                ),
                // Red badge counter
                if (badgeCount > 0)
                  Positioned(
                    top: -6,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 17,
                        minHeight: 17,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? colors.primary : colors.onSurfaceVariant,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
