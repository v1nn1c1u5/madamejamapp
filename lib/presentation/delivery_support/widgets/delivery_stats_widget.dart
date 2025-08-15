import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DeliveryStatsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> deliveries;

  const DeliveryStatsWidget({
    Key? key,
    required this.deliveries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do Dia',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  stats['total'].toString(),
                  'local_shipping',
                  AppTheme.lightTheme.primaryColor,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  'Entregues',
                  stats['delivered'].toString(),
                  'check_circle',
                  Colors.green,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  'Em Rota',
                  stats['inTransit'].toString(),
                  'navigation',
                  Colors.purple,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  'Problemas',
                  stats['problems'].toString(),
                  'report_problem',
                  Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPerformanceIndicator(
                'Taxa de Sucesso',
                '${stats['successRate'].toStringAsFixed(1)}%',
                stats['successRate'] >= 90
                    ? Colors.green
                    : stats['successRate'] >= 75
                        ? Colors.orange
                        : Colors.red,
              ),
              _buildPerformanceIndicator(
                'Tempo Médio',
                '${stats['avgDeliveryTime']} min',
                AppTheme.textSecondaryLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18.sp,
            ),
          ),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontSize: 9.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicator(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateStats() {
    final today = DateTime.now();
    final todayDeliveries = deliveries.where((delivery) {
      final createdAt = DateTime.tryParse(delivery['created_at'] ?? '');
      return createdAt != null &&
          createdAt.year == today.year &&
          createdAt.month == today.month &&
          createdAt.day == today.day;
    }).toList();

    final total = todayDeliveries.length;
    final delivered =
        todayDeliveries.where((d) => d['delivery_status'] == 'entregue').length;
    final inTransit = todayDeliveries
        .where((d) => d['delivery_status'] == 'em_transito')
        .length;
    final problems =
        todayDeliveries.where((d) => d['delivery_status'] == 'problema').length;

    final successRate = total > 0 ? (delivered / total) * 100 : 0.0;

    // Simulate average delivery time calculation
    final avgDeliveryTime =
        total > 0 ? 35 + (problems * 15) - (delivered * 5) : 0;

    return {
      'total': total,
      'delivered': delivered,
      'inTransit': inTransit,
      'problems': problems,
      'successRate': successRate,
      'avgDeliveryTime': avgDeliveryTime.clamp(20, 120),
    };
  }
}
