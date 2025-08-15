import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      if (kDebugMode) {
        print('⚠️  SUPABASE_URL or SUPABASE_ANON_KEY is empty');
        print(
            '   Please run with: flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key');
      }
      throw Exception(
          'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.');
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );

      if (kDebugMode) {
        print('✅ Supabase initialized successfully');
        print('   URL: ${supabaseUrl.substring(0, 30)}...');
        print('   Key: ${supabaseAnonKey.substring(0, 20)}...');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Supabase initialization error: $e');
      }
      rethrow;
    }
  }

  // Get Supabase client with connection validation
  SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get Supabase client: $e');
      }
      throw Exception(
          'Supabase client not initialized. Call SupabaseService.initialize() first.');
    }
  }

  // Test database connection
  Future<bool> testConnection() async {
    try {
      final response = await client.from('user_profiles').select('id').limit(1);
      if (kDebugMode) {
        print('✅ Database connection test passed');
      }
      return true;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Database connection test failed: $error');
      }
      return false;
    }
  }

  // Get current user
  User? get currentUser => client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Sign out
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      if (kDebugMode) {
        print('✅ User signed out successfully');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Sign out error: $error');
      }
      throw Exception('Sign out failed: $error');
    }
  }
}
