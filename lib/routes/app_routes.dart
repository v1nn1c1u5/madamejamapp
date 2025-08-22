import 'package:flutter/material.dart';
import '../presentation/product_detail/product_detail.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/order_history/order_history.dart';
import '../presentation/checkout_payment/checkout_payment.dart';
import '../presentation/shopping_cart/shopping_cart.dart';
import '../presentation/customer_registration/customer_registration.dart';
import '../presentation/admin_login/admin_login.dart';
import '../presentation/product_category_list/product_category_list.dart';
import '../presentation/product_catalog_home/product_catalog_home.dart';
import '../presentation/admin_dashboard/admin_dashboard.dart';
import '../presentation/customer_login/customer_login.dart';
import '../presentation/customer_profile/customer_profile.dart';
import '../presentation/add_product/add_product.dart';
import '../presentation/manual_order_creation/manual_order_creation.dart';
import '../presentation/customer_database/customer_database.dart';
import '../presentation/delivery_support/delivery_support.dart';
import '../widgets/auth_wrapper.dart';

class AppRoutes {
  // Add your routes here
  static const String initial = '/';
  static const String productDetail = '/product-detail';
  static const String splash = '/splash-screen';
  static const String orderHistory = '/order-history';
  static const String checkoutPayment = '/checkout-payment';
  static const String shoppingCart = '/shopping-cart';
  static const String customerRegistration = '/customer-registration';
  static const String adminLogin = '/admin-login';
  static const String productCategoryList = '/product-category-list';
  static const String productCatalogHome = '/product-catalog-home';
  static const String adminDashboard = '/admin-dashboard';
  static const String customerLogin = '/customer-login';
  static const String customerProfile = '/customer-profile';
  static const String addProduct = '/add-product';
  static const String manualOrderCreation = '/manual-order-creation';
  static const String customerDatabase = '/customer-database';
  static const String deliverySupport = '/delivery-support';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    productDetail: (context) => const ProductDetail(),
    splash: (context) => const SplashScreen(),
    orderHistory: (context) => AuthWrapper(
          requireAuth: true,
          child: const OrderHistory(),
        ),
    checkoutPayment: (context) => AuthWrapper(
          requireAuth: true,
          child: const CheckoutPayment(),
        ),
    shoppingCart: (context) => const ShoppingCart(),
    customerRegistration: (context) => const CustomerRegistration(),
    adminLogin: (context) => const AdminLogin(),
    productCategoryList: (context) => const ProductCategoryList(),
    productCatalogHome: (context) => const ProductCatalogHome(),
    adminDashboard: (context) => AuthWrapper(
          requireAuth: true,
          requiredRole: 'admin',
          child: const AdminDashboard(),
        ),
    customerLogin: (context) => const CustomerLogin(),
    customerProfile: (context) => AuthWrapper(
          requireAuth: true,
          child: const CustomerProfile(),
        ),
    addProduct: (context) => AuthWrapper(
          requireAuth: true,
          requiredRole: 'admin',
          child: const AddProduct(),
        ),
    manualOrderCreation: (context) => AuthWrapper(
          requireAuth: true,
          requiredRole: 'admin',
          child: const ManualOrderCreation(),
        ),
    customerDatabase: (context) => AuthWrapper(
          requireAuth: true,
          requiredRole: 'admin',
          child: const CustomerDatabase(),
        ),
    deliverySupport: (context) => AuthWrapper(
          requireAuth: true,
          requiredRole: 'admin',
          child: const DeliverySupport(),
        ),
    // Add your other routes here
  };
}
