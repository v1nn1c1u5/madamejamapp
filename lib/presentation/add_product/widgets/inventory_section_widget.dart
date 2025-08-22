import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class InventorySectionWidget extends StatelessWidget {
  final int stockQuantity;
  final int minStockLevel;
  final bool isAvailable;
  final ValueChanged<int> onStockQuantityChanged;
  final ValueChanged<int> onMinStockChanged;
  final ValueChanged<bool?> onAvailabilityChanged;

  const InventorySectionWidget({
    super.key,
    required this.stockQuantity,
    required this.minStockLevel,
    required this.isAvailable,
    required this.onStockQuantityChanged,
    required this.onMinStockChanged,
    required this.onAvailabilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 3.h,
                color: Color(0xFF8B4513),
              ),
              SizedBox(width: 2.w),
              Text(
                'Controle de Estoque',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Stock Quantity
          _buildFormField(
            label: 'Quantidade em Estoque',
            child: Row(
              children: [
                // Decrease Button
                Container(
                  width: 10.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color:
                        stockQuantity > 0 ? Colors.red[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: stockQuantity > 0
                          ? Colors.red[300]!
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: IconButton(
                    onPressed: stockQuantity > 0
                        ? () => onStockQuantityChanged(stockQuantity - 1)
                        : null,
                    icon: Icon(
                      Icons.remove,
                      color: stockQuantity > 0
                          ? Colors.red[600]
                          : Colors.grey[400],
                      size: 2.5.h,
                    ),
                  ),
                ),

                SizedBox(width: 4.w),

                // Quantity Display
                Expanded(
                  child: Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        '$stockQuantity unidades',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 4.w),

                // Increase Button
                Container(
                  width: 10.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: IconButton(
                    onPressed: () => onStockQuantityChanged(stockQuantity + 1),
                    icon: Icon(
                      Icons.add,
                      color: Colors.green[600],
                      size: 2.5.h,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Min Stock Level
          _buildFormField(
            label: 'Estoque Mínimo (Alerta)',
            child: Row(
              children: [
                // Decrease Button
                Container(
                  width: 10.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color:
                        minStockLevel > 0 ? Colors.red[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: minStockLevel > 0
                          ? Colors.red[300]!
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: IconButton(
                    onPressed: minStockLevel > 0
                        ? () => onMinStockChanged(minStockLevel - 1)
                        : null,
                    icon: Icon(
                      Icons.remove,
                      color: minStockLevel > 0
                          ? Colors.red[600]
                          : Colors.grey[400],
                      size: 2.5.h,
                    ),
                  ),
                ),

                SizedBox(width: 4.w),

                // Min Stock Display
                Expanded(
                  child: Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        '$minStockLevel unidades',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 4.w),

                // Increase Button
                Container(
                  width: 10.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: IconButton(
                    onPressed: () => onMinStockChanged(minStockLevel + 1),
                    icon: Icon(
                      Icons.add,
                      color: Colors.green[600],
                      size: 2.5.h,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Availability Toggle
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isAvailable ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAvailable ? Colors.green[200]! : Colors.orange[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isAvailable ? Icons.check_circle : Icons.pause_circle,
                  color: isAvailable ? Colors.green[600] : Colors.orange[600],
                  size: 3.h,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disponibilidade',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        isAvailable
                            ? 'Produto disponível para venda'
                            : 'Produto indisponível para venda',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isAvailable,
                  onChanged: onAvailabilityChanged,
                  activeColor: Colors.green[600],
                  activeTrackColor: Colors.green[200],
                  inactiveThumbColor: Colors.orange[600],
                  inactiveTrackColor: Colors.orange[200],
                ),
              ],
            ),
          ),

          // Stock Status Alert
          if (stockQuantity <= minStockLevel) ...[
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.red[600],
                    size: 3.h,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estoque Baixo!',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700],
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'O estoque atual está igual ou abaixo do nível mínimo configurado.',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 1.h),
        child,
      ],
    );
  }
}
