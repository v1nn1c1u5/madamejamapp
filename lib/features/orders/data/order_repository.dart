import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/order.dart';

const _orderSelect =
    '*, order_items(*, skus(name, products(name))), customers(name, phone)';

class OrderRepository {
  OrderRepository(this._client);

  final SupabaseClient _client;

  // ─── Cliente ─────────────────────────────────────────────────────────────

  Future<List<Order>> fetchMyOrders() async {
    final data = await _client
        .from('orders')
        .select(_orderSelect)
        .order('created_at', ascending: false);
    return _map(data);
  }

  /// Observa um pedido em tempo real com dados completos (order_items + joins).
  ///
  /// O Supabase `.stream()` não suporta `select` com joins; por isso usamos
  /// um [StreamController] que dispara um `fetchOrderDetail` completo sempre
  /// que o realtime notifica uma alteração na linha.
  Stream<Order?> watchOrder(String id) {
    late StreamController<Order?> controller;
    StreamSubscription<List<Map<String, dynamic>>>? realtimeSub;

    Future<void> fetchAndEmit() async {
      try {
        final order = await fetchOrderDetail(id);
        if (!controller.isClosed) controller.add(order);
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    controller = StreamController<Order?>(
      onListen: () {
        fetchAndEmit();
        realtimeSub = _client
            .from('orders')
            .stream(primaryKey: ['id'])
            .eq('id', id)
            .listen((_) => fetchAndEmit());
      },
      onCancel: () {
        realtimeSub?.cancel();
        controller.close();
      },
    );

    return controller.stream;
  }

  // ─── Admin ────────────────────────────────────────────────────────────────

  Future<List<Order>> fetchOrdersForWeek(DateTime monday) async {
    final sunday = monday.add(const Duration(days: 6));
    final data = await _client
        .from('orders')
        .select(_orderSelect)
        .eq('payment_status', 'paid')
        .gte('delivery_date', monday.toIso8601String().substring(0, 10))
        .lte('delivery_date', sunday.toIso8601String().substring(0, 10))
        .order('delivery_date');
    return _map(data);
  }

  Future<List<Order>> fetchOrdersForDay(DateTime day) async {
    final dateStr = day.toIso8601String().substring(0, 10);
    final data = await _client
        .from('orders')
        .select(_orderSelect)
        .eq('payment_status', 'paid')
        .eq('delivery_date', dateStr)
        .order('created_at');
    return _map(data);
  }

  Future<Order> fetchOrderDetail(String id) async {
    final data = await _client
        .from('orders')
        .select(_orderSelect)
        .eq('id', id)
        .single();
    return Order.fromJson(data);
  }

  Future<void> updateProductionStatus(
      String orderId, String status) async {
    await _client
        .from('orders')
        .update({'production_status': status})
        .eq('id', orderId);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  List<Order> _map(List<dynamic> data) =>
      data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(supabaseClientProvider));
});
