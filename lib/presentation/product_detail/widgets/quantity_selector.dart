import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class QuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final int maxQuantity;
  final Function(int) onQuantityChanged;
  final bool isEnabled;

  const QuantitySelector({
    Key? key,
    this.initialQuantity = 1,
    this.maxQuantity = 10,
    required this.onQuantityChanged,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _decrementQuantity() {
    if (_quantity > 1 && widget.isEnabled) {
      setState(() {
        _quantity--;
      });
      widget.onQuantityChanged(_quantity);
    }
  }

  void _incrementQuantity() {
    if (_quantity < widget.maxQuantity && widget.isEnabled) {
      setState(() {
        _quantity++;
      });
      widget.onQuantityChanged(_quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantidade',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              // Decrement Button
              GestureDetector(
                onTap: _decrementQuantity,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: _quantity > 1 && widget.isEnabled
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.w),
                    boxShadow: widget.isEnabled && _quantity > 1
                        ? [
                            BoxShadow(
                              color: AppTheme.lightTheme.colorScheme.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'remove',
                      color: _quantity > 1 && widget.isEnabled
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.colorScheme.outline,
                      size: 6.w,
                    ),
                  ),
                ),
              ),

              // Quantity Display
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _quantity.toString(),
                    textAlign: TextAlign.center,
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              // Increment Button
              GestureDetector(
                onTap: _incrementQuantity,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: _quantity < widget.maxQuantity && widget.isEnabled
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.w),
                    boxShadow:
                        widget.isEnabled && _quantity < widget.maxQuantity
                            ? [
                                BoxShadow(
                                  color: AppTheme.lightTheme.colorScheme.shadow,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: _quantity < widget.maxQuantity && widget.isEnabled
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.colorScheme.outline,
                      size: 6.w,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Quantity Info
          if (widget.maxQuantity < 10)
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Text(
                'Máximo disponível: ${widget.maxQuantity}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
