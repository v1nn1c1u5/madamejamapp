import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Sign up new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'customer',
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );
      return response;
    } catch (error) {
      throw Exception('Erro no cadastro: $error');
    }
  }

  // Sign in existing user
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Erro no login: $error');
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Erro no logout: $error');
    }
  }

  // Get user profile with role
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (!isSignedIn) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Erro ao buscar perfil: $error');
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    try {
      if (!isSignedIn) return false;

      final profile = await getUserProfile();
      return profile?['role'] == 'admin';
    } catch (error) {
      return false;
    }
  }

  // Check if user is customer
  Future<bool> isCustomer() async {
    try {
      if (!isSignedIn) return false;

      final profile = await getUserProfile();
      return profile?['role'] == 'customer';
    } catch (error) {
      return false;
    }
  }

  // Get user role
  Future<String?> getUserRole() async {
    try {
      if (!isSignedIn) return null;

      final profile = await getUserProfile();
      return profile?['role'];
    } catch (error) {
      return null;
    }
  }

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Erro ao recuperar senha: $error');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? fullName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (!isSignedIn) throw Exception('Usuário não está logado');

      Map<String, dynamic> updates = {};

      if (fullName != null) {
        updates['full_name'] = fullName;
      }

      if (additionalData != null) {
        updates.addAll(additionalData);
      }

      if (updates.isNotEmpty) {
        await _client
            .from('user_profiles')
            .update(updates)
            .eq('id', currentUser!.id);
      }
    } catch (error) {
      throw Exception('Erro ao atualizar perfil: $error');
    }
  }
}
