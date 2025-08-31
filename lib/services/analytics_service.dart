import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class RevenueData {
  final String label;
  final double value;
  final DateTime date;

  RevenueData({
    required this.label,
    required this.value,
    required this.date,
  });
}

class OrderDensity {
  final DateTime date;
  final int orderCount;

  OrderDensity({
    required this.date,
    required this.orderCount,
  });
}

class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();

  AnalyticsService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get revenue data for chart based on period
  Future<List<Map<String, dynamic>>> getRevenueChartData({
    required String period, // 'daily', 'weekly', 'monthly'
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = toDate ?? now;

      // Set date range based on period
      switch (period.toLowerCase()) {
        case 'diário':
        case 'daily':
          startDate = fromDate ?? DateTime(now.year, now.month, now.day - 6);
          return await _getDailyRevenueData(startDate, endDate);
        case 'semanal':
        case 'weekly':
          startDate = fromDate ?? DateTime(now.year, now.month, now.day - 42); // 6 weeks
          return await _getWeeklyRevenueData(startDate, endDate);
        case 'mensal':
        case 'monthly':
          startDate = fromDate ?? DateTime(now.year - 1, now.month, now.day); // 12 months
          return await _getMonthlyRevenueData(startDate, endDate);
        default:
          startDate = fromDate ?? DateTime(now.year, now.month, now.day - 6);
          return await _getDailyRevenueData(startDate, endDate);
      }
    } catch (error) {
      throw Exception('Erro ao buscar dados de receita: $error');
    }
  }

  Future<List<Map<String, dynamic>>> _getDailyRevenueData(
      DateTime startDate, DateTime endDate) async {
    final response = await _client
        .from('orders')
        .select('total_amount, created_at')
        .eq('status', 'completed')
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String())
        .order('created_at');

    final orders = List<Map<String, dynamic>>.from(response);
    
    // Group by day
    Map<String, double> dailyRevenue = {};
    final weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    
    // Initialize with zeros
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final date = startDate.add(Duration(days: i));
      final weekday = weekdays[(date.weekday - 1) % 7];
      final key = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ($weekday)';
      dailyRevenue[key] = 0.0;
    }

    // Sum actual revenue
    for (final order in orders) {
      final orderDate = DateTime.parse(order['created_at']);
      final weekday = weekdays[(orderDate.weekday - 1) % 7];
      final key = '${orderDate.day.toString().padLeft(2, '0')}/${orderDate.month.toString().padLeft(2, '0')} ($weekday)';
      dailyRevenue[key] = (dailyRevenue[key] ?? 0.0) + (order['total_amount'] ?? 0.0);
    }

    return dailyRevenue.entries
        .map((entry) => {
              'label': entry.key.split(' ')[1].replaceAll('(', '').replaceAll(')', ''),
              'value': entry.value,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getWeeklyRevenueData(
      DateTime startDate, DateTime endDate) async {
    final response = await _client
        .from('orders')
        .select('total_amount, created_at')
        .eq('status', 'completed')
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String())
        .order('created_at');

    final orders = List<Map<String, dynamic>>.from(response);
    
    // Group by week
    Map<String, double> weeklyRevenue = {};

    for (final order in orders) {
      final orderDate = DateTime.parse(order['created_at']);
      final weekStart = orderDate.subtract(Duration(days: orderDate.weekday - 1));
      final weekKey = 'Sem ${weekStart.day}/${weekStart.month}';
      
      weeklyRevenue[weekKey] = (weeklyRevenue[weekKey] ?? 0.0) + (order['total_amount'] ?? 0.0);
    }

    return weeklyRevenue.entries
        .map((entry) => {
              'label': entry.key,
              'value': entry.value,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getMonthlyRevenueData(
      DateTime startDate, DateTime endDate) async {
    final response = await _client
        .from('orders')
        .select('total_amount, created_at')
        .eq('status', 'completed')
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String())
        .order('created_at');

    final orders = List<Map<String, dynamic>>.from(response);
    
    // Group by month
    Map<String, double> monthlyRevenue = {};
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

    for (final order in orders) {
      final orderDate = DateTime.parse(order['created_at']);
      final monthKey = '${months[orderDate.month - 1]} ${orderDate.year}';
      
      monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0.0) + (order['total_amount'] ?? 0.0);
    }

    return monthlyRevenue.entries
        .map((entry) => {
              'label': entry.key,
              'value': entry.value,
            })
        .toList();
  }

  // Get order density for calendar
  Future<Map<DateTime, int>> getOrderDensity({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = fromDate ?? DateTime(now.year, now.month - 1, now.day);
      final endDate = toDate ?? now;

      final response = await _client
          .from('orders')
          .select('created_at')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at');

      final orders = List<Map<String, dynamic>>.from(response);
      
      Map<DateTime, int> orderDensity = {};

      for (final order in orders) {
        final orderDate = DateTime.parse(order['created_at']);
        final dateKey = DateTime(orderDate.year, orderDate.month, orderDate.day);
        
        orderDensity[dateKey] = (orderDensity[dateKey] ?? 0) + 1;
      }

      return orderDensity;
    } catch (error) {
      throw Exception('Erro ao buscar densidade de pedidos: $error');
    }
  }

  // Get top selling products
  Future<List<Map<String, dynamic>>> getTopSellingProducts({
    int limit = 10,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = fromDate ?? DateTime(now.year, now.month, 1);
      final endDate = toDate ?? now;

      final response = await _client.rpc('get_top_selling_products', params: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'limit_count': limit,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      // Fallback to manual calculation if function doesn't exist
      return await _getTopSellingProductsFallback(limit, startDate, endDate);
    }
  }

  Future<List<Map<String, dynamic>>> _getTopSellingProductsFallback(
      int limit, DateTime startDate, DateTime endDate) async {
    final response = await _client
        .from('order_items')
        .select('''
          quantity,
          products(id, name, price)
        ''')
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String());

    final items = List<Map<String, dynamic>>.from(response);
    
    Map<String, Map<String, dynamic>> productSales = {};

    for (final item in items) {
      final product = item['products'];
      if (product != null) {
        final productId = product['id'];
        final quantity = item['quantity'] ?? 0;
        
        if (productSales.containsKey(productId)) {
          productSales[productId]!['total_sold'] += quantity;
        } else {
          productSales[productId] = {
            'product_id': productId,
            'product_name': product['name'],
            'product_price': product['price'],
            'total_sold': quantity,
          };
        }
      }
    }

    final sortedProducts = productSales.values.toList()
      ..sort((a, b) => b['total_sold'].compareTo(a['total_sold']));

    return sortedProducts.take(limit).toList();
  }

  // Get customer analytics
  Future<Map<String, dynamic>> getCustomerAnalytics({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = fromDate ?? DateTime(now.year, now.month, 1);
      final endDate = toDate ?? now;

      // Get new customers in period
      final newCustomersResponse = await _client
          .from('customers')
          .select('id')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      // Get repeat customers (customers with more than 1 order in period)
      final repeatCustomersResponse = await _client
          .from('orders')
          .select('customer_id')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      final orders = List<Map<String, dynamic>>.from(repeatCustomersResponse);
      Map<String, int> customerOrderCount = {};
      
      for (final order in orders) {
        final customerId = order['customer_id'];
        customerOrderCount[customerId] = (customerOrderCount[customerId] ?? 0) + 1;
      }

      final repeatCustomers = customerOrderCount.values.where((count) => count > 1).length;

      return {
        'new_customers': newCustomersResponse.length,
        'repeat_customers': repeatCustomers,
        'total_customers_with_orders': customerOrderCount.length,
      };
    } catch (error) {
      throw Exception('Erro ao buscar análise de clientes: $error');
    }
  }

  // Get peak hours analysis
  Future<List<Map<String, dynamic>>> getPeakHoursAnalysis({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = fromDate ?? DateTime(now.year, now.month, 1);
      final endDate = toDate ?? now;

      final response = await _client
          .from('orders')
          .select('created_at')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      final orders = List<Map<String, dynamic>>.from(response);
      Map<int, int> hourlyOrders = {};

      // Initialize all hours
      for (int hour = 0; hour < 24; hour++) {
        hourlyOrders[hour] = 0;
      }

      for (final order in orders) {
        final orderDate = DateTime.parse(order['created_at']);
        final hour = orderDate.hour;
        hourlyOrders[hour] = (hourlyOrders[hour] ?? 0) + 1;
      }

      return hourlyOrders.entries
          .map((entry) => {
                'hour': entry.key,
                'label': '${entry.key.toString().padLeft(2, '0')}:00',
                'orders': entry.value,
              })
          .toList();
    } catch (error) {
      throw Exception('Erro ao buscar análise de horário de pico: $error');
    }
  }
}