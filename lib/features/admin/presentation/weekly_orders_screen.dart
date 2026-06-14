import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../orders/application/order_providers.dart';
import '../../orders/domain/order.dart';

class WeeklyOrdersScreen extends ConsumerStatefulWidget {
  const WeeklyOrdersScreen({super.key});

  @override
  ConsumerState<WeeklyOrdersScreen> createState() =>
      _WeeklyOrdersScreenState();
}

class _WeeklyOrdersScreenState
    extends ConsumerState<WeeklyOrdersScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Monday of current week
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateTime(_weekStart.year, _weekStart.month, _weekStart.day);
  }

  void _prevWeek() =>
      setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() =>
      setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  @override
  Widget build(BuildContext context) {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    final orders = ref.watch(weekOrdersProvider(_weekStart));

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos da Semana')),
      body: Column(
        children: [
          // Week navigator
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevWeek,
                ),
                Text(
                  '${_weekStart.day.toString().padLeft(2, '0')}/'
                  '${_weekStart.month.toString().padLeft(2, '0')} — '
                  '${weekEnd.day.toString().padLeft(2, '0')}/'
                  '${weekEnd.month.toString().padLeft(2, '0')}/'
                  '${weekEnd.year}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextWeek,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: orders.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                      child: Text('Nenhum pedido esta semana.'));
                }
                // Group by delivery date
                final grouped = <String, List<Order>>{};
                for (final o in list) {
                  final key = o.deliveryDate.toIso8601String().substring(0, 10);
                  grouped.putIfAbsent(key, () => []).add(o);
                }
                final sortedKeys = grouped.keys.toList()..sort();

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(weekOrdersProvider(_weekStart)),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: sortedKeys.map((dateStr) {
                      final dayOrders = grouped[dateStr]!;
                      final date = DateTime.parse(dateStr);

                      // Consolidate items
                      final consolidated = <String, _ConsolidatedItem>{};
                      for (final o in dayOrders) {
                        for (final item in o.items) {
                          final key = item.skuId;
                          consolidated.update(
                            key,
                            (e) => _ConsolidatedItem(
                              name: e.name,
                              sku: e.sku,
                              quantity: e.quantity + item.quantity,
                            ),
                            ifAbsent: () => _ConsolidatedItem(
                              name: item.productName ?? '',
                              sku: item.skuName ?? '',
                              quantity: item.quantity,
                            ),
                          );
                        }
                      }

                      return _DaySection(
                        date: date,
                        orderCount: dayOrders.length,
                        items: consolidated.values.toList(),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsolidatedItem {
  const _ConsolidatedItem({
    required this.name,
    required this.sku,
    required this.quantity,
  });
  final String name;
  final String sku;
  final int quantity;
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.date,
    required this.orderCount,
    required this.items,
  });
  final DateTime date;
  final int orderCount;
  final List<_ConsolidatedItem> items;

  @override
  Widget build(BuildContext context) {
    final weekdays = [
      'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
    ];
    final weekday = weekdays[date.weekday - 1];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$weekday, '
                  '${date.day.toString().padLeft(2, '0')}/'
                  '${date.month.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.champagneDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$orderCount pedido${orderCount != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(height: 16),
            Text('Insumos necessários:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey)),
            const SizedBox(height: 6),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.circle,
                        size: 6, color: AppColors.champagne),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.name} — ${item.sku}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '× ${item.quantity}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
