import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

/// Controla as ações de autenticação e expõe o estado de carregamento/erro
/// para a UI dos formulários.
class AuthController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Retorna `true` se já autenticou com sessão (vai para a home via router),
  /// `false` se o cadastro exige confirmação de e-mail.
  Future<bool?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => _repo.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
      ),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    return result.valueOrNull;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signIn(email: email, password: password),
    );
    return !state.hasError;
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.sendPasswordReset(email));
    return !state.hasError;
  }
}

final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>(AuthController.new);
