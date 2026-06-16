import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

class DeliveryZone {
  const DeliveryZone({
    required this.id,
    required this.state,
    required this.city,
    required this.neighborhood,
  });

  final String id;
  final String state;
  final String city;
  final String neighborhood;

  factory DeliveryZone.fromJson(Map<String, dynamic> json) => DeliveryZone(
        id: json['id'] as String,
        state: json['state'] as String,
        city: json['city'] as String,
        neighborhood: json['neighborhood'] as String,
      );
}

class BlockedDate {
  const BlockedDate({
    required this.id,
    required this.date,
    this.reason,
  });

  final String id;
  final DateTime date;
  final String? reason;

  factory BlockedDate.fromJson(Map<String, dynamic> json) => BlockedDate(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        reason: json['reason'] as String?,
      );
}

class DeliveryRepository {
  DeliveryRepository(this._client);

  final SupabaseClient _client;

  Future<List<DeliveryZone>> fetchZones() async {
    final data = await _client
        .from('delivery_zones')
        .select()
        .order('state')
        .order('city')
        .order('neighborhood');
    return (data as List)
        .map((e) => DeliveryZone.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addZone({
    required String state,
    required String city,
    required String neighborhood,
  }) async {
    await _client.from('delivery_zones').insert({
      'state': state,
      'city': city,
      'neighborhood': neighborhood,
    });
  }

  Future<void> deleteZone(String id) async {
    await _client.from('delivery_zones').delete().eq('id', id);
  }

  Future<List<BlockedDate>> fetchBlockedDates() async {
    final data = await _client
        .from('blocked_dates')
        .select()
        .order('date');
    return (data as List)
        .map((e) => BlockedDate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addBlockedDate(DateTime date, {String? reason}) async {
    await _client.from('blocked_dates').insert({
      'date': date.toIso8601String().substring(0, 10),
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
  }

  Future<void> removeBlockedDate(String id) async {
    await _client.from('blocked_dates').delete().eq('id', id);
  }

  Future<Set<String>> fetchBlockedDateStrings() async {
    final dates = await fetchBlockedDates();
    return dates
        .map((d) => d.date.toIso8601String().substring(0, 10))
        .toSet();
  }

  Future<bool> validateDeliveryZone({
    required String state,
    required String city,
    required String neighborhood,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'validate-delivery-zone',
        body: {
          'state': state,
          'city': city,
          'neighborhood': neighborhood,
        },
      );
      return response.data['covered'] as bool? ?? false;
    } catch (_) {
      // Fallback: query local when function unavailable
      final data = await _client
          .from('delivery_zones')
          .select('id')
          .ilike('state', state)
          .ilike('city', city)
          .ilike('neighborhood', neighborhood)
          .limit(1);
      return (data as List).isNotEmpty;
    }
  }
}

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository(ref.watch(supabaseClientProvider));
});

final deliveryZonesProvider =
    FutureProvider.autoDispose<List<DeliveryZone>>((ref) {
  return ref.read(deliveryRepositoryProvider).fetchZones();
});

final blockedDatesProvider =
    FutureProvider.autoDispose<List<BlockedDate>>((ref) {
  return ref.read(deliveryRepositoryProvider).fetchBlockedDates();
});

final blockedDateStringsProvider =
    FutureProvider.autoDispose<Set<String>>((ref) {
  return ref.read(deliveryRepositoryProvider).fetchBlockedDateStrings();
});
