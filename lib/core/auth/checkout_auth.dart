import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_routes.dart';
import '../../features/auth/data/auth_repository.dart';
import '../supabase/supabase_providers.dart';
import '../theme/app_colors.dart';

/// Banner com e-mail/nome do comprador autenticado.
class CheckoutIdentityBanner extends ConsumerWidget {
  const CheckoutIdentityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider)?.user;
    if (user == null) return const SizedBox.shrink();

    final name = user.userMetadata?['name'] as String?;
    final email = user.email ?? '';
    final label = (name != null && name.trim().isNotEmpty)
        ? '$name · $email'
        : email;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.champagneLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.champagne.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.champagneDark),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comprando como',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.champagneDark,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final destination = GoRouterState.of(context).uri.path;
              final repo = ref.read(authRepositoryProvider);
              await repo.signOut();
              if (!context.mounted) return;
              context.go(signInRouteWithRedirect(destination));
            },
            child: const Text('Trocar conta'),
          ),
        ],
      ),
    );
  }
}

/// Redireciona para login se não houver sessão ativa.
class AuthRequired extends ConsumerStatefulWidget {
  const AuthRequired({
    super.key,
    required this.destination,
    required this.child,
  });

  final String destination;
  final Widget child;

  @override
  ConsumerState<AuthRequired> createState() => _AuthRequiredState();
}

class _AuthRequiredState extends ConsumerState<AuthRequired> {
  @override
  Widget build(BuildContext context) {
    final loggedIn = ref.watch(sessionProvider) != null;
    if (!loggedIn) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}

void navigateWithAuth(
  BuildContext context,
  WidgetRef ref, {
  required String destination,
}) {
  if (ref.read(sessionProvider) == null) {
    context.push(signInRouteWithRedirect(destination));
    return;
  }
  context.push(destination);
}
