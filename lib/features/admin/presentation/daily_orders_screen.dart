import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../orders/application/order_providers.dart';
import '../../orders/domain/order.dart';

class DailyOrdersScreen extends ConsumerStatefulWidget {
  const DailyOrdersScreen({super.key});

  @override
  ConsumerState<DailyOrdersScreen> createState() =>
      _DailyOrdersScreenState();
}

class _DailyOrdersScreenState
    extends ConsumerState<DailyOrdersScreen> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDay = DateTime(
          picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(dayOrdersProvider(_selectedDay));

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos do Dia')),
      body: Column(
        children: [
          // Day picker
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.today_outlined,
                    color: AppColors.champagneDark),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _pickDay,
                  child: Text(
                    '${_selectedDay.day.toString().padLeft(2, '0')}/'
                    '${_selectedDay.month.toString().padLeft(2, '0')}/'
                    '${_selectedDay.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.champagneDark,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.edit_outlined, size: 14, color: Colors.grey),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: orders.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (list) => list.isEmpty
                  ? const Center(
                      child: Text('Nenhum pedido para este dia.'))
                  : RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(dayOrdersProvider(_selectedDay)),
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: list.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) =>
                            _OrderCard(order: list[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusLabel =
        Order.productionStatusLabels[order.productionStatus] ??
            order.productionStatus;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        title: Text(
          order.customerName ?? 'Cliente',
          style: textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.deliveryAddress.neighborhood,
                style: textTheme.bodySmall),
            Text(statusLabel,
                style: textTheme.bodySmall?.copyWith(
                    color: AppColors.champagneDark)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('R\$ ${order.total.toStringAsFixed(2)}',
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context
            .push(AppRoutes.adminOrderDetailPath(order.id)),
      ),
    );
  }
}
