import '../../catalog/data/product_repository.dart';

class CartItem {
  const CartItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final Sku sku;
  final int quantity;

  double get subtotal => sku.price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        productName: productName,
        sku: sku,
        quantity: quantity ?? this.quantity,
      );
}
