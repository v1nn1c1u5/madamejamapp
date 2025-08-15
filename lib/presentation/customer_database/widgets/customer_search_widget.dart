import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CustomerSearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onVoicePressed;

  const CustomerSearchWidget({
    Key? key,
    required this.controller,
    this.onVoicePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Buscar por nome, telefone ou email...',
          hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontSize: 12.sp,
          ),
          prefixIcon: CustomIconWidget(
            iconName: 'search',
            color: AppTheme.textSecondaryLight,
            size: 20,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.isNotEmpty)
                IconButton(
                  onPressed: () => controller.clear(),
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    color: AppTheme.textSecondaryLight,
                    size: 20,
                  ),
                ),
              IconButton(
                onPressed: onVoicePressed,
                icon: CustomIconWidget(
                  iconName: 'mic',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        ),
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
