import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class OrderStatusChip extends StatelessWidget {
  final String status;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const OrderStatusChip({
    Key? key,
    required this.status,
    required this.count,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pendentes':
        return const Color(0xFFFFA726);
      case 'em preparo':
        return const Color(0xFF42A5F5);
      case 'entregues':
        return const Color(0xFF66BB6A);
      case 'cancelados':
        return const Color(0xFFEF5350);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 2.w),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? statusColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: statusColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 1.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : statusColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: isSelected ? statusColor : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 9.sp,
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
