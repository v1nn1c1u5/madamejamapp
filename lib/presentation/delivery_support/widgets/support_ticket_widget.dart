import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SupportTicketWidget extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback? onTap;
  final VoidCallback? onResolve;
  final VoidCallback? onAssign;

  const SupportTicketWidget({
    Key? key,
    required this.ticket,
    this.onTap,
    this.onResolve,
    this.onAssign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customer = ticket['customer_profiles'] as Map<String, dynamic>? ?? {};
    final delivery = ticket['deliveries'] as Map<String, dynamic>? ?? {};

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
                      color: _getPriorityColor(ticket['priority_level'])
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'support_agent',
                      color: _getPriorityColor(ticket['priority_level']),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket['ticket_number'] ?? 'Ticket não identificado',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          ticket['issue_type'] ?? 'Problema não especificado',
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
                          color: _getPriorityColor(ticket['priority_level']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getPriorityText(ticket['priority_level']),
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
                        _formatDate(ticket['created_at']),
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descrição:',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      ticket['description'] ?? 'Sem descrição disponível',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontSize: 11.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              if (customer['full_name'] != null ||
                  delivery['delivery_code'] != null) ...[
                Row(
                  children: [
                    if (customer['full_name'] != null) ...[
                      Icon(
                        Icons.person,
                        size: 16,
                        color: AppTheme.textSecondaryLight,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          customer['full_name'],
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                    if (delivery['delivery_code'] != null) ...[
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.local_shipping,
                        size: 16,
                        color: AppTheme.textSecondaryLight,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        delivery['delivery_code'],
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onAssign,
                      icon: CustomIconWidget(
                        iconName: 'person_add',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 16,
                      ),
                      label: const Text('Atribuir'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onResolve,
                      icon: CustomIconWidget(
                        iconName: 'check_circle',
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text('Resolver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'urgente':
        return Colors.red;
      case 'alta':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'baixa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String? priority) {
    switch (priority) {
      case 'urgente':
        return 'URGENTE';
      case 'alta':
        return 'ALTA';
      case 'normal':
        return 'NORMAL';
      case 'baixa':
        return 'BAIXA';
      default:
        return 'DESCONHECIDA';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return 'há ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return 'há ${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return 'há ${difference.inDays} dias';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
