import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CustomerCardWidget extends StatelessWidget {
  final Map<String, dynamic> customer;
  final VoidCallback? onTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onOrderTap;

  const CustomerCardWidget({
    super.key,
    required this.customer,
    this.onTap,
    this.onMessageTap,
    this.onCallTap,
    this.onEditTap,
    this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    // DEBUG: printar o objeto customer recebido
    // ignore: avoid_print
    print('[CustomerCardWidget] customer: $customer');
    // Fallbacks: aceitar dados flatten ou aninhados em user_profiles
    final userProfiles = customer['user_profiles'] as Map<String, dynamic>?;
    final fullName = (customer['full_name'] ?? userProfiles?['full_name'] ?? '')
        .toString()
        .trim();
    final email =
        (customer['email'] ?? userProfiles?['email'] ?? '').toString().trim();
    final phone = (customer['phone'] ?? '').toString();
    // Derivar status caso 'customer_status' não exista
    final customerStatus = customer['customer_status'] ??
        (customer['is_vip'] == true
            ? 'vip'
            : (customer['is_active'] == false ||
                    (userProfiles?['is_active'] == false))
                ? 'inativo'
                : 'ativo');
    String avatarLetter = 'C';
    if (fullName.isNotEmpty) {
      avatarLetter = fullName.characters.first.toUpperCase();
    }
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
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                    child: Text(
                      avatarLetter,
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName.isNotEmpty ? fullName : 'Nome não informado',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          customer['customer_code'] ?? '',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(customerStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(customerStatus),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: AppTheme.textSecondaryLight,
                  ),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      phone.isNotEmpty ? phone : 'Telefone não informado',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 16,
                    color: AppTheme.textSecondaryLight,
                  ),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      email.isNotEmpty ? email : 'Email não informado',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Gasto',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                      Text(
                        'R\$ ${customer['total_spent']?.toStringAsFixed(2) ?? '0,00'}',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Pedidos',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                      Text(
                        '${customer['total_orders'] ?? 0}',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (customer['last_order_date'] != null) ...[
                SizedBox(height: 1.h),
                Text(
                  'Último pedido: ${_formatDate(customer['last_order_date'])}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                    fontSize: 10.sp,
                  ),
                ),
              ],
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: 'message',
                    label: 'Msg',
                    onTap: onMessageTap,
                  ),
                  _buildActionButton(
                    icon: 'call',
                    label: 'Ligar',
                    onTap: onCallTap,
                  ),
                  _buildActionButton(
                    icon: 'shopping_cart',
                    label: 'Pedido',
                    onTap: onOrderTap,
                  ),
                  _buildActionButton(
                    icon: 'edit',
                    label: 'Editar',
                    onTap: onEditTap,
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
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
      case 'vip':
        return Colors.purple;
      case 'ativo':
        return Colors.green;
      case 'inativo':
        return Colors.orange;
      case 'bloqueado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'vip':
        return 'VIP';
      case 'ativo':
        return 'Ativo';
      case 'inativo':
        return 'Inativo';
      case 'bloqueado':
        return 'Bloqueado';
      default:
        return 'Desconhecido';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Hoje';
      } else if (difference == 1) {
        return 'Ontem';
      } else if (difference < 7) {
        return 'há $difference dias';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
