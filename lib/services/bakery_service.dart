import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

import './supabase_service.dart';

class BakeryService {
  static BakeryService? _instance;
  static BakeryService get instance => _instance ??= BakeryService._internal();
  BakeryService._internal();

  final SupabaseClient _client = SupabaseService.instance.client;

  // Product Management
  Future<List<Map<String, dynamic>>> getProducts({
    String? categoryId,
    String? status,
    int? limit,
  }) async {
    try {
      PostgrestFilterBuilder<PostgrestList> query = _client.from('products').select('''
            *,
            product_categories(name),
            product_images(image_url, alt_text, is_primary)
          ''');

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      var transformedQuery = query.order('created_at', ascending: false);

      if (limit != null) {
        transformedQuery = transformedQuery.limit(limit);
      }

      final response = await transformedQuery;
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch products: $error');
    }
  }

  Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> productData) async {
    try {
      final response =
          await _client.from('products').insert(productData).select().single();
      return response;
    } catch (error) {
      throw Exception('Failed to create product: $error');
    }
  }

  Future<Map<String, dynamic>> updateProduct(
      String productId, Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('products')
          .update(updates)
          .eq('id', productId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update product: $error');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _client.from('products').delete().eq('id', productId);
    } catch (error) {
      throw Exception('Failed to delete product: $error');
    }
  }

  // Product Categories
  Future<List<Map<String, dynamic>>> getProductCategories() async {
    try {
      final response = await _client
          .from('product_categories')
          .select()
          .eq('is_active', true)
          .order('display_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch categories: $error');
    }
  }

  Future<Map<String, dynamic>> createCategory(
      Map<String, dynamic> categoryData) async {
    try {
      final response = await _client
          .from('product_categories')
          .insert(categoryData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create category: $error');
    }
  }

  // Product Images
  Future<Map<String, dynamic>> addProductImage(
      String productId, String imageUrl,
      {String? altText, bool isPrimary = false}) async {
    try {
      final response = await _client
          .from('product_images')
          .insert({
            'product_id': productId,
            'image_url': imageUrl,
            'alt_text': altText,
            'is_primary': isPrimary,
          })
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to add product image: $error');
    }
  }

  // Order Management
  Future<List<Map<String, dynamic>>> getOrders({
    String? status,
    String? customerId,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  }) async {
    try {
      PostgrestFilterBuilder<PostgrestList> query = _client.from('orders').select('''
            *,
            customers(
              *,
              user_profiles(full_name, email)
            ),
            order_items(
              *,
              products(name, price)
            )
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      if (customerId != null) {
        query = query.eq('customer_id', customerId);
      }

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      var transformedQuery = query.order('created_at', ascending: false);

      if (limit != null) {
        transformedQuery = transformedQuery.limit(limit);
      }

      final response = await transformedQuery;
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch orders: $error');
    }
  }

  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    try {
      final response =
          await _client.from('orders').insert(orderData).select().single();
      return response;
    } catch (error) {
      throw Exception('Failed to create order: $error');
    }
  }

  Future<String> generateOrderNumber() async {
    try {
      final response = await _client.rpc('generate_order_number');
      return response as String;
    } catch (error) {
      throw Exception('Failed to generate order number: $error');
    }
  }

  Future<void> addOrderItem(
      String orderId, String productId, int quantity, double unitPrice) async {
    try {
      await _client.from('order_items').insert({
        'order_id': orderId,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': quantity * unitPrice,
      });
    } catch (error) {
      throw Exception('Failed to add order item: $error');
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status) async {
    try {
      final response = await _client
          .from('orders')
          .update({'status': status})
          .eq('id', orderId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update order status: $error');
    }
  }

  // Customer Management
  Future<List<Map<String, dynamic>>> getCustomers({
    String? searchTerm,
    bool? isVip,
    int? limit,
  }) async {
    try {
      PostgrestFilterBuilder<PostgrestList> query = _client.from('customers').select('''
            *,
            user_profiles(full_name, email, is_active)
          ''');

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or(
            'user_profiles.full_name.ilike.%$searchTerm%,user_profiles.email.ilike.%$searchTerm%,phone.ilike.%$searchTerm%');
      }

      if (isVip != null) {
        query = query.eq('is_vip', isVip);
      }

      var transformedQuery = query.order('created_at', ascending: false);

      if (limit != null) {
        transformedQuery = transformedQuery.limit(limit);
      }

      final response = await transformedQuery;
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch customers: $error');
    }
  }

  Future<Map<String, dynamic>> createCustomer(
      Map<String, dynamic> customerData) async {
    try {
      final response =
          await _client.from('customers').insert(customerData).select('''
            *,
            user_profiles(full_name, email)
          ''').single();
      return response;
    } catch (error) {
      throw Exception('Failed to create customer: $error');
    }
  }

  Future<Map<String, dynamic>> updateCustomer(
      String customerId, Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('customers')
          .update(updates)
          .eq('id', customerId)
          .select('''
            *,
            user_profiles(full_name, email)
          ''').single();
      return response;
    } catch (error) {
      throw Exception('Failed to update customer: $error');
    }
  }

  Future<Map<String, dynamic>?> getCustomerByUserId(String userId) async {
    try {
      final response = await _client.from('customers').select('''
            *,
            user_profiles(full_name, email)
          ''').eq('user_profile_id', userId).maybeSingle();
      return response;
    } catch (error) {
      throw Exception('Failed to fetch customer: $error');
    }
  }

  // Delivery Management
  Future<List<Map<String, dynamic>>> getDeliveryRoutes({
    DateTime? date,
    String? driverId,
    String? status,
  }) async {
    try {
      PostgrestFilterBuilder<PostgrestList> query = _client.from('delivery_routes').select('''
            *,
            user_profiles!driver_id(full_name),
            order_deliveries(
              *,
              orders(
                order_number,
                total_amount,
                delivery_address,
                customers(
                  user_profiles(full_name)
                )
              )
            )
          ''');

      if (date != null) {
        query = query.eq('delivery_date', date.toIso8601String().split('T')[0]);
      }

      if (driverId != null) {
        query = query.eq('driver_id', driverId);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      var transformedQuery = query.order('delivery_date', ascending: true);

      final response = await transformedQuery;
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch delivery routes: $error');
    }
  }

  Future<Map<String, dynamic>> createDeliveryRoute(
      Map<String, dynamic> routeData) async {
    try {
      final response = await _client
          .from('delivery_routes')
          .insert(routeData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create delivery route: $error');
    }
  }

  // Analytics and Reports
  Future<Map<String, dynamic>> getDashboardMetrics({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = fromDate ?? DateTime(now.year, now.month, 1);
      final endDate = toDate ?? now;

      final ordersResponse = await _client
          .from('orders')
          .select('total_amount, status')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      final productsCount = await _client
          .from('products')
          .select()
          .eq('status', 'active')
          .count();

      final customersCount = await _client.from('customers').select().count();

      final orders = List<Map<String, dynamic>>.from(ordersResponse);
      final totalRevenue = orders.fold<double>(
          0.0, (sum, order) => sum + (order['total_amount'] ?? 0.0));
      final completedOrders =
          orders.where((order) => order['status'] == 'completed').length;
      final pendingOrders =
          orders.where((order) => order['status'] == 'pending').length;

      return {
        'total_revenue': totalRevenue,
        'total_orders': orders.length,
        'completed_orders': completedOrders,
        'pending_orders': pendingOrders,
        'active_products': productsCount.count ?? 0,
        'total_customers': customersCount.count ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch dashboard metrics: $error');
    }
  }

  // Storage helper for product images
  Future<String> uploadProductImage(
      String fileName, List<int> fileBytes) async {
    try {
      final filePath = 'products/$fileName';
      await _client.storage
          .from('product-images')
          .uploadBinary(filePath, Uint8List.fromList(fileBytes));

      return _client.storage.from('product-images').getPublicUrl(filePath);
    } catch (error) {
      throw Exception('Failed to upload product image: $error');
    }
  }
}