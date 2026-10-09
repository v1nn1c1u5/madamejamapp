import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/auth/auth_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/brand_wordmark.dart';
import '../application/auth_controller.dart';
import 'auth_feedback.dart';

/// Tela de login (Story 1.3).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _redirectTarget(BuildContext context) {
    final raw = GoRouterState.of(context).uri.queryParameters['redirect'];
    if (raw == null || raw.isEmpty) return null;
    return Uri.decodeComponent(raw);
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final dest = _redirectTarget(context);
    final router = GoRouter.of(context);
    final ok = await ref.read(authControllerProvider.notifier).signIn(
          email: _email.text,
          password: _password.text,
        );
    if (ok && mounted) {
      router.go(dest ?? AppRoutes.catalog);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final loading = state.isLoading;
    final hasRedirect = _redirectTarget(context) != null;
    final canSkipLogin = allowsGuestBypass(_redirectTarget(context));
    ref.listenAuthErrors(context);

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandWordmark(),
                      const SizedBox(height: 8),
                      Text(
                        'Da minha família para a sua',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(labelText: 'E-mail'),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        decoration: const InputDecoration(labelText: 'Senha'),
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(context),
                        validator: (v) =>
                            Validators.required(v, field: 'Senha'),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: loading
                              ? null
                              : () => context.push(AppRoutes.forgotPassword),
                          child: const Text('Esqueci minha senha'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading ? null : () => _submit(context),
                          child: loading
                              ? const AuthButtonSpinner()
                              : const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Ainda não tem conta?',
                              style: textTheme.bodyMedium),
                          TextButton(
                            onPressed: loading
                                ? null
                                : () => context.push(AppRoutes.signUp),
                            child: const Text('Criar conta'),
                          ),
                        ],
                      ),
                      if (hasRedirect && canSkipLogin) ...[
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.catalog),
                          child: const Text('Continuar sem login'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
