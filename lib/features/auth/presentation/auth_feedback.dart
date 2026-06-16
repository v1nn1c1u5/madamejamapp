import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/auth_repository.dart';
import '../application/auth_controller.dart';

/// Escuta erros do [authControllerProvider] e exibe um SnackBar traduzido.
extension AuthFeedback on WidgetRef {
  void listenAuthErrors(BuildContext context) {
    listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final message = error is AuthFailure
            ? error.message
            : 'Não foi possível concluir. Tente novamente.';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
            ),
          );
      }
    });
  }
}

/// Spinner branco para botões em estado de carregamento.
class AuthButtonSpinner extends StatelessWidget {
  const AuthButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}
