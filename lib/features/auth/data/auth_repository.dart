import 'package:flutter/foundation.dart';
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

      if (res.user == null) {
        throw const AuthFailure(
          'Não foi possível criar sua conta. Tente novamente.',
        );
      }

      // Supabase pode responder 200 sem erro quando o e-mail já existe.
      final identities = res.user!.identities;
      if (identities == null || identities.isEmpty) {
        throw const AuthFailure('Este e-mail já está em uso.');
      }

      return res.session != null;
    } on AuthException catch (e, stack) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('signUp AuthException: $e\n$stack');
      }
      throw AuthFailure(_translateSignUp(e));
    } on AuthFailure {
      rethrow;
    } catch (e, stack) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('signUp unexpected: $e\n$stack');
      }
      throw AuthFailure(_translateUnexpected(e));
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
    } catch (e) {
      throw AuthFailure(_translateUnexpected(e));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    } catch (e) {
      throw AuthFailure(_translateUnexpected(e));
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Traduz erros de cadastro com mensagens mais específicas para o usuário.
  String _translateSignUp(AuthException e) {
    switch (e.code) {
      case 'email_exists':
      case 'user_already_exists':
      case 'identity_already_exists':
        return 'Este e-mail já está em uso.';
      case 'weak_password':
        return 'A senha é muito fraca. Use ao menos 6 caracteres.';
      case 'signup_disabled':
      case 'email_provider_disabled':
        return 'Cadastro temporariamente indisponível. Tente mais tarde.';
      case 'invalid_jwt':
      case 'bad_jwt':
        return 'Chave de API inválida. No dart_define.json use a chave '
            '"anon public" ou "publishable" do Supabase (Settings → API).';
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      case 'validation_failed':
        return 'Dados inválidos. Verifique e-mail, senha e telefone.';
      case 'unexpected_failure':
        return 'Erro no servidor ao criar a conta. '
            'Verifique os logs do Supabase (Authentication → Logs).';
      case 'anonymous_provider_disabled':
        return 'Falha ao enviar e-mail/senha para o cadastro. '
            'Tente fechar e abrir o app novamente.';
    }

    final msg = e.message.toLowerCase();

    if (msg.contains('already registered') ||
        msg.contains('already been registered') ||
        msg.contains('user already exists')) {
      return 'Este e-mail já está em uso.';
    }
    if (msg.contains('password') &&
        (msg.contains('at least') ||
            msg.contains('least 6') ||
            msg.contains('too short') ||
            msg.contains('weak'))) {
      return 'A senha deve ter ao menos 6 caracteres.';
    }
    if (msg.contains('invalid') && msg.contains('email')) {
      return 'E-mail inválido. Verifique o endereço informado.';
    }
    if (msg.contains('signup') && msg.contains('disabled')) {
      return 'Cadastro temporariamente indisponível. Tente mais tarde.';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
    }
    if (msg.contains('confirmation email') ||
        msg.contains('sending confirmation')) {
      return 'Não foi possível enviar o e-mail de confirmação. '
          'Verifique o endereço ou tente outro e-mail.';
    }
    if (msg.contains('database error') || msg.contains('saving new user')) {
      return 'Erro ao salvar sua conta no servidor. '
          'Verifique se o banco está configurado corretamente.';
    }

    final detail = e.message.trim();
    if (detail.isNotEmpty) {
      return 'Não foi possível criar sua conta: $detail';
    }
    return 'Não foi possível criar sua conta. Tente novamente.';
  }

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

  String _translateUnexpected(Object error) {
    if (error is AuthException) {
      return _translateSignUp(error);
    }

    final msg = error.toString().toLowerCase();
    if (msg.contains('certificate_verify_failed') ||
        msg.contains('handshakeexception') ||
        msg.contains('self signed certificate')) {
      return 'Falha na verificação do certificado SSL. '
          'Desative inspeção HTTPS do antivírus/proxy ou use outra rede '
          '(ex.: celular como hotspot).';
    }
    if (msg.contains('socket') ||
        msg.contains('network') ||
        msg.contains('connection') ||
        msg.contains('failed host lookup') ||
        msg.contains('timed out')) {
      return 'Sem conexão com o servidor. Verifique sua internet e tente novamente.';
    }

    final detail = error.toString().trim();
    if (detail.isNotEmpty && detail != 'Exception') {
      return 'Não foi possível criar sua conta: $detail';
    }
    return 'Não foi possível criar sua conta. Tente novamente.';
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});
