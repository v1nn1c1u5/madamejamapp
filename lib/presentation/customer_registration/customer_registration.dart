import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/customer_service.dart';
import './widgets/registration_form_widget.dart';
import './widgets/registration_header_widget.dart';
import './widgets/success_message_widget.dart';

class CustomerRegistration extends StatefulWidget {
  const CustomerRegistration({Key? key}) : super(key: key);

  @override
  State<CustomerRegistration> createState() => _CustomerRegistrationState();
}

class _CustomerRegistrationState extends State<CustomerRegistration> {
  bool _isLoading = false;
  bool _showSuccessMessage = false;
  String? _errorMessage;
  bool _returnToManualOrder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we should return to manual order after success
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _returnToManualOrder = args?['returnToManualOrder'] ?? false;
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _handleFormSubmit(Map<String, String> formData) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fullName = formData['fullName']!;
      final email = formData['email']!.toLowerCase();
      final password = formData['password']!;
      final phone = formData['phone'];
      final complex = formData['complex'];
      final building = formData['building'];
      final apartment = formData['apartment'];
      final notes = formData['notes'];

      // Check if customer already exists by email
      final customerExistsByEmail =
          await CustomerService.instance.customerExistsByEmail(email);
      if (customerExistsByEmail) {
        _showErrorMessage(
            'Este e-mail já está cadastrado. Tente fazer login ou use outro e-mail.');
        return;
      }

      // Check if customer already exists by phone
      if (phone != null && phone.isNotEmpty) {
        final customerExistsByPhone =
            await CustomerService.instance.customerExistsByPhone(phone);
        if (customerExistsByPhone) {
          _showErrorMessage(
              'Este telefone já está cadastrado. Tente fazer login ou use outro número.');
          return;
        }
      }

      // Create user account in Supabase Auth
      final authResponse = await AuthService.instance.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: 'customer',
      );

      if (authResponse.user != null) {
        // Create customer profile
        await CustomerService.instance.createCustomer(
          userProfileId: authResponse.user!.id,
          phone: phone,
          addressLine1: complex,
          addressLine2: '$building, Apt $apartment',
          deliveryNotes: notes?.isNotEmpty == true ? notes : null,
        );

        // Show success message
        setState(() {
          _showSuccessMessage = true;
        });
      } else {
        _showErrorMessage('Erro no cadastro. Tente novamente.');
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Handle specific Supabase errors
      if (errorMessage.contains('already registered') ||
          errorMessage.contains('User already registered')) {
        errorMessage = 'Este e-mail já está cadastrado. Tente fazer login.';
      } else if (errorMessage.contains('email')) {
        errorMessage = 'Erro relacionado ao e-mail. Verifique se está correto.';
      } else if (errorMessage.contains('password')) {
        errorMessage = 'Erro na senha. Tente uma senha mais forte.';
      } else if (errorMessage.contains('network') ||
          errorMessage.contains('connection')) {
        errorMessage =
            'Erro de conexão. Verifique sua internet e tente novamente.';
      } else if (errorMessage.contains('signup')) {
        errorMessage = 'Erro no processo de cadastro. Tente novamente.';
      } else if (errorMessage.contains('profile')) {
        errorMessage = 'Erro ao criar perfil do cliente. Tente novamente.';
      } else if (errorMessage.isEmpty || errorMessage == 'null') {
        errorMessage = 'Algo deu errado. Tente novamente.';
      }

      _showErrorMessage(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBackPressed() {
    if (_showSuccessMessage) {
      setState(() {
        _showSuccessMessage = false;
      });
    } else {
      // If we came from manual order, go back there, otherwise go to customer login
      if (_returnToManualOrder) {
        Navigator.pop(context, false); // Return false (no customer created)
      } else {
        Navigator.pushReplacementNamed(context, '/customer-login');
      }
    }
  }

  void _handleSuccessComplete() {
    if (_returnToManualOrder) {
      // Return to manual order with success indicator
      Navigator.pop(
          context, true); // Return true (customer created successfully)
    } else {
      // Normal flow - go to product catalog
      Navigator.pushReplacementNamed(context, '/product-catalog-home');
    }
  }

  void _dismissError() {
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          RegistrationHeaderWidget(
            onBackPressed: _handleBackPressed,
            title: _returnToManualOrder ? 'Cadastrar Cliente' : null,
          ),

          // Main Content
          Expanded(
            child: _showSuccessMessage
                ? SuccessMessageWidget(
                    onComplete: _handleSuccessComplete,
                    title: _returnToManualOrder ? 'Cliente Cadastrado!' : null,
                    message: _returnToManualOrder
                        ? 'Cliente cadastrado com sucesso! Você pode agora selecioná-lo na lista de clientes.'
                        : null,
                    buttonText:
                        _returnToManualOrder ? 'Voltar ao Pedido' : null,
                  )
                : _buildRegistrationContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Error Message
          if (_errorMessage != null) ...[
            _buildErrorMessage(),
            SizedBox(height: 2.h),
          ],

          // Registration Form
          RegistrationFormWidget(
            onFormSubmit: _handleFormSubmit,
            isLoading: _isLoading,
          ),

          // Bottom spacing for keyboard
          SizedBox(height: 4.h),

          // Login Link (only show if not from manual order)
          if (!_returnToManualOrder) _buildLoginLink(),

          // Additional bottom spacing
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'error',
            size: 6.w,
            color: AppTheme.lightTheme.colorScheme.error,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: _dismissError,
            child: CustomIconWidget(
              iconName: 'close',
              size: 5.w,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Já tem uma conta? ',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushReplacementNamed(context, '/customer-login'),
            child: Text(
              'Fazer Login',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
