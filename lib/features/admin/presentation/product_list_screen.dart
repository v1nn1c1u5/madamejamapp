import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/data/product_repository.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(adminProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
        onPressed: () =>
            context.push(AppRoutes.adminProductNew),
      ),
      body: products.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text(
                    'Nenhum produto cadastrado.\nToque em + para começar.',
                    textAlign: TextAlign.center),
              )
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(adminProductsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 8),
                  itemBuilder: (ctx, i) =>
                      _ProductTile(product: list[i]),
                ),
              ),
      ),
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        title: Text(product.name, style: textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.activeSkus.isNotEmpty)
              Text(
                'A partir de R\$ '
                '${product.priceFrom.toStringAsFixed(2)}',
                style: textTheme.bodySmall?.copyWith(
                    color: AppColors.champagneDark),
              ),
            Text(
              '${product.activeSkus.length} variante'
              '${product.activeSkus.length != 1 ? 's' : ''}'
              ' ativa'
              '${product.activeSkus.length != 1 ? 's' : ''}',
              style: textTheme.bodySmall,
            ),
          ],
        ),
        leading: _ActiveBadge(active: product.active),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(
              value: product.active,
              onChanged: (v) => _toggleActive(context, ref, v),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context
                  .push(AppRoutes.adminProductEditPath(product.id)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleActive(
      BuildContext context, WidgetRef ref, bool active) async {
    try {
      await ref
          .read(productRepositoryProvider)
          .setActive(product.id, active: active);
      ref.invalidate(adminProductsProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: $e')),
      );
    }
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.green : Colors.grey,
      ),
    );
  }
}
