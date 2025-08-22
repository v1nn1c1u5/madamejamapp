import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/custom_text_field.dart';
import './widgets/primary_button.dart';
import './widgets/social_login_button.dart';

class CustomerLogin extends StatefulWidget {
  const CustomerLogin({super.key});

  @override
  State<CustomerLogin> createState() => _CustomerLoginState();
}

class _CustomerLoginState extends State<CustomerLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isMicrosoftLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _isValidEmail(_emailController.text) &&
        _emailError == null &&
        _passwordError == null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email é obrigatório';
      } else if (!_isValidEmail(value)) {
        _emailError = 'Digite um email válido';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Senha é obrigatória';
      } else if (value.length < 6) {
        _passwordError = 'Senha deve ter pelo menos 6 caracteres';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text.trim();

      // Use Supabase authentication
      await AuthService.instance.signIn(
        email: email,
        password: password,
      );

      // Get user role to determine redirect
      final userRole = await AuthService.instance.getUserRole();

      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();

      // Show success toast
      Fluttertoast.showToast(
        msg: "Login realizado com sucesso!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        textColor: AppTheme.lightTheme.colorScheme.onPrimary,
      );

      if (mounted) {
        // Navigate based on user role
        if (userRole == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/product-catalog-home');
        }
      }
    } catch (e) {
      _showErrorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (provider == 'google') {
      setState(() {
        _isGoogleLoading = true;
      });
    } else {
      setState(() {
        _isMicrosoftLoading = true;
      });
    }

    try {
      // Note: Social login would need additional setup in Supabase dashboard
      // For now, show message about configuration
      _showErrorMessage(
          'Login social em desenvolvimento. Use email e senha por enquanto.');
    } catch (e) {
      _showErrorMessage(
          'Erro no login com ${provider == 'google' ? 'Google' : 'Microsoft'}. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() {
          if (provider == 'google') {
            _isGoogleLoading = false;
          } else {
            _isMicrosoftLoading = false;
          }
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: AppTheme.lightTheme.colorScheme.onError,
    );
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !_isValidEmail(email)) {
      _showErrorMessage('Digite um email válido primeiro');
      return;
    }

    try {
      await AuthService.instance.resetPassword(email: email);
      Fluttertoast.showToast(
        msg: "Link de recuperação enviado para seu email!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        textColor: AppTheme.lightTheme.colorScheme.onPrimary,
      );
    } catch (e) {
      _showErrorMessage('Erro ao enviar link de recuperação');
    }
  }

  void _navigateToRegistration() {
    Navigator.pushNamed(context, '/customer-registration');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 4.h),

                      // Logo Section
                      Container(
                        width: 25.w,
                        height: 25.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'bakery_dining',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 12.w,
                          ),
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Welcome Message
                      Text(
                        'Bem-vinda à Madame Jam',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 1.h),

                      Text(
                        'Entre na sua conta para descobrir nossos produtos artesanais',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 4.h),

                      // Email Field
                      CustomTextField(
                        label: 'Email',
                        hint: 'Digite seu email',
                        iconName: 'email',
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        errorText: _emailError,
                        enabled: !_isLoading,
                        onChanged: _validateEmail,
                      ),

                      SizedBox(height: 3.h),

                      // Password Field
                      CustomTextField(
                        label: 'Senha',
                        hint: 'Digite sua senha',
                        iconName: 'lock',
                        isPassword: true,
                        controller: _passwordController,
                        errorText: _passwordError,
                        enabled: !_isLoading,
                        onChanged: _validatePassword,
                      ),

                      SizedBox(height: 2.h),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : _handleForgotPassword,
                          child: Text(
                            'Esqueceu a senha?',
                            style: AppTheme.lightTheme.textTheme.labelMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Login Button
                      PrimaryButton(
                        text: 'Entrar',
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                        isEnabled: _isFormValid,
                      ),

                      SizedBox(height: 4.h),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppTheme.lightTheme.colorScheme.outline,
                              thickness: 1.0,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              'Ou continue com',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppTheme.lightTheme.colorScheme.outline,
                              thickness: 1.0,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 3.h),

                      // Social Login Buttons
                      SocialLoginButton(
                        iconName: 'g_mobiledata',
                        label: 'Continuar com Google',
                        onPressed: () => _handleSocialLogin('google'),
                        isLoading: _isGoogleLoading,
                      ),

                      SizedBox(height: 2.h),

                      SocialLoginButton(
                        iconName: 'microsoft',
                        label: 'Continuar com Microsoft',
                        onPressed: () => _handleSocialLogin('microsoft'),
                        isLoading: _isMicrosoftLoading,
                      ),

                      const Spacer(),

                      SizedBox(height: 4.h),

                      // Registration Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Novo usuário? ',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed:
                                _isLoading ? null : _navigateToRegistration,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 1.w),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Cadastre-se',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // Development Note
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme
                              .lightTheme.colorScheme.primaryContainer
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
                              'Credenciais de Teste',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Admin: admin@madamejam.com.br / admin123\n'
                              'Cliente: cliente@madamejam.com.br / cliente123',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
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
            ),
          ),
        ),
      ),
    );
  }
}
