import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../presentation/customer_login/customer_login.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;
  final bool requireAuth;
  final String? requiredRole;
  final Widget? fallbackWidget;

  const AuthWrapper({
    super.key,
    required this.child,
    this.requireAuth = false,
    this.requiredRole,
    this.fallbackWidget,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    AuthService.instance.authStateChanges.listen((AuthState state) {
      if (state.event == AuthChangeEvent.signedIn) {
        _checkAuthStatus();
      } else if (state.event == AuthChangeEvent.signedOut) {
        if (mounted) {
          setState(() {
            _isAuthenticated = false;
            _userRole = null;
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isSignedIn = AuthService.instance.isSignedIn;
      String? role;

      if (isSignedIn) {
        role = await AuthService.instance.getUserRole();
      }

      if (mounted) {
        setState(() {
          _isAuthenticated = isSignedIn;
          _userRole = role;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _userRole = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If auth is not required, show the child widget
    if (!widget.requireAuth) {
      return widget.child;
    }

    // If auth is required but user is not authenticated
    if (!_isAuthenticated) {
      return widget.fallbackWidget ?? const CustomerLogin();
    }

    // If specific role is required, check user role
    if (widget.requiredRole != null && _userRole != widget.requiredRole) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Acesso Negado',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Você não tem permissão para acessar esta área.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/customer-login');
                },
                child: const Text('Voltar ao Login'),
              ),
            ],
          ),
        ),
      );
    }

    // All checks passed, show the child widget
    return widget.child;
  }
}
