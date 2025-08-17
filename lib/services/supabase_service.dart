import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL',
      defaultValue: 'https://xxguipvbmruxgkraqkbf.supabase.co');
  static const String supabaseAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4Z3VpcHZibXJ1eGdrcmFxa2JmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxODM2NzUsImV4cCI6MjA3MDc1OTY3NX0.7CuAKmOiX4FNPbt-upOW7fWyEkFtW2y1XRnFuN9Rc4w');

  // Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Get Supabase client
  SupabaseClient get client => Supabase.instance.client;
}
