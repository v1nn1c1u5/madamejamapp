import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../supabase/supabase_providers.dart';
import 'go_router_refresh_stream.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/admin/presentation/admin_home_screen.dart';

/// Rotas nomeadas do app.
abstract final class AppRoutes {
  static const signIn = '/sign-in';
  static const catalog = '/'; // home do cliente
  static const adminHome = '/admin';
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
      // Enquanto o estado inicial de auth carrega, não redireciona.
      final loggedIn = ref.read(sessionProvider) != null;
      final isAdmin = ref.read(isAdminProvider);
      final goingToSignIn = state.matchedLocation == AppRoutes.signIn;
      final goingToAdmin = state.matchedLocation.startsWith(AppRoutes.adminHome);

      if (!loggedIn) {
        return goingToSignIn ? null : AppRoutes.signIn;
      }

      // Logado tentando acessar a tela de login → manda para a home.
      if (goingToSignIn) {
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
