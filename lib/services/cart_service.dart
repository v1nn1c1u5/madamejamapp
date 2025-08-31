import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String? imageUrl;
  final String? description;
  int quantity;
  final Map<String, dynamic>? customizations;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
    this.quantity = 1,
    this.customizations,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'quantity': quantity,
      'customizations': customizations,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      name: json['name'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      description: json['description'],
      quantity: json['quantity'] ?? 1,
      customizations: json['customizations'],
    );
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    String? imageUrl,
    String? description,
    int? quantity,
    Map<String, dynamic>? customizations,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      customizations: customizations ?? this.customizations,
    );
  }
}

class CartService extends ChangeNotifier {
  static CartService? _instance;
  static CartService get instance => _instance ??= CartService._();

  CartService._();

  static const String _cartStorageKey = 'shopping_cart';
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => subtotal >= 50.0 ? 0.0 : 5.0; // Free delivery over R$ 50

  double get total => subtotal + deliveryFee;

  // Initialize and load cart from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadCartFromStorage();
    } catch (error) {
      debugPrint('Error loading cart from storage: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add item to cart
  Future<void> addItem({
    required String productId,
    required String name,
    required double price,
    String? imageUrl,
    String? description,
    int quantity = 1,
    Map<String, dynamic>? customizations,
  }) async {
    try {
      // Generate unique ID for cart item (product + customizations)
      final itemId = _generateItemId(productId, customizations);

      // Check if item already exists
      final existingItemIndex = _items.indexWhere((item) => item.id == itemId);

      if (existingItemIndex >= 0) {
        // Update quantity of existing item
        _items[existingItemIndex].quantity += quantity;
      } else {
        // Add new item
        final newItem = CartItem(
          id: itemId,
          productId: productId,
          name: name,
          price: price,
          imageUrl: imageUrl,
          description: description,
          quantity: quantity,
          customizations: customizations,
        );
        _items.add(newItem);
      }

      await _saveCartToStorage();
      notifyListeners();
    } catch (error) {
      throw Exception('Erro ao adicionar item ao carrinho: $error');
    }
  }

  // Remove item from cart
  Future<void> removeItem(String itemId) async {
    try {
      _items.removeWhere((item) => item.id == itemId);
      await _saveCartToStorage();
      notifyListeners();
    } catch (error) {
      throw Exception('Erro ao remover item do carrinho: $error');
    }
  }

  // Update item quantity
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeItem(itemId);
        return;
      }

      final itemIndex = _items.indexWhere((item) => item.id == itemId);
      if (itemIndex >= 0) {
        _items[itemIndex].quantity = newQuantity;
        await _saveCartToStorage();
        notifyListeners();
      }
    } catch (error) {
      throw Exception('Erro ao atualizar quantidade: $error');
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      _items.clear();
      await _saveCartToStorage();
      notifyListeners();
    } catch (error) {
      throw Exception('Erro ao limpar carrinho: $error');
    }
  }

  // Get item by ID
  CartItem? getItemById(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    return index >= 0 ? _items[index] : null;
  }

  // Check if product is in cart
  bool hasProduct(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  // Get total quantity for a specific product
  int getProductQuantity(String productId) {
    return _items
        .where((item) => item.productId == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  // Private methods
  String _generateItemId(String productId, Map<String, dynamic>? customizations) {
    final customizationString = customizations?.entries
            .map((e) => '${e.key}:${e.value}')
            .join('|') ??
        '';
    return '$productId${customizationString.isNotEmpty ? '_$customizationString' : ''}';
  }

  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartStorageKey);

      if (cartJson != null) {
        final List<dynamic> cartData = json.decode(cartJson);
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (error) {
      debugPrint('Error loading cart from storage: $error');
      _items = [];
    }
  }

  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString(_cartStorageKey, cartJson);
    } catch (error) {
      debugPrint('Error saving cart to storage: $error');
    }
  }

  // Helper methods for checkout
  List<Map<String, dynamic>> getCartItemsForOrder() {
    return _items.map((item) => {
      'product_id': item.productId,
      'quantity': item.quantity,
      'unit_price': item.price,
      'total_price': item.totalPrice,
      'special_instructions': item.customizations?.toString(),
    }).toList();
  }

  Map<String, dynamic> getOrderSummary() {
    return {
      'items': getCartItemsForOrder(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total_amount': total,
      'total_items': totalItems,
    };
  }
}