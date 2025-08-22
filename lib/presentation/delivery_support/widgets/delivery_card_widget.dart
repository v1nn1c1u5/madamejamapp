import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DeliveryCardWidget extends StatelessWidget {
  final Map<String, dynamic> delivery;
  final VoidCallback? onTap;
  final VoidCallback? onStatusUpdate;
  final VoidCallback? onContactCustomer;
  final VoidCallback? onTrackDelivery;
  final VoidCallback? onReportIssue;

  const DeliveryCardWidget({
    super.key,
    required this.delivery,
    this.onTap,
    this.onStatusUpdate,
    this.onContactCustomer,
    this.onTrackDelivery,
    this.onReportIssue,
  });

  @override
  Widget build(BuildContext context) {
    final customer =
        delivery['customer_profiles'] as Map<String, dynamic>? ?? {};
    final address =
        delivery['customer_addresses'] as Map<String, dynamic>? ?? {};
    final assignedUser =
        delivery['user_profiles'] as Map<String, dynamic>? ?? {};

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: _getStatusColor(delivery['delivery_status'])
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _getStatusIcon(delivery['delivery_status']),
                      color: _getStatusColor(delivery['delivery_status']),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery['delivery_code'] ?? 'Código não informado',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          customer['full_name'] ?? 'Cliente não informado',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(delivery['delivery_status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(delivery['delivery_status']),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'R\$ ${delivery['order_value']?.toStringAsFixed(2) ?? '0,00'}',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.textSecondaryLight,
                  ),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      '${address['street_address'] ?? ''}, ${address['neighborhood'] ?? ''} - ${address['city'] ?? ''}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (assignedUser['full_name'] != null) ...[
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppTheme.textSecondaryLight,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Entregador: ${assignedUser['full_name']}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
              if (delivery['scheduled_date'] != null) ...[
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppTheme.textSecondaryLight,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Agendado: ${_formatDate(delivery['scheduled_date'])}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
              if (delivery['priority_level'] == 'alta' ||
                  delivery['priority_level'] == 'urgente') ...[
                SizedBox(height: 1.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: delivery['priority_level'] == 'urgente'
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: delivery['priority_level'] == 'urgente'
                          ? Colors.red
                          : Colors.orange,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.priority_high,
                        size: 14,
                        color: delivery['priority_level'] == 'urgente'
                            ? Colors.red
                            : Colors.orange,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        delivery['priority_level'] == 'urgente'
                            ? 'URGENTE'
                            : 'PRIORIDADE ALTA',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: delivery['priority_level'] == 'urgente'
                              ? Colors.red
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: 'call',
                    label: 'Contato',
                    onTap: onContactCustomer,
                  ),
                  _buildActionButton(
                    icon: 'update',
                    label: 'Status',
                    onTap: onStatusUpdate,
                  ),
                  _buildActionButton(
                    icon: 'location_on',
                    label: 'Rastrear',
                    onTap: onTrackDelivery,
                  ),
                  _buildActionButton(
                    icon: 'report_problem',
                    label: 'Problema',
                    onTap: onReportIssue,
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    final actionColor = color ?? AppTheme.lightTheme.primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.5.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: actionColor,
              size: 18,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: actionColor,
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'coletado':
        return Colors.blue;
      case 'em_transito':
        return Colors.purple;
      case 'entregue':
        return Colors.green;
      case 'problema':
        return Colors.red;
      case 'cancelado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusIcon(String? status) {
    switch (status) {
      case 'pendente':
        return 'schedule';
      case 'coletado':
        return 'inventory_2';
      case 'em_transito':
        return 'local_shipping';
      case 'entregue':
        return 'check_circle';
      case 'problema':
        return 'report_problem';
      case 'cancelado':
        return 'cancel';
      default:
        return 'help_outline';
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'coletado':
        return 'Coletado';
      case 'em_transito':
        return 'Em Trânsito';
      case 'entregue':
        return 'Entregue';
      case 'problema':
        return 'Problema';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Desconhecido';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now);

      if (difference.inDays == 0) {
        return 'Hoje ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Amanhã ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays > 0) {
        return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}


