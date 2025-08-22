import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DeliveryMapWidget extends StatefulWidget {
  final List<Map<String, dynamic>> deliveries;
  final Function(Map<String, dynamic>) onDeliveryTap;

  const DeliveryMapWidget({
    super.key,
    required this.deliveries,
    required this.onDeliveryTap,
  });

  @override
  State<DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<DeliveryMapWidget> {
  String _selectedStatus = 'Todos';

  final List<String> _statusOptions = [
    'Todos',
    'Em Trânsito',
    'Pendente',
    'Problema'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMapControls(),
        Expanded(
          child: _buildMapView(),
        ),
        _buildActiveDeliveriesList(),
      ],
    );
  }

  Widget _buildMapControls() {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Entregas Ativas',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'local_shipping',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${_getActiveDeliveries().length} ativas',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 6.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _statusOptions.length,
              separatorBuilder: (context, index) => SizedBox(width: 2.w),
              itemBuilder: (context, index) {
                final status = _statusOptions[index];
                final isSelected = _selectedStatus == status;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.borderLight,
                      ),
                    ),
                    child: Text(
                      status,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textPrimaryLight,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        image: const DecorationImage(
          image: NetworkImage(
              'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&h=600&fit=crop'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Map overlay with delivery markers
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          _buildDeliveryMarkers(),
          _buildMapLegend(),
        ],
      ),
    );
  }

  Widget _buildDeliveryMarkers() {
    final activeDeliveries = _getFilteredDeliveries();

    return Stack(
      children: activeDeliveries.asMap().entries.map((entry) {
        final index = entry.key;
        final delivery = entry.value;

        // Simulate marker positions
        final left = 20.w + (index * 15.w);
        final top = 10.h + (index * 8.h);

        return Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onTap: () => widget.onDeliveryTap(delivery),
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: _getStatusColor(delivery['delivery_status']),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomIconWidget(
                iconName: 'local_shipping',
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMapLegend() {
    return Positioned(
      top: 2.h,
      right: 4.w,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legenda',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 1.h),
            _buildLegendItem('Em Trânsito', Colors.purple),
            _buildLegendItem('Pendente', Colors.orange),
            _buildLegendItem('Problema', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveriesList() {
    final activeDeliveries = _getFilteredDeliveries();

    if (activeDeliveries.isEmpty) {
      return Container(
        height: 20.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'location_off',
              color: AppTheme.textSecondaryLight,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              'Nenhuma entrega ativa',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 20.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              'Rotas Ativas (${activeDeliveries.length})',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: activeDeliveries.length,
              itemBuilder: (context, index) {
                final delivery = activeDeliveries[index];
                final customer =
                    delivery['customer_profiles'] as Map<String, dynamic>? ??
                        {};

                return Container(
                  width: 60.w,
                  margin: EdgeInsets.only(right: 2.w),
                  child: Card(
                    child: InkWell(
                      onTap: () => widget.onDeliveryTap(delivery),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 3.w,
                                  height: 3.w,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                        delivery['delivery_status']),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    delivery['delivery_code'] ?? '',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              customer['full_name'] ?? 'Cliente não informado',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              _getStatusText(delivery['delivery_status']),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: _getStatusColor(
                                    delivery['delivery_status']),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getActiveDeliveries() {
    return widget.deliveries.where((delivery) {
      final status = delivery['delivery_status'] ?? '';
      return ['pendente', 'coletado', 'em_transito', 'problema']
          .contains(status);
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredDeliveries() {
    final activeDeliveries = _getActiveDeliveries();

    if (_selectedStatus == 'Todos') return activeDeliveries;

    return activeDeliveries.where((delivery) {
      final status = delivery['delivery_status'] ?? '';
      switch (_selectedStatus) {
        case 'Em Trânsito':
          return status == 'em_transito';
        case 'Pendente':
          return status == 'pendente';
        case 'Problema':
          return status == 'problema';
        default:
          return true;
      }
    }).toList();
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
}


