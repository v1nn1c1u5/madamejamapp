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
      // Debug auth context
      final currentUser = _client.auth.currentUser;
      // ignore: avoid_print
      print(
          '[CustomerService] getAllCustomers() user=${currentUser?.email} id=${currentUser?.id}');

      // Primary query with join bringing profile fields
      var query = _client.from('customers').select('''
        id,
        user_profile_id,
        phone,
        birth_date,
        address_line1,
        address_line2,
        city,
        state,
        postal_code,
        delivery_notes,
        is_vip,
        created_at,
        updated_at,
        user_profiles: user_profile_id (
          id,
          email,
          full_name,
          role,
          is_active,
          created_at,
          updated_at
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
      PostgrestList response;
      try {
        response = await query.order(orderBy!, ascending: ascending).range(
            offset ?? 0, limit != null ? (offset ?? 0) + limit - 1 : 999);
      } on PostgrestException catch (e) {
        // Fallback: retry without join if join caused issue
        // (Helps diagnosticar problemas de relationship naming)
        // ignore: avoid_print
        print('[CustomerService] Primary select failed: ${e.message}');
        final fallbackQuery = _client.from('customers').select('*');
        response = await fallbackQuery
            .order(orderBy!, ascending: ascending)
            .range(
                offset ?? 0, limit != null ? (offset ?? 0) + limit - 1 : 999);
      }

      // ignore: avoid_print
      print('[CustomerService] getAllCustomers rows: ${response.length}');

      // If no rows, attempt alternative join syntax (using * and simpler embed)
      if (response.isEmpty) {
        // ignore: avoid_print
        print(
            '[CustomerService] Primary query empty. Trying alternative join syntax...');
        try {
          final alt = await _client
              .from('customers')
              .select('''
            *,
            user_profiles: user_profile_id (id, email, full_name, is_active, created_at)
          ''')
              .order(orderBy, ascending: ascending)
              .range(
                  offset ?? 0, limit != null ? (offset ?? 0) + limit - 1 : 999);
          // ignore: avoid_print
          print('[CustomerService] Alternative join rows: ${alt.length}');
          if (alt.isNotEmpty) {
            response = alt;
          }
        } catch (e) {
          // ignore: avoid_print
          print('[CustomerService] Alternative join failed: $e');
        }
      }

      // If still empty, try simplest select to rule out RLS
      if (response.isEmpty) {
        // ignore: avoid_print
        print('[CustomerService] Still empty. Trying base select (*).');
        try {
          final base = await _client
              .from('customers')
              .select('*')
              .order(orderBy, ascending: ascending)
              .range(
                  offset ?? 0, limit != null ? (offset ?? 0) + limit - 1 : 999);
          // ignore: avoid_print
          print('[CustomerService] Base select rows: ${base.length}');
          if (base.isNotEmpty) {
            response = base;
          }
        } catch (e) {
          // ignore: avoid_print
          print('[CustomerService] Base select failed: $e');
        }
      }

      // Flatten user profile if present
      final customers = List<Map<String, dynamic>>.from(response).map((c) {
        final up = c['user_profiles'];
        if (up is Map<String, dynamic>) {
          c['email'] = up['email'];
          c['full_name'] = up['full_name'];
          c['role'] = up['role'];
          c['is_active'] = up['is_active'];
          c['user_profile_created_at'] = up['created_at'];
          c['user_profile_updated_at'] = up['updated_at'];
        }
        return c;
      }).toList();
      return customers;
    } catch (error) {
      throw Exception('Erro ao buscar clientes: $error');
    }
  }

  // Check if customer exists by email
  Future<bool> customerExistsByEmail(String email) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('id')
          .eq('email', email)
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
        'total_customers': totalData.count,
        'vip_customers': vipData.count,
        'active_customers': activeData.count,
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
