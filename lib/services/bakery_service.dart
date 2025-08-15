import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class BakeryService {
  static BakeryService? _instance;
  static BakeryService get instance => _instance ??= BakeryService._();

  BakeryService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Generate unique order number
  Future<String> generateOrderNumber() async {
    try {
      final response = await _client.rpc('generate_order_number');
      return response as String;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Generate order number error: $error');
      }
      throw Exception('Failed to generate order number: $error');
    }
  }

  // Get dashboard metrics with improved error handling
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    try {
      // Test connection first
      if (!await SupabaseService.instance.testConnection()) {
        throw Exception('Database connection failed');
      }

      // Get total orders count
      final ordersCountResponse =
          await _client.from('orders').select('id').count();
      final totalOrders = ordersCountResponse.count ?? 0;

      // Get pending orders count
      final pendingOrdersResponse = await _client
          .from('orders')
          .select('id')
          .eq('status', 'pending')
          .count();
      final pendingOrders = pendingOrdersResponse.count ?? 0;

      // Get total revenue from completed orders
      final revenueResponse = await _client
          .from('orders')
          .select('total_amount')
          .eq('status', 'completed');

      double totalRevenue = 0.0;
      for (final order in revenueResponse) {
        totalRevenue += (order['total_amount'] as num?)?.toDouble() ?? 0.0;
      }

      // Get total customers count
      final customersCountResponse =
          await _client.from('customers').select('id').count();
      final totalCustomers = customersCountResponse.count ?? 0;

      if (kDebugMode) {
        print('✅ Dashboard metrics loaded successfully');
        print('   Orders: $totalOrders, Pending: $pendingOrders');
        print('   Revenue: R\$ ${totalRevenue.toStringAsFixed(2)}');
        print('   Customers: $totalCustomers');
      }

      return {
        'total_orders': totalOrders,
        'pending_orders': pendingOrders,
        'total_revenue': totalRevenue,
        'total_customers': totalCustomers,
      };
    } catch (error) {
      if (kDebugMode) {
        print('❌ Dashboard metrics error: $error');
      }
      throw Exception('Failed to get dashboard metrics: $error');
    }
  }

  // Create a new order
  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    try {
      final response =
          await _client.from('orders').insert(orderData).select().single();

      if (kDebugMode) {
        print('✅ Order created: ${response['order_number']}');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Create order error: $error');
      }
      throw Exception('Failed to create order: $error');
    }
  }

  // Add order item
  Future<Map<String, dynamic>> addOrderItem(
    String orderId,
    String productId,
    int quantity,
    double unitPrice,
  ) async {
    try {
      final response = await _client
          .from('order_items')
          .insert({
            'order_id': orderId,
            'product_id': productId,
            'quantity': quantity,
            'unit_price': unitPrice,
            'total_price': unitPrice * quantity,
          })
          .select()
          .single();

      if (kDebugMode) {
        print('✅ Order item added: Product $productId, Qty $quantity');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Add order item error: $error');
      }
      throw Exception('Failed to add order item: $error');
    }
  }

  // Get products with improved error handling and debugging
  Future<List<Map<String, dynamic>>> getProducts({
    int? limit,
    String? status,
  }) async {
    try {
      // Build query step by step
      var query = _client.from('products').select('''
            *,
            product_categories(name),
            product_images(image_url, is_primary, display_order)
          ''');

      // Apply status filter
      if (status != null) {
        query = query.eq('status', status);
      } else {
        query = query.eq('status', 'active');
      }

      // Apply ordering and limit
      final orderedQuery = query.order('name', ascending: true);
      final finalQuery =
          limit != null ? orderedQuery.limit(limit) : orderedQuery;

      final response = await finalQuery;

      if (kDebugMode) {
        print('✅ Products loaded: ${response.length} items');
        if (response.isNotEmpty) {
          print('   Sample: ${response.first['name']}');
        }
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      if (kDebugMode) {
        print('❌ Get products error: $error');
        print('   Status filter: $status');
        print('   Limit: $limit');
      }
      throw Exception('Failed to fetch products: $error');
    }
  }

  // Create a new product
  Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> productData) async {
    try {
      final response =
          await _client.from('products').insert(productData).select().single();

      if (kDebugMode) {
        print('✅ Product created: ${response['name']}');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Create product error: $error');
      }
      throw Exception('Failed to create product: $error');
    }
  }

  // Upload product image to Supabase Storage
  Future<String> uploadProductImage(String fileName, List<int> bytes) async {
    try {
      final path = 'products/$fileName';

      await _client.storage
          .from('product-images')
          .uploadBinary(path, Uint8List.fromList(bytes));

      final imageUrl =
          _client.storage.from('product-images').getPublicUrl(path);

      if (kDebugMode) {
        print('✅ Image uploaded: $path');
      }

      return imageUrl;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Upload image error: $error');
      }
      throw Exception('Failed to upload product image: $error');
    }
  }

  // Add product image record to database
  Future<Map<String, dynamic>> addProductImage(
    String productId,
    String imageUrl, {
    String? altText,
    bool isPrimary = false,
    int displayOrder = 0,
  }) async {
    try {
      final response = await _client
          .from('product_images')
          .insert({
            'product_id': productId,
            'image_url': imageUrl,
            'alt_text': altText,
            'is_primary': isPrimary,
            'display_order': displayOrder,
          })
          .select()
          .single();

      if (kDebugMode) {
        print('✅ Product image added to database');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Add product image error: $error');
      }
      throw Exception('Failed to add product image: $error');
    }
  }

  // Get customers with improved error handling
  Future<List<Map<String, dynamic>>> getCustomers({int? limit}) async {
    try {
      var query = _client.from('customers').select('''
        *,
        user_profiles(full_name, email)
      ''');

      final orderedQuery = query.order('created_at', ascending: false);
      final finalQuery =
          limit != null ? orderedQuery.limit(limit) : orderedQuery;

      final response = await finalQuery;

      if (kDebugMode) {
        print('✅ Customers loaded: ${response.length} items');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      if (kDebugMode) {
        print('❌ Get customers error: $error');
      }
      throw Exception('Failed to fetch customers: $error');
    }
  }

  // Get product categories
  Future<List<Map<String, dynamic>>> getProductCategories() async {
    try {
      final response = await _client
          .from('product_categories')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true)
          .order('name', ascending: true);

      if (kDebugMode) {
        print('✅ Product categories loaded: ${response.length} items');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      if (kDebugMode) {
        print('❌ Get categories error: $error');
      }
      throw Exception('Failed to fetch product categories: $error');
    }
  }

  // Get orders with improved error handling
  Future<List<Map<String, dynamic>>> getOrders({
    String? status,
    String? customerId,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('orders').select('''
            *,
            customers(name, user_profiles(full_name, email)),
            user_profiles!orders_created_by_fkey(full_name)
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      if (customerId != null) {
        query = query.eq('customer_id', customerId);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);

      if (kDebugMode) {
        print('✅ Orders loaded: ${response.length} items');
        if (status != null) print('   Filtered by status: $status');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      if (kDebugMode) {
        print('❌ Get orders error: $error');
      }
      throw Exception('Failed to fetch orders: $error');
    }
  }

  // Update order status
  Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status) async {
    try {
      final response = await _client
          .from('orders')
          .update({'status': status, 'updated_at': 'now()'})
          .eq('id', orderId)
          .select()
          .single();

      if (kDebugMode) {
        print('✅ Order status updated: ${response['order_number']} -> $status');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Update order status error: $error');
      }
      throw Exception('Failed to update order status: $error');
    }
  }

  // Get order details with items
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final orderResponse = await _client.from('orders').select('''
            *,
            customers(*, user_profiles(full_name, email)),
            user_profiles!orders_created_by_fkey(full_name)
          ''').eq('id', orderId).single();

      final itemsResponse = await _client.from('order_items').select('''
            *,
            products(name, description, price)
          ''').eq('order_id', orderId).order('created_at');

      if (kDebugMode) {
        print('✅ Order details loaded: ${orderResponse['order_number']}');
      }

      return {
        ...orderResponse,
        'items': itemsResponse,
      };
    } catch (error) {
      if (kDebugMode) {
        print('❌ Get order details error: $error');
      }
      throw Exception('Failed to fetch order details: $error');
    }
  }
}
