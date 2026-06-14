import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../supabase/supabase_providers.dart';
import 'go_router_refresh_stream.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/admin/presentation/admin_home_screen.dart';

/// Rotas nomeadas do app.
abstract final class AppRoutes {
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';
  static const catalog = '/'; // home do cliente
  static const adminHome = '/admin';

  /// Rotas acessíveis sem autenticação.
  static const _publicRoutes = {signIn, signUp, forgotPassword};
}

/// Roteador com proteção por autenticação e por role (NFR6).
///
/// - Sem sessão → redireciona para o login.
/// - Sessão sem role admin tentando rota `/admin` → volta ao catálogo.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.catalog,
    refreshListenable: GoRouterRefreshStream(
      ref.watch(supabaseClientProvider).auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final loggedIn = ref.read(sessionProvider) != null;
      final isAdmin = ref.read(isAdminProvider);
      final atPublicRoute =
          AppRoutes._publicRoutes.contains(state.matchedLocation);
      final goingToAdmin = state.matchedLocation.startsWith(AppRoutes.adminHome);

      // Sem sessão: só pode estar numa rota pública (login/cadastro/recuperação).
      if (!loggedIn) {
        return atPublicRoute ? null : AppRoutes.signIn;
      }

      // Logado tentando acessar rota de autenticação → manda para a home.
      if (atPublicRoute) {
        return isAdmin ? AppRoutes.adminHome : AppRoutes.catalog;
      }

      // Cliente comum tentando acessar área admin → bloqueia.
      if (goingToAdmin && !isAdmin) {
        return AppRoutes.catalog;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.catalog,
        builder: (context, state) => const CatalogScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminHome,
        builder: (context, state) => const AdminHomeScreen(),
      ),
    ],
  );
});
