import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EditFormWidget extends StatefulWidget {
  final Map<String, dynamic> customer;
  final Function(Map<String, String>) onFormSubmit;
  final bool isLoading;

  const EditFormWidget({
    super.key,
    required this.customer,
    required this.onFormSubmit,
    required this.isLoading,
  });

  @override
  State<EditFormWidget> createState() => _EditFormWidgetState();
}

class _EditFormWidgetState extends State<EditFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _complexController = TextEditingController();
  final _buildingController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isFormValid = false;
  bool _isActive = true;
  bool _isVip = false;

  // Validation states
  final Map<String, bool> _fieldValidation = {
    'fullName': true,
    'email': true,
    'phone': true, // Phone is optional
    'complex': true, // Address fields are optional
    'building': true,
    'apartment': true,
    'city': true,
    'state': true,
    'postalCode': true,
  };

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
    _setupFormListeners();
  }

  void _loadCustomerData() {
    final userProfile =
        widget.customer['user_profiles'] as Map<String, dynamic>? ?? {};

    // Load user profile data
    _fullNameController.text = userProfile['full_name']?.toString() ?? '';
    _emailController.text = userProfile['email']?.toString() ?? '';
    _isActive = userProfile['is_active'] ?? true;

    // Load customer data
    _phoneController.text = widget.customer['phone']?.toString() ?? '';
    _isVip = widget.customer['is_vip'] ?? false;

    // Parse address fields
    final addressLine1 = widget.customer['address_line1']?.toString() ?? '';
    final addressLine2 = widget.customer['address_line2']?.toString() ?? '';

    _complexController.text = addressLine1;

    // Try to parse building and apartment from address_line2
    if (addressLine2.isNotEmpty) {
      final parts = addressLine2.split(', ');
      if (parts.length >= 2) {
        _buildingController.text = parts[0];
        _apartmentController.text = parts[1];
      } else {
        _buildingController.text = addressLine2;
      }
    }

    _cityController.text = widget.customer['city']?.toString() ?? '';
    _stateController.text = widget.customer['state']?.toString() ?? '';
    _postalCodeController.text =
        widget.customer['postal_code']?.toString() ?? '';
    _notesController.text = widget.customer['delivery_notes']?.toString() ?? '';

    _validateForm();
  }

  void _setupFormListeners() {
    _fullNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _complexController.addListener(_validateForm);
    _buildingController.addListener(_validateForm);
    _apartmentController.addListener(_validateForm);
    _cityController.addListener(_validateForm);
    _stateController.addListener(_validateForm);
    _postalCodeController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _fieldValidation['fullName'] =
          _fullNameController.text.trim().length >= 2;
      _fieldValidation['email'] = _isValidEmail(_emailController.text);
      _fieldValidation['phone'] = _phoneController.text.isEmpty ||
          _isValidBrazilianPhone(_phoneController.text);
      _fieldValidation['complex'] = true; // Optional
      _fieldValidation['building'] = true; // Optional
      _fieldValidation['apartment'] = true; // Optional
      _fieldValidation['city'] = true; // Optional
      _fieldValidation['state'] = true; // Optional
      _fieldValidation['postalCode'] = _postalCodeController.text.isEmpty ||
          _isValidBrazilianPostalCode(_postalCodeController.text);

      _isFormValid = _fieldValidation.values.every((isValid) => isValid);
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidBrazilianPhone(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length == 10 || cleanPhone.length == 11;
  }

  bool _isValidBrazilianPostalCode(String postalCode) {
    String cleanCode = postalCode.replaceAll(RegExp(r'[^\d]'), '');
    return cleanCode.length == 8;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _isFormValid) {
      final formData = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'isActive': _isActive.toString(),
        'isVip': _isVip.toString(),
        'phone': _phoneController.text.trim(),
        'complex': _complexController.text.trim(),
        'building': _buildingController.text.trim(),
        'apartment': _apartmentController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'notes': _notesController.text.trim(),
      };

      print('Form submitting with data: $formData');
      print('isActive value: $_isActive');
      print('isVip value: $_isVip');

      widget.onFormSubmit(formData);
    } else {
      print('Form validation failed. isFormValid: $_isFormValid');
      print('Field validations: $_fieldValidation');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _complexController.dispose();
    _buildingController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Profile Section
          _buildSectionTitle('Informações Pessoais'),
          SizedBox(height: 1.h),

          _buildTextField(
            controller: _fullNameController,
            label: 'Nome Completo *',
            hintText: 'Ex: Maria Silva Santos',
            isValid: _fieldValidation['fullName']!,
            errorMessage: 'Nome deve ter pelo menos 2 caracteres',
            prefixIcon: 'person',
          ),

          SizedBox(height: 2.h),

          _buildTextField(
            controller: _emailController,
            label: 'Email *',
            hintText: 'exemplo@email.com',
            keyboardType: TextInputType.emailAddress,
            isValid: _fieldValidation['email']!,
            errorMessage: 'Email deve ter um formato válido',
            prefixIcon: 'email',
          ),

          SizedBox(height: 2.h),

          // Status Switches
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status do Cliente',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: _isActive ? 'check_circle' : 'cancel',
                            color: _isActive ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Cliente Ativo',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: widget.isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                        activeColor: AppTheme.lightTheme.primaryColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: _isVip ? 'star' : 'star_border',
                            color: _isVip ? Colors.amber : Colors.grey,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Cliente VIP',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isVip,
                        onChanged: widget.isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _isVip = value;
                                });
                              },
                        activeColor: Colors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Phone Field
          _buildSectionTitle('Contato'),
          SizedBox(height: 1.h),
          _buildTextField(
            controller: _phoneController,
            label: 'Telefone',
            hintText: '(11) 99999-9999',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            isValid: _fieldValidation['phone']!,
            errorMessage: 'Telefone deve ter 10 ou 11 dígitos',
            prefixIcon: 'phone',
          ),

          SizedBox(height: 3.h),

          // Address Section
          _buildSectionTitle('Endereço'),
          SizedBox(height: 1.h),

          _buildTextField(
            controller: _complexController,
            label: 'Condomínio/Residencial',
            hintText: 'Ex: Residencial Jardim das Flores',
            isValid: _fieldValidation['complex']!,
            prefixIcon: 'location_city',
          ),

          SizedBox(height: 2.h),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _buildingController,
                  label: 'Bloco/Prédio',
                  hintText: 'Ex: Bloco A',
                  isValid: _fieldValidation['building']!,
                  prefixIcon: 'business',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildTextField(
                  controller: _apartmentController,
                  label: 'Apartamento',
                  hintText: 'Ex: Apto 205',
                  isValid: _fieldValidation['apartment']!,
                  prefixIcon: 'home',
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _cityController,
                  label: 'Cidade',
                  hintText: 'Ex: São Paulo',
                  isValid: _fieldValidation['city']!,
                  prefixIcon: 'location_on',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'Estado',
                  hintText: 'Ex: SP',
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(2),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                  ],
                  isValid: _fieldValidation['state']!,
                  prefixIcon: 'map',
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          _buildTextField(
            controller: _postalCodeController,
            label: 'CEP',
            hintText: '12345-678',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            isValid: _fieldValidation['postalCode']!,
            errorMessage: 'CEP deve ter 8 dígitos',
            prefixIcon: 'local_post_office',
          ),

          SizedBox(height: 3.h),

          // Delivery Notes
          _buildSectionTitle('Observações de Entrega'),
          SizedBox(height: 1.h),

          _buildTextField(
            controller: _notesController,
            label: 'Notas para entrega',
            hintText: 'Ex: Portão azul, interfone 205',
            maxLines: 3,
            prefixIcon: 'note',
          ),

          SizedBox(height: 4.h),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isFormValid && !widget.isLoading ? _submitForm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
                disabledBackgroundColor:
                    AppTheme.lightTheme.colorScheme.outline,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.surface,
                        ),
                      ),
                    )
                  : Text(
                      'Atualizar Cliente',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryLight,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool isValid = true,
    String? errorMessage,
    String? prefixIcon,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          enabled: !widget.isLoading,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: prefixIcon,
                      color: isValid
                          ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          : AppTheme.errorLight,
                      size: 5.w,
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppTheme.lightTheme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isValid
                    ? AppTheme.lightTheme.colorScheme.outline
                    : AppTheme.errorLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isValid
                    ? AppTheme.lightTheme.colorScheme.outline
                    : AppTheme.errorLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isValid
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.errorLight,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.errorLight,
              ),
            ),
            hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.6),
            ),
          ),
        ),
        if (!isValid && errorMessage != null)
          Padding(
            padding: EdgeInsets.only(top: 0.5.h, left: 3.w),
            child: Text(
              errorMessage,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.errorLight,
              ),
            ),
          ),
      ],
    );
  }
}
