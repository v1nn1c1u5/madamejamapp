import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/domain/order.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<Order?>(
      stream: ref.read(orderRepositoryProvider).watchOrder(orderId),
      builder: (context, snap) {
        final order = snap.data;
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 80, color: AppColors.champagneDark),
                    const SizedBox(height: 24),
                    Text(
                      'Pedido confirmado!',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (order != null) ...[
                      Text(
                        'Entrega em '
                        '${order.deliveryDate.day.toString().padLeft(2, '0')}/'
                        '${order.deliveryDate.month.toString().padLeft(2, '0')}/'
                        '${order.deliveryDate.year}',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.deliveryAddress.formatted,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Ver meus pedidos'),
                      onPressed: () => context.go(AppRoutes.myOrders),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.catalog),
                      child: const Text('Voltar ao catálogo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
