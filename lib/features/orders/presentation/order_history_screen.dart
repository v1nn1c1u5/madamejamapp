import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../application/order_providers.dart';
import '../domain/order.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pedidos')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) => list.isEmpty
            ? const _EmptyOrders()
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(myOrdersProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _OrderTile(order: list[i]),
                ),
              ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 64, color: AppColors.champagne),
            const SizedBox(height: 16),
            Text(
              'Você ainda não fez nenhum pedido.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label =
        Order.productionStatusLabels[order.productionStatus] ??
            order.productionStatus;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        title: Text(
          '${order.deliveryDate.day.toString().padLeft(2, '0')}/'
          '${order.deliveryDate.month.toString().padLeft(2, '0')}/'
          '${order.deliveryDate.year}',
          style: textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('R\$ ${order.total.toStringAsFixed(2)}',
                style: textTheme.bodySmall?.copyWith(
                    color: AppColors.champagneDark)),
            Text(label, style: textTheme.bodySmall),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            context.push(AppRoutes.orderTrackingPath(order.id)),
      ),
    );
  }
}
