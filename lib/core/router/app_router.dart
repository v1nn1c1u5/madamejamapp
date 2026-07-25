import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_routes.dart';
import '../auth/checkout_auth.dart';
import '../scaffold/root_scaffold_messenger.dart';
import '../supabase/supabase_providers.dart';
import 'go_router_refresh_stream.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/catalog/presentation/product_detail_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/payment_screen.dart';
import '../../features/checkout/presentation/order_confirmation_screen.dart';
import '../../features/orders/presentation/order_history_screen.dart';
import '../../features/orders/presentation/order_tracking_screen.dart';
import '../../features/admin/presentation/admin_home_screen.dart';
import '../../features/admin/presentation/product_list_screen.dart';
import '../../features/admin/presentation/product_form_screen.dart';
import '../../features/admin/presentation/delivery_config_screen.dart';
import '../../features/admin/presentation/weekly_orders_screen.dart';
import '../../features/admin/presentation/daily_orders_screen.dart';
import '../../features/admin/presentation/order_detail_screen.dart';

abstract final class AppRoutes {
  // ── Auth ─────────────────────────────────────────────────────────────────
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';

  // ── Cliente ───────────────────────────────────────────────────────────────
  static const catalog = '/';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const payment = '/checkout/payment';
  static const myOrders = '/orders';

  static String productDetailPath(String id) => '/product/$id';
  static String orderConfirmationPath(String id) => '/orders/$id/confirmation';
  static String orderTrackingPath(String id) => '/orders/$id';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const adminHome = '/admin';
  static const adminProducts = '/admin/products';
  static const adminProductNew = '/admin/products/new';
  static const adminDeliveryConfig = '/admin/delivery';
  static const adminWeeklyOrders = '/admin/orders/week';
  static const adminDailyOrders = '/admin/orders/day';

  static String adminProductEditPath(String id) => '/admin/products/$id';
  static String adminOrderDetailPath(String id) => '/admin/orders/$id';

  /// Prefixos de rotas que exigem autenticação obrigatória.
  static const authRequiredPrefixes = [checkout, myOrders, adminHome];
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.catalog,
    refreshListenable: GoRouterRefreshStream(
      ref.watch(supabaseClientProvider).auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final loggedIn = ref.read(sessionProvider) != null;
      final isAdmin = ref.read(isAdminProvider);
      final loc = state.matchedLocation;

      final atAuthScreen = {
        AppRoutes.signIn,
        AppRoutes.signUp,
        AppRoutes.forgotPassword,
      }.contains(loc);

      // Rota exige login se começa com algum prefixo protegido.
      final needsAuth = routeRequiresAuth(loc);

      if (!loggedIn && needsAuth) {
        // Guarda destino para redirecionar após login.
        return signInRouteWithRedirect(loc);
      }
      if (loggedIn && atAuthScreen) {
        return isAdmin ? AppRoutes.adminHome : AppRoutes.catalog;
      }
      if (loc.startsWith(AppRoutes.adminHome) && !isAdmin) {
        return AppRoutes.catalog;
      }
      return null;
    },
    routes: [
      // ── Autenticação ─────────────────────────────────────────────────────
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

      // ── Cliente ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.catalog,
        builder: (context, state) => const CatalogScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => ProductDetailScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => AuthRequired(
          destination: AppRoutes.checkout,
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) => AuthRequired(
          destination: AppRoutes.payment,
          child: PaymentScreen(
            checkoutData: state.extra! as CheckoutData,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.myOrders,
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) => OrderTrackingScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id/confirmation',
        builder: (context, state) => OrderConfirmationScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),

      // ── Admin ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.adminHome,
        builder: (context, state) => const AdminHomeScreen(),
        routes: [
          GoRoute(
            path: 'products',
            builder: (context, state) => const ProductListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ProductFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => ProductFormScreen(
                  productId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'delivery',
            builder: (context, state) => const DeliveryConfigScreen(),
          ),
          GoRoute(
            path: 'orders/week',
            builder: (context, state) => const WeeklyOrdersScreen(),
          ),
          GoRoute(
            path: 'orders/day',
            builder: (context, state) => const DailyOrdersScreen(),
          ),
          GoRoute(
            path: 'orders/:id',
            builder: (context, state) => AdminOrderDetailScreen(
              orderId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );

  router.routerDelegate.addListener(() {
    rootScaffoldMessengerKey.currentState?.clearSnackBars();
  });

  return router;
});
