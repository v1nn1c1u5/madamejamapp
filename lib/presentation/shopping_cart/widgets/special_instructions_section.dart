import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SpecialInstructionsSection extends StatefulWidget {
  final String? instructions;
  final Function(String) onInstructionsChanged;

  const SpecialInstructionsSection({
    Key? key,
    this.instructions,
    required this.onInstructionsChanged,
  }) : super(key: key);

  @override
  State<SpecialInstructionsSection> createState() =>
      _SpecialInstructionsSectionState();
}

class _SpecialInstructionsSectionState
    extends State<SpecialInstructionsSection> {
  late TextEditingController _controller;
  final int maxCharacters = 200;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.instructions ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'edit_note',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Instruções Especiais',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Adicione observações sobre a entrega (opcional)',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _controller,
            maxLines: 4,
            maxLength: maxCharacters,
            onChanged: widget.onInstructionsChanged,
            decoration: InputDecoration(
              hintText: 'Ex: Entregar no portão, apartamento no 3º andar...',
              counterText: '${_controller.text.length}/$maxCharacters',
              counterStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: _controller.text.length > maxCharacters * 0.8
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
