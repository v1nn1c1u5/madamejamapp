import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AdvancedOptionsWidget extends StatelessWidget {
  final TextEditingController preparationTimeController;
  final List<String> allergens;
  final List<String> availableAllergens;
  final bool isGlutenFree;
  final bool isVegan;
  final int? weightGrams;
  final ValueChanged<int?> onPreparationTimeChanged;
  final ValueChanged<String> onAllergenToggle;
  final ValueChanged<bool?> onGlutenFreeChanged;
  final ValueChanged<bool?> onVeganChanged;
  final ValueChanged<int?> onWeightChanged;

  const AdvancedOptionsWidget({
    super.key,
    required this.preparationTimeController,
    required this.allergens,
    required this.availableAllergens,
    required this.isGlutenFree,
    required this.isVegan,
    required this.weightGrams,
    required this.onPreparationTimeChanged,
    required this.onAllergenToggle,
    required this.onGlutenFreeChanged,
    required this.onVeganChanged,
    required this.onWeightChanged,
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
                Icons.tune,
                size: 3.h,
                color: Color(0xFF8B4513),
              ),
              SizedBox(width: 2.w),
              Text(
                'Opções Avançadas',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Preparation Time and Weight Row
          Row(
            children: [
              // Preparation Time
              Expanded(
                child: _buildFormField(
                  label: 'Tempo de Preparo (min)',
                  child: TextFormField(
                    controller: preparationTimeController,
                    decoration: _inputDecoration('30'),
                    style: GoogleFonts.inter(fontSize: 14.sp),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      final time = int.tryParse(value);
                      onPreparationTimeChanged(time);
                    },
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final time = int.tryParse(value);
                        if (time == null || time <= 0) {
                          return 'Tempo inválido';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Weight
              Expanded(
                child: _buildFormField(
                  label: 'Peso (gramas)',
                  child: TextFormField(
                    decoration: _inputDecoration('500'),
                    style: GoogleFonts.inter(fontSize: 14.sp),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      final weight = int.tryParse(value);
                      onWeightChanged(weight);
                    },
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final weight = int.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Peso inválido';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Dietary Options
          _buildFormField(
            label: 'Opções Dietéticas',
            child: Column(
              children: [
                // Gluten Free Toggle
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isGlutenFree ? Colors.green[50] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isGlutenFree ? Colors.green[200]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color:
                            isGlutenFree ? Colors.green[600] : Colors.grey[600],
                        size: 2.5.h,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Sem Glúten',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Switch(
                        value: isGlutenFree,
                        onChanged: onGlutenFreeChanged,
                        activeColor: Colors.green[600],
                        activeTrackColor: Colors.green[200],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                // Vegan Toggle
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isVegan ? Colors.green[50] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isVegan ? Colors.green[200]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.eco,
                        color: isVegan ? Colors.green[600] : Colors.grey[600],
                        size: 2.5.h,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Vegano',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Switch(
                        value: isVegan,
                        onChanged: onVeganChanged,
                        activeColor: Colors.green[600],
                        activeTrackColor: Colors.green[200],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Allergens Section
          _buildFormField(
            label: 'Alérgenos',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecione os alérgenos presentes no produto:',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: availableAllergens.map((allergen) {
                    final isSelected = allergens.contains(allergen);
                    return GestureDetector(
                      onTap: () => onAllergenToggle(allergen),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.5.w,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red[50] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.red[300]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Icon(
                                Icons.warning,
                                size: 2.h,
                                color: Colors.red[600],
                              ),
                            if (isSelected) SizedBox(width: 1.w),
                            Text(
                              allergen,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? Colors.red[700]
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Selected Allergens Summary
                if (allergens.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.red[600],
                          size: 2.5.h,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contém Alérgenos:',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                allergens.join(', '),
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
          ),

          SizedBox(height: 2.h),

          // Info Box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 2.5.h,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'As informações de alérgenos e opções dietéticas são importantes para clientes com restrições alimentares.',
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 2.h,
      ),
    );
  }
}
