import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/brand_wordmark.dart';

/// Tela de acesso — esqueleto da fundação (Story 1.1).
///
/// Os fluxos reais de cadastro, login e recuperação de senha são entregues
/// nas Stories 1.2 e 1.3.
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BrandWordmark(),
                  const SizedBox(height: 8),
                  Text(
                    'Da minha família para a sua',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Acesso em construção',
                    style: textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login e cadastro chegam nas próximas etapas (Stories 1.2 e 1.3).',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
