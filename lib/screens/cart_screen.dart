import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../theme/app_theme.dart';

/// Cart Screen — displays all cart items with quantity controls, totals, and checkout.
/// Fully theme-adaptive for light and dark mode.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final shop = Provider.of<ShopProvider>(context);
    final cartItems = shop.cartItems;
    final total = shop.calculateTotal();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar( 
        title: const Text('My Cart'),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: () => _showClearCartDialog(context, shop),
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: colors.error,
                size: 20,
              ),
              label: Text(
                'Clear',
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          // ─── Empty Cart State ──────────────────────────
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 72,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse products and add items to your cart!',
                    style: TextStyle(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          // ─── Cart Content ──────────────────────────────
          : Column(
              children: [
                // Items count header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    children: [
                      Text(
                        '${shop.cartTotalItems} items in cart',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart items list
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    itemCount: cartItems.length,
                    itemBuilder: (ctx, index) {
                      final item = cartItems[index];
                      return Dismissible(
                        key: ValueKey(item.product.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) =>
                            shop.removeFromCart(item.product.id),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: colors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: Icon(
                            Icons.delete_outline,
                            color: colors.error,
                            size: 28,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.outline.withValues(alpha: 0.5),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Product image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.product.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    width: 80,
                                    height: 80,
                                    color: colors.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Product info & controls
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name & remove row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.product.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: colors.onSurface,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => shop.removeFromCart(
                                            item.product.id,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: colors.error.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              color: colors.error,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Price & quantity controls
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Subtotal
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '\$${item.product.price.toStringAsFixed(2)} each',
                                              style: TextStyle(
                                                color: colors.onSurfaceVariant,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '\$${item.subtotal.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: colors.primary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Quantity controls
                                        Container(
                                          decoration: BoxDecoration(
                                            color:
                                                colors.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              _QuantityButton(
                                                icon: Icons.remove,
                                                onTap: () =>
                                                    shop.decreaseQuantity(
                                                      item.product.id,
                                                    ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                    ),
                                                child: Text(
                                                  '${item.quantity}',
                                                  style: TextStyle(
                                                    color: colors.onSurface,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              _QuantityButton(
                                                icon: Icons.add,
                                                onTap: () =>
                                                    shop.increaseQuantity(
                                                      item.product.id,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ─── Total & Checkout ──────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -6),
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
                    top: false,
                    child: Column(
                      children: [
                        // Subtotal row
                        _PriceRow(
                          label: 'Subtotal',
                          amount: total,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        _PriceRow(
                          label: 'Shipping',
                          amountText: 'Free',
                          color: AppTheme.primaryColor,
                        ),
                        Divider(
                          color: colors.outline.withValues(alpha: 0.5),
                          height: 24,
                        ),
                        // Total row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Checkout button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () =>
                                _showCheckoutDialog(context, shop, total),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Checkout',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Shows a clear cart confirmation dialog.
  void _showClearCartDialog(BuildContext context, ShopProvider shop) {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear Cart?', style: TextStyle(color: colors.onSurface)),
        content: Text(
          'This will remove all items from your cart.',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              shop.clearCart();
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a mock checkout confirmation dialog.
  void _showCheckoutDialog(
    BuildContext context,
    ShopProvider shop,
    double total,
  ) {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
            const SizedBox(width: 10),
            Text('Order Placed!', style: TextStyle(color: colors.onSurface)),
          ],
        ),
        content: Text(
          'Your order of \$${total.toStringAsFixed(2)} has been placed successfully! 🎉',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              shop.clearCart();
              Navigator.of(ctx).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

/// Small button for quantity increment / decrement.
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colors.primary, size: 18),
      ),
    );
  }
}

/// Helper widget for price summary rows.
class _PriceRow extends StatelessWidget {
  final String label;
  final double? amount;
  final String? amountText;
  final Color color;

  const _PriceRow({
    required this.label,
    this.amount,
    this.amountText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 14)),
        Text(
          amountText ?? '\$${amount!.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
