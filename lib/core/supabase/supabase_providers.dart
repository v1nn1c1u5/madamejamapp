import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Acesso ao cliente Supabase já inicializado em `main()`.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Stream do estado de autenticação (login, logout, refresh de token).
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Sessão atual (null quando não autenticado).
final sessionProvider = Provider<Session?>((ref) {
  // Reage às mudanças de auth e relê a sessão corrente.
  ref.watch(authStateProvider);
  return ref.watch(supabaseClientProvider).auth.currentSession;
});

/// Indica se o usuário autenticado tem papel de admin.
///
/// O papel vive em `app_metadata.role` no JWT — definido no Supabase e não
/// alterável pelo cliente (NFR6).
final isAdminProvider = Provider<bool>((ref) {
  final session = ref.watch(sessionProvider);
  final role = session?.user.appMetadata['role'];
  return role == 'admin';
});
