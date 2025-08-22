import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MetricsCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String changePercentage;
  final bool isPositive;
  final Color cardColor;
  final String iconName;

  const MetricsCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.changePercentage,
    required this.isPositive,
    required this.cardColor,
    required this.iconName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 12.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                    fontSize: 10.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: AppTheme.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              CustomIconWidget(
                iconName: isPositive ? 'trending_up' : 'trending_down',
                color: isPositive ? AppTheme.successLight : AppTheme.errorLight,
                size: 14,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  '$changePercentage% vs ontem',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isPositive
                        ? AppTheme.successLight
                        : AppTheme.errorLight,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


