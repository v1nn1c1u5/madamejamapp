import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrderItemWidget extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onStatusUpdate;
  final VoidCallback? onContactCustomer;

  const OrderItemWidget({
    super.key,
    required this.order,
    this.onStatusUpdate,
    this.onContactCustomer,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA726); // Orange/Yellow
      case 'confirmed':
        return const Color(0xFF42A5F5); // Blue
      case 'preparing':
        return const Color(0xFF42A5F5); // Blue
      case 'ready':
        return AppTheme.successLight; // Green
      case 'delivered':
        return AppTheme.successLight; // Green
      case 'cancelled':
        return AppTheme.errorLight; // Red
      default:
        return AppTheme.textSecondaryLight;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendente';
      case 'confirmed':
        return 'Confirmado';
      case 'preparing':
        return 'Preparando';
      case 'ready':
        return 'Pronto';
      case 'delivered':
        return 'Entregue';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Map real database structure to widget display
    final customerData = order['customers'];
    final userProfile = customerData?['user_profiles'];

    final String customerName =
        userProfile?['full_name'] ?? customerData?['full_name'] ?? 'Cliente';
    final double totalAmount = (order['total_amount'] ?? 0.0).toDouble();
    final String orderValue = 'R\$ ${totalAmount.toStringAsFixed(2)}';
    final String status = order['status'] ?? 'pending';

    // Format creation time
    final String time = order['created_at'] != null
        ? _formatTime(DateTime.parse(order['created_at']))
        : '00:00';

    final String orderId = order['id']?.toString() ?? '0';

    return Dismissible(
      key: Key('order_$orderId'),
      background: Container(
        color: AppTheme.successLight.withValues(alpha: 0.2),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: CustomIconWidget(
          iconName: 'check_circle',
          color: AppTheme.successLight,
          size: 24,
        ),
      ),
      secondaryBackground: Container(
        color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: CustomIconWidget(
          iconName: 'phone',
          color: AppTheme.lightTheme.primaryColor,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd &&
            onStatusUpdate != null) {
          onStatusUpdate!();
        } else if (direction == DismissDirection.endToStart &&
            onContactCustomer != null) {
          onContactCustomer!();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    orderValue,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    time,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: onStatusUpdate,
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: AppTheme.successLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.successLight,
                            size: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      GestureDetector(
                        onTap: onContactCustomer,
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'phone',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
