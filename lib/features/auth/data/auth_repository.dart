import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

/// Erro de autenticação já traduzido para PT-BR, pronto para exibir ao usuário.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Acesso a autenticação (Supabase Auth) e ao vínculo com `customers`.
///
/// O registro em `public.customers` é criado por trigger no banco a partir do
/// metadata do usuário (ver migration 0002) — evita problemas de RLS/timing
/// quando há confirmação de e-mail pendente.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Cadastra um novo cliente. `name`/`phone` vão no metadata e o trigger
  /// cria o registro em `customers`. Retorna `true` se já há sessão ativa
  /// (confirmação de e-mail desabilitada), `false` se confirmação é exigida.
  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim(), 'phone': phone.trim()},
      );
      return res.session != null;
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Traduz mensagens do Supabase para PT-BR sem revelar qual campo falhou no
  /// login (requisito da Story 1.3).
  String _translate(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('already registered') ||
        msg.contains('already been registered') ||
        msg.contains('user already exists')) {
      return 'Este e-mail já está em uso.';
    }
    if (msg.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Muitas tentativas. Tente novamente em instantes.';
    }
    return 'Não foi possível concluir. Tente novamente.';
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});
