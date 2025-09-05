import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/customer_service.dart';
import './widgets/edit_form_widget.dart';

class CustomerEdit extends StatefulWidget {
  final Map<String, dynamic> customer;

  const CustomerEdit({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerEdit> createState() => _CustomerEditState();
}

class _CustomerEditState extends State<CustomerEdit> {
  bool _isLoading = false;
  String? _errorMessage;

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
      // Extract data for update
      final customerId = widget.customer['id'];
      final userProfile =
          widget.customer['user_profiles'] as Map<String, dynamic>? ?? {};
      final userProfileId = userProfile['id'];

      // Debug: Print form data
      print('Form data received: $formData');
      print('User profile ID: $userProfileId');

      // Update user profile data (name, email, status)
      if (userProfileId != null) {
        final fullName = formData['fullName']?.trim();
        final email = formData['email']?.trim();
        final isActive = formData['isActive'] == 'true';

        print(
            'Updating profile with: fullName=$fullName, email=$email, isActive=$isActive');

        // Only update if we have valid data
        if (fullName != null && fullName.isNotEmpty) {
          await CustomerService.instance.updateCustomerProfile(
            userProfileId: userProfileId,
            fullName: fullName,
            email: email != null && email.isNotEmpty ? email : null,
            isActive: isActive,
          );
        }
      }

      // Update customer data (address, phone, etc.)
      final isVip = formData['isVip'] == 'true';
      print('Updating customer with isVip: $isVip');

      await CustomerService.instance.updateCustomer(
        customerId: customerId,
        phone: formData['phone']?.trim(),
        addressLine1: formData['complex']?.trim(),
        addressLine2:
            '${formData['building']?.trim()}, ${formData['apartment']?.trim()}',
        city: formData['city']?.trim(),
        state: formData['state']?.trim(),
        postalCode: formData['postalCode']?.trim(),
        deliveryNotes: formData['notes']?.trim().isNotEmpty == true
            ? formData['notes']?.trim()
            : null,
        isVip: isVip,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (error) {
      print('Error updating customer: $error');
      _showErrorMessage('Erro ao atualizar cliente: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 4.h),
              if (_errorMessage != null) _buildErrorMessage(),
              EditFormWidget(
                customer: widget.customer,
                onFormSubmit: _handleFormSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back_ios',
          color: AppTheme.textPrimaryLight,
          size: 24,
        ),
      ),
      title: Text(
        'Editar Cliente',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final userProfile =
        widget.customer['user_profiles'] as Map<String, dynamic>? ?? {};
    final fullName = userProfile['full_name']?.toString() ?? 'Cliente';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editando: $fullName',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 24.sp,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Atualize as informações do cliente',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: AppTheme.errorLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'error',
            color: AppTheme.errorLight,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.errorLight,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
