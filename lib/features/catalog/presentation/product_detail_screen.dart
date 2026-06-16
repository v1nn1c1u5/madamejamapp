import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../cart/application/cart_providers.dart';
import '../../cart/domain/cart_item.dart';
import '../application/catalog_providers.dart';
import '../data/product_repository.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Produto')),
      body: product.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (p) => _ProductDetailBody(product: p),
      ),
    );
  }
}

class _ProductDetailBody extends ConsumerStatefulWidget {
  const _ProductDetailBody({required this.product});
  final Product product;

  @override
  ConsumerState<_ProductDetailBody> createState() =>
      _ProductDetailBodyState();
}

class _ProductDetailBodyState
    extends ConsumerState<_ProductDetailBody> {
  int _imageIndex = 0;
  Sku? _selectedSku;
  int _quantity = 1;

  Product get p => widget.product;

  @override
  void initState() {
    super.initState();
    if (p.activeSkus.isNotEmpty) {
      _selectedSku = p.activeSkus.first;
      _quantity = p.activeSkus.first.minQuantity;
    }
  }

  void _selectSku(Sku sku) {
    setState(() {
      _selectedSku = sku;
      _quantity = sku.minQuantity;
    });
  }

  void _addToCart() {
    final sku = _selectedSku;
    if (sku == null) return;

    final messenger = ScaffoldMessenger.of(context);

    if (_quantity < sku.minQuantity) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(
              'Quantidade mínima para "${sku.name}" é ${sku.minQuantity}.'),
        ));
      return;
    }

    ref.read(cartProvider.notifier).add(CartItem(
          productId: p.id,
          productName: p.name,
          productMinQuantity: p.minQuantity,
          sku: sku,
          quantity: _quantity,
        ));

    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text('${p.name} adicionado ao carrinho.'),
        action: SnackBarAction(
          label: 'Ver carrinho',
          onPressed: () => context.push(AppRoutes.cart),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Imagens ──────────────────────────────────────────────────
          SizedBox(
            height: 280,
            child: p.images.isEmpty
                ? Container(
                    color: AppColors.champagneLight,
                    child: const Center(
                      child: Icon(Icons.bakery_dining_outlined,
                          size: 80, color: AppColors.champagne),
                    ),
                  )
                : Stack(
                    children: [
                      PageView.builder(
                        itemCount: p.images.length,
                        onPageChanged: (i) =>
                            setState(() => _imageIndex = i),
                        itemBuilder: (context, i) => CachedNetworkImage(
                          imageUrl: p.images[i].storageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                              color: AppColors.champagneLight),
                          errorWidget: (_, _, _) => Container(
                            color: AppColors.champagneLight,
                            child: const Center(
                              child: Icon(Icons.bakery_dining_outlined,
                                  size: 60, color: AppColors.champagne),
                            ),
                          ),
                        ),
                      ),
                      if (p.images.length > 1)
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              p.images.length,
                              (i) => AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 3),
                                width: i == _imageIndex ? 10 : 6,
                                height: i == _imageIndex ? 10 : 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == _imageIndex
                                      ? AppColors.champagneDark
                                      : Colors.white
                                          .withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: textTheme.headlineSmall),
                if (p.description != null &&
                    p.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(p.description!, style: textTheme.bodyMedium),
                ],

                // ── Variantes ─────────────────────────────────────────
                if (p.activeSkus.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Variantes',
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.activeSkus.map((sku) {
                      final selected = _selectedSku?.id == sku.id;
                      return ChoiceChip(
                        label: Text(
                          '${sku.name}\nR\$ ${sku.price.toStringAsFixed(2)}'
                          '\nmín. ${sku.minQuantity}',
                        ),
                        selected: selected,
                        onSelected: (_) => _selectSku(sku),
                        selectedColor:
                            AppColors.champagneDark.withValues(alpha: 0.15),
                      );
                    }).toList(),
                  ),

                  // ── Quantidade ──────────────────────────────────────
                  if (_selectedSku != null) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text('Quantidade:',
                            style: textTheme.titleSmall),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _quantity >
                                  (_selectedSku?.minQuantity ?? 1)
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Text('$_quantity',
                            style: textTheme.titleMedium),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () =>
                              setState(() => _quantity++),
                        ),
                      ],
                    ),
                    if (_selectedSku != null) ...[
                      Text(
                        'Mín. por sabor: ${_selectedSku!.minQuantity} · '
                        'Subtotal: R\$ ${(_selectedSku!.price * _quantity).toStringAsFixed(2)}',
                        style: textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                      if (p.minQuantity > 1)
                        Text(
                          'Mínimo por pedido: ${p.minQuantity} un. (total do produto)',
                          style: textTheme.bodySmall?.copyWith(
                              color: AppColors.champagneDark,
                              fontWeight: FontWeight.w600),
                        ),
                    ],
                  ],

                  // ── Botão ────────────────────────────────────────────
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Adicionar ao carrinho'),
                      onPressed:
                          _selectedSku != null ? _addToCart : null,
                    ),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      'Nenhuma variante disponível no momento.',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
