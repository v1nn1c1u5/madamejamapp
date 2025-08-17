import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class PaymentOptionsWidget extends StatelessWidget {
  final String selectedPaymentMethod;
  final double discountAmount;
  final String discountReason;
  final ValueChanged<String> onPaymentMethodChanged;
  final Function(double, String) onDiscountChanged;

  const PaymentOptionsWidget({
    super.key,
    required this.selectedPaymentMethod,
    required this.discountAmount,
    required this.discountReason,
    required this.onPaymentMethodChanged,
    required this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section Title
            Row(
              children: [
                Icon(
                  Icons.payment,
                  size: 3.h,
                  color: Color(0xFF8B4513),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Pagamento e Desconto',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Payment Methods
            Text(
              'Forma de Pagamento',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 2.h),

            Column(
              children: [
                _buildPaymentOption(
                  'cash',
                  'Dinheiro',
                  Icons.money,
                  'Pagamento em espécie',
                ),
                SizedBox(height: 2.h),
                _buildPaymentOption(
                  'card',
                  'Cartão',
                  Icons.credit_card,
                  'Débito ou crédito',
                ),
                SizedBox(height: 2.h),
                _buildPaymentOption(
                  'pix',
                  'PIX',
                  Icons.qr_code,
                  'Transferência instantânea',
                ),
                SizedBox(height: 2.h),
                _buildPaymentOption(
                  'reservation',
                  'Reserva de 50%',
                  Icons.account_balance_wallet,
                  'Paga 50% agora, 50% na entrega',
                ),
              ],
            ),

            SizedBox(height: 4.h),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 3.h),

            // Discount Section
            Row(
              children: [
                Icon(
                  Icons.local_offer,
                  size: 2.5.h,
                  color: Color(0xFF8B4513),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Desconto',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showDiscountDialog(context),
                  child: Text(
                    discountAmount > 0 ? 'Alterar' : 'Adicionar',
                    style: GoogleFonts.inter(
                      color: Color(0xFF8B4513),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            if (discountAmount > 0) ...[
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green[600], size: 2.5.h),
                        SizedBox(width: 2.w),
                        Text(
                          'Desconto Aplicado',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '- R\$ ${discountAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    if (discountReason.isNotEmpty) ...[
                      SizedBox(height: 1.h),
                      Text(
                        'Motivo: $discountReason',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () => onDiscountChanged(0.0, ''),
                          child: Text(
                            'Remover Desconto',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: Colors.red[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.grey[500], size: 2.5.h),
                    SizedBox(width: 2.w),
                    Text(
                      'Nenhum desconto aplicado',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Quick Discount Options
              Text(
                'Descontos Rápidos:',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  _buildQuickDiscountChip(
                      context, '5%', 0.05, 'Desconto promocional'),
                  _buildQuickDiscountChip(
                      context, '10%', 0.10, 'Cliente fidelidade'),
                  _buildQuickDiscountChip(
                      context, 'R\$ 5,00', 5.0, 'Desconto fixo'),
                  _buildQuickDiscountChip(
                      context, 'R\$ 10,00', 10.0, 'Cortesia'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      String value, String title, IconData icon, String subtitle) {
    final isSelected = selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () => onPaymentMethodChanged(value),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF8B4513).withAlpha(26) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF8B4513) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF8B4513) : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 3.h,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Color(0xFF8B4513),
                size: 3.h,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDiscountChip(
      BuildContext context, String label, double discount, String reason) {
    return GestureDetector(
      onTap: () {
        double discountValue = discount;

        // If it's a percentage, calculate based on subtotal
        // Note: This would need access to subtotal, which should be passed as parameter
        // For now, using fixed values

        onDiscountChanged(discountValue, reason);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.w),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer, size: 1.5.h, color: Colors.orange[600]),
            SizedBox(width: 1.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiscountDialog(BuildContext context) {
    final discountController = TextEditingController(
      text: discountAmount > 0 ? discountAmount.toString() : '',
    );
    final reasonController = TextEditingController(text: discountReason);
    bool isPercentage = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Aplicar Desconto',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discount Type Toggle
              Row(
                children: [
                  Text(
                    'Tipo:',
                    style: GoogleFonts.inter(
                        fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 2.w),
                  ToggleButtons(
                    isSelected: [!isPercentage, isPercentage],
                    onPressed: (index) {
                      setState(() {
                        isPercentage = index == 1;
                        discountController.clear();
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Text('R\$', style: GoogleFonts.inter()),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Text('%', style: GoogleFonts.inter()),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Discount Value
              TextFormField(
                controller: discountController,
                decoration: InputDecoration(
                  labelText: isPercentage ? 'Porcentagem' : 'Valor em Reais',
                  hintText: isPercentage ? '10' : '5.00',
                  prefixText: isPercentage ? '' : 'R\$ ',
                  suffixText: isPercentage ? '%' : '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
              ),

              SizedBox(height: 2.h),

              // Discount Reason
              TextFormField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Motivo (opcional)',
                  hintText: 'Ex: Cliente fidelidade, promoção...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: GoogleFonts.inter()),
            ),
            ElevatedButton(
              onPressed: () {
                final discountText =
                    discountController.text.replaceAll(',', '.');
                final discountValue = double.tryParse(discountText) ?? 0.0;

                if (discountValue > 0) {
                  double finalDiscount = discountValue;

                  // For percentage discounts, you'd need to calculate based on subtotal
                  // This would require passing subtotal as parameter
                  if (isPercentage) {
                    // finalDiscount = subtotal * (discountValue / 100);
                    // For now, just use the percentage value as fixed amount
                    finalDiscount = discountValue;
                  }

                  onDiscountChanged(finalDiscount, reasonController.text);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B4513),
                foregroundColor: Colors.white,
              ),
              child: Text('Aplicar', style: GoogleFonts.inter()),
            ),
          ],
        ),
      ),
    );
  }
}
