import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyCustomersWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showAddButton;
  final VoidCallback? onAddPressed;

  const EmptyCustomersWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.showAddButton = true,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'people_outline',
                color: AppTheme.lightTheme.primaryColor,
                size: 60,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
            ),
            if (showAddButton && onAddPressed != null) ...[
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: CustomIconWidget(
                  iconName: 'person_add',
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text('Adicionar Cliente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


