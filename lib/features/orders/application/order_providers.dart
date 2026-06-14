import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/order_repository.dart';
import '../domain/order.dart';

final myOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) {
  return ref.read(orderRepositoryProvider).fetchMyOrders();
});

final orderDetailProvider =
    FutureProvider.autoDispose.family<Order, String>((ref, id) {
  return ref.read(orderRepositoryProvider).fetchOrderDetail(id);
});

final weekOrdersProvider =
    FutureProvider.autoDispose.family<List<Order>, DateTime>((ref, monday) {
  return ref.read(orderRepositoryProvider).fetchOrdersForWeek(monday);
});

final dayOrdersProvider =
    FutureProvider.autoDispose.family<List<Order>, DateTime>((ref, day) {
  return ref.read(orderRepositoryProvider).fetchOrdersForDay(day);
});
