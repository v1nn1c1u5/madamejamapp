import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ProductFormWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController costPriceController;
  final List<Map<String, dynamic>> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;

  const ProductFormWidget({
    Key? key,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.costPriceController,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
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
                Icons.info_outline,
                size: 3.h,
                color: Color(0xFF8B4513),
              ),
              SizedBox(width: 2.w),
              Text(
                'Informações do Produto',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Product Name Field
          _buildFormField(
            label: 'Nome do Produto',
            child: TextFormField(
              controller: nameController,
              decoration: _inputDecoration('Ex: Pão Francês Artesanal'),
              style: GoogleFonts.inter(fontSize: 14.sp),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome do produto é obrigatório';
                }
                if (value.trim().length < 2) {
                  return 'Nome deve ter pelo menos 2 caracteres';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
          ),

          SizedBox(height: 3.h),

          // Product Description Field
          _buildFormField(
            label: 'Descrição',
            child: TextFormField(
              controller: descriptionController,
              decoration: _inputDecoration(
                  'Descreva os detalhes, ingredientes e características do produto...'),
              style: GoogleFonts.inter(fontSize: 14.sp),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value != null && value.length > 500) {
                  return 'Descrição não pode exceder 500 caracteres';
                }
                return null;
              },
            ),
          ),

          SizedBox(height: 3.h),

          // Category Dropdown
          _buildFormField(
            label: 'Categoria',
            child: DropdownButtonFormField<String>(
              value: selectedCategoryId,
              decoration: _inputDecoration('Selecione a categoria'),
              style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black87),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: onCategoryChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Categoria é obrigatória';
                }
                return null;
              },
              dropdownColor: Colors.white,
              icon: Icon(Icons.arrow_drop_down, color: Color(0xFF8B4513)),
            ),
          ),

          SizedBox(height: 3.h),

          // Price Fields Row
          Row(
            children: [
              // Sale Price
              Expanded(
                flex: 3,
                child: _buildFormField(
                  label: 'Preço de Venda (R\$)',
                  child: TextFormField(
                    controller: priceController,
                    decoration: _inputDecoration('0,00'),
                    style: GoogleFonts.inter(fontSize: 14.sp),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Preço é obrigatório';
                      }
                      final price = double.tryParse(value.replaceAll(',', '.'));
                      if (price == null || price <= 0) {
                        return 'Preço deve ser maior que zero';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Cost Price (Optional)
              Expanded(
                flex: 2,
                child: _buildFormField(
                  label: 'Custo (Opcional)',
                  child: TextFormField(
                    controller: costPriceController,
                    decoration: _inputDecoration('0,00'),
                    style: GoogleFonts.inter(fontSize: 14.sp),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final cost =
                            double.tryParse(value.replaceAll(',', '.'));
                        if (cost == null || cost < 0) {
                          return 'Custo inválido';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Price Calculation Helper
          if (priceController.text.isNotEmpty &&
              costPriceController.text.isNotEmpty)
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withAlpha(77)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calculate, color: Colors.green[600], size: 2.h),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final price = double.tryParse(
                                priceController.text.replaceAll(',', '.')) ??
                            0;
                        final cost = double.tryParse(costPriceController.text
                                .replaceAll(',', '.')) ??
                            0;
                        final margin =
                            price > 0 ? ((price - cost) / price * 100) : 0;
                        final profit = price - cost;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Margem de Lucro: ${margin.toStringAsFixed(1)}%',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.green[700],
                              ),
                            ),
                            Text(
                              'Lucro por unidade: R\$ ${profit.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        );
                      },
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
