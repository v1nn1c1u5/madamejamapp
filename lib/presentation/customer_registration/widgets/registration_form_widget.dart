import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationFormWidget extends StatefulWidget {
  final Function(Map<String, String>) onFormSubmit;
  final bool isLoading;

  const RegistrationFormWidget({
    super.key,
    required this.onFormSubmit,
    required this.isLoading,
  });

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _complexController = TextEditingController();
  final _buildingController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _notesController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptTerms = false;
  bool _isFormValid = false;

  // Validation states
  final Map<String, bool> _fieldValidation = {
    'fullName': false,
    'email': false,
    'password': false,
    'phone': false,
    'complex': false,
    'building': false,
    'apartment': false,
  };

  @override
  void initState() {
    super.initState();
    _setupFormListeners();
  }

  void _setupFormListeners() {
    _fullNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _complexController.addListener(_validateForm);
    _buildingController.addListener(_validateForm);
    _apartmentController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _fieldValidation['fullName'] =
          _fullNameController.text.trim().length >= 2;
      _fieldValidation['email'] = _isValidEmail(_emailController.text);
      _fieldValidation['password'] = _isValidPassword(_passwordController.text);
      _fieldValidation['phone'] = _isValidBrazilianPhone(_phoneController.text);
      _fieldValidation['complex'] = _complexController.text.trim().isNotEmpty;
      _fieldValidation['building'] = _buildingController.text.trim().isNotEmpty;
      _fieldValidation['apartment'] =
          _apartmentController.text.trim().isNotEmpty;

      _isFormValid =
          _fieldValidation.values.every((isValid) => isValid) && _acceptTerms;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  bool _isValidBrazilianPhone(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Aceita formato nacional (11 dígitos) ou internacional (13 dígitos começando com 55)
    if (cleanPhone.length == 11) {
      // Ex: 71981919187
      return true;
    } else if (cleanPhone.length == 13 && cleanPhone.startsWith('55')) {
      // Ex: 5571981919187
      return true;
    }
    return false;
  }

  String _formatBrazilianPhone(String value) {
    String numbers = value.replaceAll(RegExp(r'[^\d]'), '');

    if (numbers.isEmpty) return '';

    if (!numbers.startsWith('55')) {
      numbers = '55$numbers';
    }

    if (numbers.length <= 2) return '+$numbers';
    if (numbers.length <= 4)
      return '+${numbers.substring(0, 2)} (${numbers.substring(2)}';
    if (numbers.length <= 9)
      return '+${numbers.substring(0, 2)} (${numbers.substring(2, 4)}) ${numbers.substring(4)}';
    if (numbers.length <= 13) {
      return '+${numbers.substring(0, 2)} (${numbers.substring(2, 4)}) ${numbers.substring(4, 9)}-${numbers.substring(9)}';
    }

    return '+${numbers.substring(0, 2)} (${numbers.substring(2, 4)}) ${numbers.substring(4, 9)}-${numbers.substring(9, 13)}';
  }

  int _getPasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  Color _getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppTheme.lightTheme.colorScheme.error;
      case 2:
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.green;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Fraca';
      case 2:
      case 3:
        return 'Média';
      case 4:
      case 5:
        return 'Forte';
      default:
        return '';
    }
  }

  void _submitForm() {
    if (_isFormValid && !widget.isLoading) {
      final formData = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'phone': _phoneController.text,
        'complex': _complexController.text.trim(),
        'building': _buildingController.text.trim(),
        'apartment': _apartmentController.text.trim(),
        'notes': _notesController.text.trim(),
      };
      widget.onFormSubmit(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information Section
          Text(
            'Informações Pessoais',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Full Name Field
          _buildInputField(
            controller: _fullNameController,
            label: 'Nome Completo',
            hint: 'Digite seu nome completo',
            icon: 'person',
            isValid: _fieldValidation['fullName'] ?? false,
            errorText: _fullNameController.text.isNotEmpty &&
                    !(_fieldValidation['fullName'] ?? false)
                ? 'Nome deve ter pelo menos 2 caracteres'
                : null,
          ),
          SizedBox(height: 2.h),

          // Email Field
          _buildInputField(
            controller: _emailController,
            label: 'E-mail',
            hint: 'Digite seu e-mail',
            icon: 'email',
            keyboardType: TextInputType.emailAddress,
            isValid: _fieldValidation['email'] ?? false,
            errorText: _emailController.text.isNotEmpty &&
                    !(_fieldValidation['email'] ?? false)
                ? 'Digite um e-mail válido'
                : null,
          ),
          SizedBox(height: 2.h),

          // Password Field with Strength Indicator
          _buildPasswordField(),
          SizedBox(height: 2.h),

          // Phone Field
          _buildPhoneField(),
          SizedBox(height: 3.h),

          // Address Section
          Text(
            'Endereço de Entrega',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Residential Complex Field
          _buildInputField(
            controller: _complexController,
            label: 'Condomínio/Residencial',
            hint: 'Nome do condomínio',
            icon: 'location_city',
            isValid: _fieldValidation['complex'] ?? false,
            errorText: _complexController.text.isNotEmpty &&
                    !(_fieldValidation['complex'] ?? false)
                ? 'Campo obrigatório'
                : null,
          ),
          SizedBox(height: 2.h),

          // Building and Apartment Row
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _buildingController,
                  label: 'Bloco/Torre',
                  hint: 'Ex: A, 1, Torre 1',
                  icon: 'business',
                  isValid: _fieldValidation['building'] ?? false,
                  errorText: _buildingController.text.isNotEmpty &&
                          !(_fieldValidation['building'] ?? false)
                      ? 'Campo obrigatório'
                      : null,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildInputField(
                  controller: _apartmentController,
                  label: 'Apartamento',
                  hint: 'Ex: 101, 205',
                  icon: 'home',
                  keyboardType: TextInputType.text,
                  isValid: _fieldValidation['apartment'] ?? false,
                  errorText: _apartmentController.text.isNotEmpty &&
                          !(_fieldValidation['apartment'] ?? false)
                      ? 'Campo obrigatório'
                      : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Delivery Notes Field
          _buildInputField(
            controller: _notesController,
            label: 'Observações para Entrega (Opcional)',
            hint: 'Ex: Portaria, interfone, referências...',
            icon: 'note',
            maxLines: 3,
            isValid: true, // Optional field
          ),
          SizedBox(height: 3.h),

          // Terms and Conditions
          _buildTermsCheckbox(),
          SizedBox(height: 4.h),

          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isValid = false,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: icon,
                size: 5.w,
                color: isValid && controller.text.isNotEmpty
                    ? Colors.green
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: isValid ? 'check_circle' : 'error',
                      size: 5.w,
                      color: isValid
                          ? Colors.green
                          : AppTheme.lightTheme.colorScheme.error,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isValid && controller.text.isNotEmpty
                    ? Colors.green
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            errorText,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField() {
    int strength = _getPasswordStrength(_passwordController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: 'Senha',
            hintText: 'Mínimo 8 caracteres, 1 maiúscula, 1 número',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                size: 5.w,
                color: _fieldValidation['password']! &&
                        _passwordController.text.isNotEmpty
                    ? Colors.green
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_passwordController.text.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: CustomIconWidget(
                      iconName: _fieldValidation['password']!
                          ? 'check_circle'
                          : 'error',
                      size: 5.w,
                      color: _fieldValidation['password']!
                          ? Colors.green
                          : AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName:
                          _obscurePassword ? 'visibility' : 'visibility_off',
                      size: 5.w,
                      color: AppTheme.lightTheme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _fieldValidation['password']! &&
                        _passwordController.text.isNotEmpty
                    ? Colors.green
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ),
        if (_passwordController.text.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: strength / 5,
                  backgroundColor: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _getPasswordStrengthColor(strength)),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                _getPasswordStrengthText(strength),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: _getPasswordStrengthColor(strength),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        if (_passwordController.text.isNotEmpty &&
            !_fieldValidation['password']!) ...[
          SizedBox(height: 0.5.h),
          Text(
            'Senha deve ter pelo menos 8 caracteres, 1 letra maiúscula e 1 número',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(13),
          ],
          onChanged: (value) {
            String formatted = _formatBrazilianPhone(value);
            if (formatted != value) {
              _phoneController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          },
          decoration: InputDecoration(
            labelText: 'Telefone',
            hintText: '+55 (11) 99999-9999',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'phone',
                size: 5.w,
                color: _fieldValidation['phone']! &&
                        _phoneController.text.isNotEmpty
                    ? Colors.green
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            suffixIcon: _phoneController.text.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName:
                          _fieldValidation['phone']! ? 'check_circle' : 'error',
                      size: 5.w,
                      color: _fieldValidation['phone']!
                          ? Colors.green
                          : AppTheme.lightTheme.colorScheme.error,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _fieldValidation['phone']! &&
                        _phoneController.text.isNotEmpty
                    ? Colors.green
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ),
        if (_phoneController.text.isNotEmpty &&
            !_fieldValidation['phone']!) ...[
          SizedBox(height: 0.5.h),
          Text(
            'Digite um número de telefone brasileiro válido',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
              _validateForm();
            });
          },
          activeColor: AppTheme.lightTheme.colorScheme.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
                _validateForm();
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: 3.w),
              child: RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                  children: [
                    const TextSpan(text: 'Eu aceito os '),
                    TextSpan(
                      text: 'Termos de Uso',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' e a '),
                    TextSpan(
                      text: 'Política de Privacidade',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' da Madame Jam'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _isFormValid && !widget.isLoading ? _submitForm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          foregroundColor: _isFormValid
              ? AppTheme.lightTheme.colorScheme.onPrimary
              : AppTheme.lightTheme.colorScheme.outline,
          elevation: _isFormValid ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
                height: 5.w,
                width: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                'Cadastrar',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isFormValid
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _complexController.dispose();
    _buildingController.dispose();
    _apartmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
