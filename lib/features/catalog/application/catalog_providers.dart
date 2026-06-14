import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_repository.dart';

/// Termo digitado na barra de busca do catálogo.
final catalogSearchProvider = StateProvider.autoDispose<String>((ref) => '');

/// Lista de produtos ativos, refiltrada sempre que a busca muda.
final activeProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) {
  final query = ref.watch(catalogSearchProvider);
  return ref
      .read(productRepositoryProvider)
      .fetchActiveProducts(query: query.isEmpty ? null : query);
});

/// Detalhe de um produto pelo id (client + admin).
final productDetailProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) {
  return ref.read(productRepositoryProvider).fetchProductDetail(id);
});

/// Lista completa de produtos para o admin (ativos + inativos).
final adminProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.read(productRepositoryProvider).fetchAllProducts();
});
