import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class DeliveryDetailsWidget extends StatelessWidget {
  final DateTime? deliveryDate;
  final TimeOfDay? deliveryTimeStart;
  final TimeOfDay? deliveryTimeEnd;
  final String deliveryAddress;
  final String specialInstructions;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<TimeOfDay?> onStartTimeChanged;
  final ValueChanged<TimeOfDay?> onEndTimeChanged;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<String> onInstructionsChanged;

  const DeliveryDetailsWidget({
    Key? key,
    required this.deliveryDate,
    required this.deliveryTimeStart,
    required this.deliveryTimeEnd,
    required this.deliveryAddress,
    required this.specialInstructions,
    required this.onDateChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onAddressChanged,
    required this.onInstructionsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delivery Date Section
          Container(
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
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 3.h,
                      color: Color(0xFF8B4513),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Data e Horário de Entrega',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Date Picker
                _buildFormField(
                  label: 'Data de Entrega',
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month,
                              color: Color(0xFF8B4513), size: 2.5.h),
                          SizedBox(width: 3.w),
                          Text(
                            deliveryDate != null
                                ? _formatDate(deliveryDate!)
                                : 'Selecionar data',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: deliveryDate != null
                                  ? Colors.black87
                                  : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // Time Range
                Row(
                  children: [
                    // Start Time
                    Expanded(
                      child: _buildFormField(
                        label: 'Horário Inicial',
                        child: GestureDetector(
                          onTap: () => _selectStartTime(context),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time,
                                    color: Color(0xFF8B4513), size: 2.5.h),
                                SizedBox(width: 2.w),
                                Text(
                                  deliveryTimeStart != null
                                      ? _formatTime(deliveryTimeStart!)
                                      : '--:--',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: deliveryTimeStart != null
                                        ? Colors.black87
                                        : Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 4.w),

                    // End Time
                    Expanded(
                      child: _buildFormField(
                        label: 'Horário Final',
                        child: GestureDetector(
                          onTap: () => _selectEndTime(context),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_filled,
                                    color: Color(0xFF8B4513), size: 2.5.h),
                                SizedBox(width: 2.w),
                                Text(
                                  deliveryTimeEnd != null
                                      ? _formatTime(deliveryTimeEnd!)
                                      : '--:--',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: deliveryTimeEnd != null
                                        ? Colors.black87
                                        : Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Quick Time Options
                SizedBox(height: 3.h),
                Text(
                  'Opções Rápidas:',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: [
                    _buildQuickTimeChip(
                        'Manhã (08:00 - 12:00)',
                        const TimeOfDay(hour: 8, minute: 0),
                        const TimeOfDay(hour: 12, minute: 0)),
                    _buildQuickTimeChip(
                        'Tarde (13:00 - 17:00)',
                        const TimeOfDay(hour: 13, minute: 0),
                        const TimeOfDay(hour: 17, minute: 0)),
                    _buildQuickTimeChip(
                        'Noite (18:00 - 21:00)',
                        const TimeOfDay(hour: 18, minute: 0),
                        const TimeOfDay(hour: 21, minute: 0)),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Delivery Address Section
          Container(
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
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 3.h,
                      color: Color(0xFF8B4513),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Endereço de Entrega',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                _buildFormField(
                  label: 'Endereço Completo',
                  child: TextFormField(
                    initialValue: deliveryAddress,
                    decoration:
                        _inputDecoration('Rua, número, bairro, cidade...'),
                    style: GoogleFonts.inter(fontSize: 14.sp),
                    maxLines: 3,
                    onChanged: onAddressChanged,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Endereço de entrega é obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Special Instructions Section
          Container(
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
                Row(
                  children: [
                    Icon(
                      Icons.sticky_note_2,
                      size: 3.h,
                      color: Color(0xFF8B4513),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Instruções Especiais',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                _buildFormField(
                  label: 'Observações para Entrega',
                  child: TextFormField(
                    initialValue: specialInstructions,
                    decoration: _inputDecoration(
                        'Ex: Entregar na portaria, tocar interfone 101, cuidado com o portão...'),
                    style: GoogleFonts.inter(fontSize: 14.sp),
                    maxLines: 4,
                    onChanged: onInstructionsChanged,
                  ),
                ),

                SizedBox(height: 3.h),

                // Common Instructions
                Text(
                  'Instruções Comuns:',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: [
                    _buildInstructionChip('Entregar na portaria'),
                    _buildInstructionChip('Tocar campainha'),
                    _buildInstructionChip('Ligar antes de entregar'),
                    _buildInstructionChip('Cuidado com animais'),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),
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

  Widget _buildQuickTimeChip(String label, TimeOfDay start, TimeOfDay end) {
    final isSelected = deliveryTimeStart == start && deliveryTimeEnd == end;

    return GestureDetector(
      onTap: () {
        onStartTimeChanged(start);
        onEndTimeChanged(end);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.w),
        decoration: BoxDecoration(
          color:
              isSelected ? Color(0xFF8B4513).withAlpha(26) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF8B4513) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Color(0xFF8B4513) : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionChip(String instruction) {
    return GestureDetector(
      onTap: () {
        final currentInstructions = specialInstructions.trim();
        String newInstructions;

        if (currentInstructions.isEmpty) {
          newInstructions = instruction;
        } else if (currentInstructions.contains(instruction)) {
          return; // Already added
        } else {
          newInstructions = '$currentInstructions; $instruction';
        }

        onInstructionsChanged(newInstructions);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.w),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline,
                size: 1.5.h, color: Colors.blue[600]),
            SizedBox(width: 1.w),
            Text(
              instruction,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 13.sp,
        color: Colors.grey[400],
      ),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF8B4513), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 2.h,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: deliveryDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF8B4513),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: deliveryTimeStart ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF8B4513),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onStartTimeChanged(picked);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: deliveryTimeEnd ?? const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF8B4513),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onEndTimeChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo'
    ];
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekday, ${date.day} de $month de ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
