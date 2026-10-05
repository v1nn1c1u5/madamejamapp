import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/address.dart';

class AddressRepository {
  AddressRepository(this._client);

  final SupabaseClient _client;

  Future<String> _customerId() async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from('customers')
        .select('id')
        .eq('user_id', userId)
        .single();
    return data['id'] as String;
  }

  Future<List<Address>> fetchMyAddresses() async {
    final data = await _client
        .from('addresses')
        .select()
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Address.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Address> addAddress({
    required String label,
    required String state,
    required String city,
    required String neighborhood,
    required String street,
    required String number,
    String? complement,
    bool isDefault = false,
  }) async {
    final customerId = await _customerId();
    final data = await _client
        .from('addresses')
        .insert({
          'customer_id': customerId,
          'label': label,
          'state': state,
          'city': city,
          'neighborhood': neighborhood,
          'street': street,
          'number': number,
          if (complement != null && complement.isNotEmpty)
            'complement': complement,
          'is_default': isDefault,
        })
        .select()
        .single();
    return Address.fromJson(data);
  }

  Future<void> updateAddress(Address address) async {
    await _client.from('addresses').update({
      'label': address.label,
      'state': address.state,
      'city': address.city,
      'neighborhood': address.neighborhood,
      'street': address.street,
      'number': address.number,
      'complement': address.complement,
      'is_default': address.isDefault,
    }).eq('id', address.id);
  }

  Future<void> setDefault(String id) async {
    await _client.from('addresses').update({'is_default': true}).eq('id', id);
  }

  Future<void> deleteAddress(String id) async {
    await _client.from('addresses').delete().eq('id', id);
  }
}

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ref.watch(supabaseClientProvider));
});

final myAddressesProvider = FutureProvider.autoDispose<List<Address>>((ref) {
  return ref.read(addressRepositoryProvider).fetchMyAddresses();
});
