import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class FilterModalWidget extends StatefulWidget {
  final RangeValues priceRange;
  final bool showAvailableOnly;
  final Function(RangeValues, bool) onFiltersChanged;

  const FilterModalWidget({
    Key? key,
    required this.priceRange,
    required this.showAvailableOnly,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late RangeValues _currentPriceRange;
  late bool _currentShowAvailableOnly;
  bool _isPriceExpanded = true;
  bool _isAvailabilityExpanded = true;

  @override
  void initState() {
    super.initState();
    _currentPriceRange = widget.priceRange;
    _currentShowAvailableOnly = widget.showAvailableOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentPriceRange = const RangeValues(0, 200);
                    _currentShowAvailableOnly = false;
                  });
                },
                child: Text(
                  'Limpar',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Price range filter
                  _buildExpandableSection(
                    title: 'Faixa de Preço',
                    isExpanded: _isPriceExpanded,
                    onToggle: () {
                      setState(() {
                        _isPriceExpanded = !_isPriceExpanded;
                      });
                    },
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'R\$ ${_currentPriceRange.start.round()}',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'R\$ ${_currentPriceRange.end.round()}',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        RangeSlider(
                          values: _currentPriceRange,
                          min: 0,
                          max: 200,
                          divisions: 20,
                          activeColor: AppTheme.lightTheme.colorScheme.primary,
                          inactiveColor: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                          onChanged: (RangeValues values) {
                            setState(() {
                              _currentPriceRange = values;
                            });
                          },
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'R\$ 0',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'R\$ 200+',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Availability filter
                  _buildExpandableSection(
                    title: 'Disponibilidade',
                    isExpanded: _isAvailabilityExpanded,
                    onToggle: () {
                      setState(() {
                        _isAvailabilityExpanded = !_isAvailabilityExpanded;
                      });
                    },
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Switch(
                              value: _currentShowAvailableOnly,
                              onChanged: (bool value) {
                                setState(() {
                                  _currentShowAvailableOnly = value;
                                });
                              },
                              activeColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                'Mostrar apenas produtos disponíveis',
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
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
          ),
          // Apply button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: ElevatedButton(
              onPressed: () {
                widget.onFiltersChanged(
                    _currentPriceRange, _currentShowAvailableOnly);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Aplicar Filtros',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    size: 24,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: child,
            ),
          if (isExpanded) SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
