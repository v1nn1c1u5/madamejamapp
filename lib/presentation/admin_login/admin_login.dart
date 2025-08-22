import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/admin_header_widget.dart';
import './widgets/admin_login_button_widget.dart';
import './widgets/admin_login_form_widget.dart';
import './widgets/security_features_widget.dart';
import './widgets/session_timeout_widget.dart';
import './widgets/social_login_widget.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _twoFactorController = TextEditingController();

  // State variables
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  int _failedAttempts = 0;
  bool _isLocked = false;
  int _lockoutTimeRemaining = 0;
  bool _showTwoFactorPrompt = false;
  bool _showTimeoutWarning = false;
  int _timeoutCountdown = 0;
  Timer? _lockoutTimer;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _startSessionTimeoutTimer();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _twoFactorController.dispose();
    _lockoutTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startSessionTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeoutCountdown > 0) {
        setState(() {
          _timeoutCountdown--;
        });
      } else if (_showTimeoutWarning) {
        _handleSessionTimeout();
      }
    });

    // Start timeout warning after 10 minutes of inactivity
    Timer(const Duration(minutes: 10), () {
      if (mounted) {
        setState(() {
          _showTimeoutWarning = true;
          _timeoutCountdown = 60; // 60 seconds warning
        });
      }
    });
  }

  void _handleSessionTimeout() {
    _timeoutTimer?.cancel();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/customer-login');
    }
  }

  void _extendSession() {
    setState(() {
      _showTimeoutWarning = false;
      _timeoutCountdown = 0;
    });
    _startSessionTimeoutTimer();
  }

  void _startLockoutTimer() {
    setState(() {
      _isLocked = true;
      _lockoutTimeRemaining = 300; // 5 minutes lockout
    });

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockoutTimeRemaining > 0) {
        setState(() {
          _lockoutTimeRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isLocked = false;
          _failedAttempts = 0;
        });
      }
    });
  }

  Future<void> _handleLogin() async {
    if (_isLocked || _isLoading) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorMessage('Por favor, preencha todos os campos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Try to sign in with Supabase
      await AuthService.instance.signIn(
        email: username.contains('@') ? username : '$username@madamejam.com.br',
        password: password,
      );

      // Check if user is admin
      final isAdmin = await AuthService.instance.isAdmin();

      if (!isAdmin) {
        await AuthService.instance.signOut();
        throw Exception(
            'Acesso negado. Esta área é exclusiva para administradores.');
      }

      _handleSuccessfulLogin();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _failedAttempts++;
      });

      if (_failedAttempts >= 3) {
        _startLockoutTimer();
        _showErrorMessage(
            'Muitas tentativas falharam. Conta bloqueada temporariamente.');
      } else {
        _showErrorMessage(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _handleTwoFactorSubmit() async {
    final code = _twoFactorController.text.trim();

    if (code.length != 6) {
      _showErrorMessage('Código deve ter 6 dígitos');
      return;
    }

    // Mock two-factor validation (accept 123456 as valid code)
    if (code == '123456') {
      _handleSuccessfulLogin();
    } else {
      _showErrorMessage('Código inválido. Use: 123456');
    }
  }

  void _handleSuccessfulLogin() {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Navigate to admin dashboard
    Navigator.pushReplacementNamed(context, '/admin-dashboard');
  }

  void _handleTwoFactorCancel() {
    setState(() {
      _showTwoFactorPrompt = false;
      _twoFactorController.clear();
    });
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recuperação de Senha'),
        content: Text(
          'Para recuperar sua senha de administrador, entre em contato com o suporte técnico ou com o proprietário da padaria.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate social login delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock social login success
    _showErrorMessage(
        'Login social disponível apenas para administradores autorizados');

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  bool get _isFormValid {
    return _usernameController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/customer-login'),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 2.h),

              // Admin Header
              const AdminHeaderWidget(),
              SizedBox(height: 4.h),

              // Session Timeout Warning
              SessionTimeoutWidget(
                showTimeoutWarning: _showTimeoutWarning,
                timeoutCountdown: _timeoutCountdown,
                onExtendSession: _extendSession,
                onLogout: () =>
                    Navigator.pushReplacementNamed(context, '/customer-login'),
              ),
              if (_showTimeoutWarning) SizedBox(height: 3.h),

              // Security Features
              SecurityFeaturesWidget(
                failedAttempts: _failedAttempts,
                isLocked: _isLocked,
                lockoutTimeRemaining: _lockoutTimeRemaining,
                showTwoFactorPrompt: _showTwoFactorPrompt,
                twoFactorController: _twoFactorController,
                onTwoFactorSubmit: _handleTwoFactorSubmit,
                onTwoFactorCancel: _handleTwoFactorCancel,
              ),

              // Login Form
              if (!_showTwoFactorPrompt) ...[
                AdminLoginFormWidget(
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  isPasswordVisible: _isPasswordVisible,
                  onPasswordVisibilityToggle: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  onForgotPassword: _handleForgotPassword,
                  isLoading: _isLoading,
                ),
                SizedBox(height: 4.h),

                // Login Button
                AdminLoginButtonWidget(
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  isEnabled: _isFormValid && !_isLocked,
                ),
                SizedBox(height: 4.h),

                // Social Login
                SocialLoginWidget(
                  onGoogleLogin: () => _handleSocialLogin('Google'),
                  onMicrosoftLogin: () => _handleSocialLogin('Microsoft'),
                  isLoading: _isLoading,
                ),
              ],

              SizedBox(height: 4.h),

              // Admin Session Indicator
              if (_showTimeoutWarning || _failedAttempts > 0) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'admin_panel_settings',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Sessão Administrativa',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
              ],

              // Development Note
              Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Credenciais de Admin',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Email: admin@madamejam.com.br\n'
                      'Usuário: admin\n'
                      'Senha: admin123',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
