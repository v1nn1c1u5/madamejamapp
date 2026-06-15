import '../../catalog/data/product_repository.dart';

class CartItem {
  const CartItem({
    required this.productId,
    required this.productName,
    required this.productMinQuantity,
    required this.sku,
    required this.quantity,
  });

  final String productId;
  final String productName;
  /// Mínimo total de unidades do produto (soma de SKUs) por pedido.
  final int productMinQuantity;
  final Sku sku;
  final int quantity;

  double get subtotal => sku.price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        productName: productName,
        productMinQuantity: productMinQuantity,
        sku: sku,
        quantity: quantity ?? this.quantity,
      );
}
