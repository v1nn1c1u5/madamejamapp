import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../orders/application/order_providers.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/domain/order.dart';

class AdminOrderDetailScreen extends ConsumerWidget {
  const AdminOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do Pedido')),
      body: order.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (o) => _OrderDetailBody(order: o),
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  const _OrderDetailBody({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final statusLabel =
        Order.productionStatusLabels[order.productionStatus] ??
            order.productionStatus;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status de produção ────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status de produção',
                        style: textTheme.bodySmall
                            ?.copyWith(color: Colors.grey)),
                    Text(statusLabel,
                        style: textTheme.titleMedium?.copyWith(
                            color: AppColors.champagneDark,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (order.nextStatus != null)
                FilledButton(
                  onPressed: () =>
                      _advanceStatus(context, ref, order),
                  child: Text(
                    'Avançar para\n'
                    '${Order.productionStatusLabels[order.nextStatus!]}',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
          const Divider(height: 28),

          // ── Cliente ───────────────────────────────────────────────
          Text('Cliente', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _InfoRow(label: 'Nome', value: order.customerName ?? '—'),
          _InfoRow(label: 'Telefone', value: order.customerPhone ?? '—'),
          const SizedBox(height: 20),

          // ── Entrega ───────────────────────────────────────────────
          Text('Entrega', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Data',
            value:
                '${order.deliveryDate.day.toString().padLeft(2, '0')}/'
                '${order.deliveryDate.month.toString().padLeft(2, '0')}/'
                '${order.deliveryDate.year}',
          ),
          _InfoRow(
              label: 'Endereço',
              value: order.deliveryAddress.formatted),
          const SizedBox(height: 20),

          // ── Itens ─────────────────────────────────────────────────
          Text('Itens', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName ?? ''} — '
                      '${item.skuName ?? ''} × ${item.quantity}',
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
              Text('Total', style: textTheme.titleMedium),
              Text(
                'R\$ ${order.total.toStringAsFixed(2)}',
                style: textTheme.titleMedium?.copyWith(
                    color: AppColors.champagneDark,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Pagamento',
            value: order.paymentStatus == 'paid'
                ? 'Aprovado'
                : order.paymentStatus,
          ),
        ],
      ),
    );
  }

  Future<void> _advanceStatus(
      BuildContext context, WidgetRef ref, Order order) async {
    final next = order.nextStatus;
    if (next == null) return;

    final nextLabel = Order.productionStatusLabels[next] ?? next;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Avançar status'),
        content: Text('Mover para "$nextLabel"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;
    try {
      await ref
          .read(orderRepositoryProvider)
          .updateProductionStatus(order.id, next);
      ref.invalidate(orderDetailProvider(order.id));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
