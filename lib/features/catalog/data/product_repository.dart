import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

class ProductImage {
  const ProductImage({
    required this.id,
    required this.productId,
    required this.storageUrl,
    required this.position,
  });

  final String id;
  final String productId;
  final String storageUrl;
  final int position;

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
        id: json['id'] as String,
        productId: json['product_id'] as String,
        storageUrl: json['storage_url'] as String,
        position: json['position'] as int,
      );
}

class Sku {
  const Sku({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.minQuantity,
    required this.active,
  });

  final String id;
  final String productId;
  final String name;
  final double price;
  final int minQuantity;
  final bool active;

  factory Sku.fromJson(Map<String, dynamic> json) => Sku(
        id: json['id'] as String,
        productId: json['product_id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        minQuantity: json['min_quantity'] as int,
        active: json['active'] as bool,
      );
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.active,
    required this.minQuantity,
    required this.createdAt,
    required this.skus,
    required this.images,
  });

  final String id;
  final String name;
  final String? description;
  final bool active;
  /// Quantidade mínima total do produto por pedido (soma de todos os SKUs).
  final int minQuantity;
  final DateTime createdAt;
  final List<Sku> skus;
  final List<ProductImage> images;

  String? get coverUrl => images.isEmpty ? null : images.first.storageUrl;

  double get priceFrom {
    final active = skus.where((s) => s.active).toList();
    if (active.isEmpty) return 0;
    return active.map((s) => s.price).reduce((a, b) => a < b ? a : b);
  }

  List<Sku> get activeSkus => skus.where((s) => s.active).toList();

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages =
        (json['product_images'] as List<dynamic>? ?? [])
            .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      active: json['active'] as bool,
      minQuantity: (json['min_quantity'] as int?) ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      skus: (json['skus'] as List<dynamic>? ?? [])
          .map((e) => Sku.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: rawImages,
    );
  }
}

class ProductRepository {
  ProductRepository(this._client);

  final SupabaseClient _client;
  static const _bucket = 'products';

  // ─── Catálogo (cliente) ───────────────────────────────────────────────────

  Future<List<Product>> fetchActiveProducts({String? query}) async {
    if (query != null && query.isNotEmpty) {
      final data = await _client
          .from('products')
          .select('*, skus(*), product_images(*)')
          .eq('active', true)
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);
      return _mapList(data);
    }
    final data = await _client
        .from('products')
        .select('*, skus(*), product_images(*)')
        .eq('active', true)
        .order('created_at', ascending: false);
    return _mapList(data);
  }

  Future<Product> fetchProductDetail(String id) async {
    final data = await _client
        .from('products')
        .select('*, skus(*), product_images(*)')
        .eq('id', id)
        .single();
    return Product.fromJson(data);
  }

  // ─── Admin ────────────────────────────────────────────────────────────────

  Future<List<Product>> fetchAllProducts() async {
    final data = await _client
        .from('products')
        .select('*, skus(*), product_images(*)')
        .order('created_at', ascending: false);
    return _mapList(data);
  }

  Future<Product> createProduct(
    String name,
    String? description, {
    int minQuantity = 1,
  }) async {
    final data = await _client
        .from('products')
        .insert({
          'name': name,
          'description': description,
          'min_quantity': minQuantity,
        })
        .select('*, skus(*), product_images(*)')
        .single();
    return Product.fromJson(data);
  }

  Future<void> updateProduct(
    String id, {
    required String name,
    String? description,
    int minQuantity = 1,
  }) async {
    await _client.from('products').update({
      'name': name,
      'description': description,
      'min_quantity': minQuantity,
    }).eq('id', id);
  }

  Future<void> setActive(String id, {required bool active}) async {
    await _client
        .from('products')
        .update({'active': active})
        .eq('id', id);
  }

  // ─── SKUs ─────────────────────────────────────────────────────────────────

  Future<void> upsertSku({
    String? id,
    required String productId,
    required String name,
    required double price,
    required int minQuantity,
  }) async {
    final payload = {
      'product_id': productId,
      'name': name,
      'price': price,
      'min_quantity': minQuantity,
    };
    if (id != null) {
      await _client.from('skus').update(payload).eq('id', id);
    } else {
      await _client.from('skus').insert(payload);
    }
  }

  Future<void> deleteSku(String skuId) async {
    await _client.from('skus').delete().eq('id', skuId);
  }

  // ─── Imagens ──────────────────────────────────────────────────────────────

  Future<void> uploadImage({
    required String productId,
    required String filename,
    required Uint8List bytes,
    required String mimeType,
    required int position,
  }) async {
    final path =
        '$productId/${DateTime.now().millisecondsSinceEpoch}_$filename';
    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );
    final url = _client.storage.from(_bucket).getPublicUrl(path);
    await _client.from('product_images').insert({
      'product_id': productId,
      'storage_url': url,
      'position': position,
    });
  }

  Future<void> deleteImage(String imageId, String storageUrl) async {
    final uri = Uri.parse(storageUrl);
    final segments = uri.pathSegments;
    final idx = segments.indexOf(_bucket);
    if (idx >= 0 && idx < segments.length - 1) {
      final path = segments.sublist(idx + 1).join('/');
      await _client.storage.from(_bucket).remove([path]);
    }
    await _client.from('product_images').delete().eq('id', imageId);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  List<Product> _mapList(List<dynamic> data) =>
      data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(supabaseClientProvider));
});
