import '../router/app_router.dart';

/// Rotas que exigem autenticação (checkout, pedidos, admin).
bool routeRequiresAuth(String location) =>
    AppRoutes.authRequiredPrefixes
        .any((prefix) => location == prefix || location.startsWith('$prefix/'));

String signInRouteWithRedirect(String destination) =>
    '${AppRoutes.signIn}?redirect=${Uri.encodeComponent(destination)}';

/// Destinos de checkout/pagamento não permitem continuar sem login.
bool allowsGuestBypass(String? redirectTarget) {
  if (redirectTarget == null || redirectTarget.isEmpty) return true;
  return !routeRequiresAuth(redirectTarget);
}
