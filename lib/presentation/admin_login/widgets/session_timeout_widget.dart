import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SessionTimeoutWidget extends StatelessWidget {
  final bool showTimeoutWarning;
  final int timeoutCountdown;
  final VoidCallback onExtendSession;
  final VoidCallback onLogout;

  const SessionTimeoutWidget({
    super.key,
    required this.showTimeoutWarning,
    required this.timeoutCountdown,
    required this.onExtendSession,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    if (!showTimeoutWarning) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'access_time',
                color: Colors.orange,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Sessão expirando em breve',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Sua sessão expirará em $timeoutCountdown segundos por inatividade.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.orange.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onLogout,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.orange),
                    foregroundColor: Colors.orange.shade700,
                  ),
                  child: Text('Sair'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onExtendSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Estender Sessão'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
