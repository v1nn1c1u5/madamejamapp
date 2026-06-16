import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../application/order_providers.dart';
import '../domain/order.dart';

class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderTrackingProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Acompanhar Pedido')),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                const Text('Não foi possível carregar o pedido.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(orderTrackingProvider(orderId)),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Pedido não encontrado.'));
          }
          return _TrackingBody(order: order);
        },
      ),
    );
  }
}

class _TrackingBody extends StatelessWidget {
  const _TrackingBody({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentIdx =
        Order.productionStatuses.indexOf(order.productionStatus);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Entrega em',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey)),
          Text(
            '${order.deliveryDate.day.toString().padLeft(2, '0')}/'
            '${order.deliveryDate.month.toString().padLeft(2, '0')}/'
            '${order.deliveryDate.year}',
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(order.deliveryAddress.formatted,
              style: textTheme.bodyMedium),
          const SizedBox(height: 28),

          Text('Status de produção', style: textTheme.titleMedium),
          const SizedBox(height: 16),

          // Timeline
          ...Order.productionStatuses.asMap().entries.map((entry) {
            final idx = entry.key;
            final status = entry.value;
            final label = Order.productionStatusLabels[status] ?? status;
            final isDone = idx <= currentIdx;
            final isCurrent = idx == currentIdx;

            return _TimelineStep(
              label: label,
              isDone: isDone,
              isCurrent: isCurrent,
              isLast: idx == Order.productionStatuses.length - 1,
            );
          }),

          const SizedBox(height: 28),
          Text('Itens do pedido', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName ?? ''} — ${item.skuName ?? ''} × ${item.quantity}',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    'R\$ ${item.subtotal.toStringAsFixed(2)}',
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: textTheme.titleSmall),
              Text(
                'R\$ ${order.total.toStringAsFixed(2)}',
                style: textTheme.titleSmall?.copyWith(
                    color: AppColors.champagneDark,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  final String label;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = isDone ? AppColors.champagneDark : Colors.grey.shade300;
    final textColor = isCurrent ? AppColors.champagneDark : Colors.grey;

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppColors.champagneDark : Colors.white,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 16),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: isCurrent ? FontWeight.bold : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
