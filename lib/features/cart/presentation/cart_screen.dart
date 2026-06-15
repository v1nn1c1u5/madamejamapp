import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../application/cart_providers.dart';
import '../domain/cart_item.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              child: const Text('Limpar'),
            ),
        ],
      ),
      body: items.isEmpty
          ? const _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _CartItemTile(item: items[i]),
                  ),
                ),
                _CartSummary(total: total),
              ],
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 64, color: AppColors.champagne),
            const SizedBox(height: 16),
            Text(
              'Seu carrinho está vazio.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final notifier = ref.read(cartProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: textTheme.titleSmall),
                  Text(item.sku.name,
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.champagneDark)),
                  Text(
                    'R\$ ${item.sku.price.toStringAsFixed(2)} / un.',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            _QuantityStepper(
              quantity: item.quantity,
              min: item.sku.minQuantity,
              onChanged: (q) => notifier.updateQuantity(item.sku.id, q),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 72,
              child: Text(
                'R\$ ${item.subtotal.toStringAsFixed(2)}',
                style: textTheme.titleSmall?.copyWith(
                    color: AppColors.champagneDark,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: Colors.red),
              onPressed: () => notifier.remove(item.sku.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.min,
    required this.onChanged,
  });

  final int quantity;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 22),
          onPressed: quantity > min ? () => onChanged(quantity - 1) : null,
        ),
        Text('$quantity',
            style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 22),
          onPressed: () => onChanged(quantity + 1),
        ),
      ],
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(
                'R\$ ${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.champagneDark,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Ir para o checkout'),
              onPressed: () => context.push(AppRoutes.checkout),
            ),
          ),
        ],
      ),
    );
  }
}
