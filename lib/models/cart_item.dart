import 'product.dart';

/// CartItem wraps a Product with a quantity for the shopping cart.
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Calculates subtotal for this cart item
  double get subtotal => product.price * quantity;
}
