import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PixPaymentWidget extends StatefulWidget {
  final double amount;

  const PixPaymentWidget({
    super.key,
    required this.amount,
  });

  @override
  State<PixPaymentWidget> createState() => _PixPaymentWidgetState();
}

class _PixPaymentWidgetState extends State<PixPaymentWidget>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  int _remainingMinutes = 15;
  int _remainingSeconds = 0;

  final String _pixCode =
      "00020126580014BR.GOV.BCB.PIX013636c4e1c8-7e8a-4c5d-9f2b-8a1b2c3d4e5f520400005303986540525.005802BR5925MADAME JAM PADARIA ARTESA6009SAO PAULO62070503***6304A1B2";

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(minutes: 15),
      vsync: this,
    );

    _timerController.addListener(() {
      final totalSeconds = (15 * 60 * (1 - _timerController.value)).round();
      setState(() {
        _remainingMinutes = totalSeconds ~/ 60;
        _remainingSeconds = totalSeconds % 60;
      });
    });

    _timerController.forward();
  }

  void _copyPixCode() {
    Clipboard.setData(ClipboardData(text: _pixCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código PIX copiado para a área de transferência'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Pagamento via PIX',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Timer
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color:
                  AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'timer',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Expira em ${_remainingMinutes.toString().padLeft(2, '0')}:${_remainingSeconds.toString().padLeft(2, '0')}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // QR Code Placeholder
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'qr_code_2',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 80,
                ),
                SizedBox(height: 2.h),
                Text(
                  'QR Code PIX',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          Text(
            'Valor: R\$ ${widget.amount.toStringAsFixed(2).replaceAll('.', ',')}',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),

          SizedBox(height: 3.h),

          // Instructions
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Como pagar:',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                _buildInstructionStep('1. Abra o app do seu banco'),
                _buildInstructionStep('2. Escolha a opção PIX'),
                _buildInstructionStep('3. Escaneie o QR Code ou cole o código'),
                _buildInstructionStep('4. Confirme o pagamento'),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Copy Code Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _copyPixCode,
              icon: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              label: const Text('Copiar Código PIX'),
            ),
          ),

          SizedBox(height: 2.h),

          Text(
            'O pagamento será confirmado automaticamente',
            style: AppTheme.lightTheme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'check_circle_outline',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }
}
