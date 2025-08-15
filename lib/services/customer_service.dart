import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class CustomerService {
  static CustomerService? _instance;
  static CustomerService get instance => _instance ??= CustomerService._();

  CustomerService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Create a new customer profile
  Future<Map<String, dynamic>> createCustomer({
    required String userProfileId,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? deliveryNotes,
    DateTime? birthDate,
    bool isVip = false,
  }) async {
    try {
      final customerData = {
        'user_profile_id': userProfileId,
        if (phone != null) 'phone': phone,
        if (addressLine1 != null) 'address_line1': addressLine1,
        if (addressLine2 != null) 'address_line2': addressLine2,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (postalCode != null) 'postal_code': postalCode,
        if (deliveryNotes != null) 'delivery_notes': deliveryNotes,
        if (birthDate != null)
          'birth_date': birthDate.toIso8601String().split('T')[0],
        'is_vip': isVip,
      };

      final response = await _client
          .from('customers')
          .insert(customerData)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Erro ao criar perfil do cliente: $error');
    }
  }

  // Get customer by user profile ID
  Future<Map<String, dynamic>?> getCustomerByUserProfileId(
      String userProfileId) async {
    try {
      final response = await _client
          .from('customers')
          .select()
          .eq('user_profile_id', userProfileId)
          .maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Erro ao buscar cliente: $error');
    }
  }

  // Get customer by ID
  Future<Map<String, dynamic>?> getCustomerById(String customerId) async {
    try {
      final response = await _client
          .from('customers')
          .select()
          .eq('id', customerId)
          .maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Erro ao buscar cliente: $error');
    }
  }

  // Update customer profile
  Future<Map<String, dynamic>> updateCustomer({
    required String customerId,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? deliveryNotes,
    DateTime? birthDate,
    bool? isVip,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (phone != null) updateData['phone'] = phone;
      if (addressLine1 != null) updateData['address_line1'] = addressLine1;
      if (addressLine2 != null) updateData['address_line2'] = addressLine2;
      if (city != null) updateData['city'] = city;
      if (state != null) updateData['state'] = state;
      if (postalCode != null) updateData['postal_code'] = postalCode;
      if (deliveryNotes != null) updateData['delivery_notes'] = deliveryNotes;
      if (birthDate != null)
        updateData['birth_date'] = birthDate.toIso8601String().split('T')[0];
      if (isVip != null) updateData['is_vip'] = isVip;

      if (updateData.isEmpty) {
        throw Exception('Nenhum dado para atualizar');
      }

      final response = await _client
          .from('customers')
          .update(updateData)
          .eq('id', customerId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Erro ao atualizar cliente: $error');
    }
  }

  // Get all customers (admin only)
  Future<List<Map<String, dynamic>>> getAllCustomers({
    int? limit,
    int? offset,
    String? searchTerm,
    bool? isVip,
    String? orderBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      var query = _client.from('customers').select('''
            *,
            user_profiles!customers_user_profile_id_fkey (
              id,
              email,
              full_name,
              is_active,
              created_at
            )
          ''');

      // Apply filters
      if (isVip != null) {
        query = query.eq('is_vip', isVip);
      }

      // Apply search
      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or(
            'phone.ilike.%$searchTerm%,city.ilike.%$searchTerm%,user_profiles.full_name.ilike.%$searchTerm%,user_profiles.email.ilike.%$searchTerm%');
      }

      // Apply ordering and limiting
      final response = await query
          .order(orderBy!, ascending: ascending)
          .range(offset ?? 0, limit != null ? (offset ?? 0) + limit - 1 : 999);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Erro ao buscar clientes: $error');
    }
  }

  // Check if customer exists by email
  Future<bool> customerExistsByEmail(String email) async {
    try {
      final response = await _client
          .from('customers')
          .select('id, user_profiles!customers_user_profile_id_fkey(email)')
          .eq('user_profiles.email', email)
          .maybeSingle();

      return response != null;
    } catch (error) {
      return false;
    }
  }

  // Check if customer exists by phone
  Future<bool> customerExistsByPhone(String phone) async {
    try {
      final response = await _client
          .from('customers')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();

      return response != null;
    } catch (error) {
      return false;
    }
  }

  // Get customer statistics
  Future<Map<String, dynamic>> getCustomerStatistics() async {
    try {
      final totalData = await _client.from('customers').select('id').count();
      final vipData = await _client
          .from('customers')
          .select('id')
          .eq('is_vip', true)
          .count();
      final activeData = await _client.from('customers').select('''
        id,
        user_profiles!customers_user_profile_id_fkey(is_active)
      ''').eq('user_profiles.is_active', true).count();

      return {
        'total_customers': totalData.count ?? 0,
        'vip_customers': vipData.count ?? 0,
        'active_customers': activeData.count ?? 0,
      };
    } catch (error) {
      throw Exception('Erro ao buscar estatísticas: $error');
    }
  }

  // Delete customer (soft delete by deactivating user profile)
  Future<void> deleteCustomer(String customerId) async {
    try {
      // Get customer to find user_profile_id
      final customer = await _client
          .from('customers')
          .select('user_profile_id')
          .eq('id', customerId)
          .single();

      // Deactivate user profile instead of deleting
      await _client
          .from('user_profiles')
          .update({'is_active': false}).eq('id', customer['user_profile_id']);
    } catch (error) {
      throw Exception('Erro ao desativar cliente: $error');
    }
  }
}
