import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductImageUploadWidget extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onAddImage;
  final Function(int) onRemoveImage;

  const ProductImageUploadWidget({
    Key? key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
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
          Row(
            children: [
              Icon(
                Icons.photo_camera,
                size: 3.h,
                color: Color(0xFF8B4513),
              ),
              SizedBox(width: 2.w),
              Text(
                'Fotos do Produto',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (images.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF8B4513).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${images.length} foto${images.length != 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),

          // Add Image Button
          GestureDetector(
            onTap: onAddImage,
            child: Container(
              width: double.infinity,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF8B4513).withAlpha(77),
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 6.h,
                    color: Color(0xFF8B4513).withAlpha(153),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Adicionar Fotos',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8B4513).withAlpha(204),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Toque para selecionar múltiplas imagens',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Display selected images
          if (images.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              'Imagens Selecionadas:',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              height: 12.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (context, index) => SizedBox(width: 2.w),
                itemBuilder: (context, index) {
                  final image = images[index];
                  return Stack(
                    children: [
                      Container(
                        width: 20.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: index == 0
                                ? Color(0xFF8B4513)
                                : Colors.grey.withAlpha(77),
                            width: index == 0 ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 4.h,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Primary image indicator
                      if (index == 0)
                        Positioned(
                          bottom: 1.w,
                          left: 1.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 1.w,
                              vertical: 0.5.w,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF8B4513),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Principal',
                              style: GoogleFonts.inter(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // Remove button
                      Positioned(
                        top: 1.w,
                        right: 1.w,
                        child: GestureDetector(
                          onTap: () => onRemoveImage(index),
                          child: Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 3.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Image upload tips
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withAlpha(51),
                ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dicas para melhores fotos:',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 1.w),
                        Text(
                          '• A primeira imagem será a principal\n• Use boa iluminação\n• Mostre diferentes ângulos do produto',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.blue[700],
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
}
