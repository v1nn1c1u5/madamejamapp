import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class CartSummaryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double discountAmount;
  final double total;

  const CartSummaryWidget({
    Key? key,
    required this.cartItems,
    required this.subtotal,
    required this.discountAmount,
    required this.total,
  }) : super(key: key);

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
                Icons.receipt_long,
                size: 3.h,
                color: Color(0xFF8B4513),
              ),
              SizedBox(width: 2.w),
              Text(
                'Resumo do Pedido',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Cart Items
          if (cartItems.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.w),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 8.h,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Nenhum produto adicionado',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Volte para a aba de produtos para adicionar itens ao pedido',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                // Items List
                ...cartItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildCartItem(item, index);
                }).toList(),

                SizedBox(height: 3.h),
                Divider(color: Colors.grey[300]),
                SizedBox(height: 2.h),

                // Order Totals
                _buildTotalRow('Subtotal:', subtotal, isSubtotal: true),

                if (discountAmount > 0) ...[
                  SizedBox(height: 1.h),
                  _buildTotalRow('Desconto:', -discountAmount,
                      isDiscount: true),
                ],

                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 2.h),

                _buildTotalRow('Total:', total, isTotal: true),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    // Handle potential type conversion issues
    double quantity = (item['quantity'] ?? 0).toDouble();
    double unitPrice = (item['price'] ?? 0).toDouble();
    double totalPrice = (item['total_price'] ?? 0).toDouble();
    String productName = item['name'] ?? 'Produto sem nome';
    String specialInstructions = item['special_instructions'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Text(
                          '${quantity.toInt()}x',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'R\$ ${unitPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                'R\$ ${totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B4513),
                ),
              ),
            ],
          ),

          // Special Instructions
          if (specialInstructions.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.note_alt, color: Colors.blue[600], size: 2.h),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Obs: $specialInstructions',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.blue[700],
                      ),
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

  Widget _buildTotalRow(String label, double amount,
      {bool isSubtotal = false,
      bool isDiscount = false,
      bool isTotal = false}) {
    Color textColor = Colors.black87;
    FontWeight fontWeight = FontWeight.w500;
    double fontSize = 14.sp;

    if (isDiscount) {
      textColor = Colors.red[600]!;
    } else if (isTotal) {
      textColor = Color(0xFF8B4513);
      fontWeight = FontWeight.w700;
      fontSize = 18.sp;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
        Text(
          'R\$ ${amount.abs().toStringAsFixed(2)}',
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
