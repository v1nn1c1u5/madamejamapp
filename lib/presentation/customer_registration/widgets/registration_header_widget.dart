import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationHeaderWidget extends StatelessWidget {
  final VoidCallback onBackPressed;
  final String? title;

  const RegistrationHeaderWidget({
    Key? key,
    required this.onBackPressed,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 2.h,
        left: 4.w,
        right: 4.w,
        bottom: 3.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B4513),
            Color(0xFF8B4513).withAlpha(204),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Title
          Text(
            title ?? 'Criar Conta',
            style: GoogleFonts.inter(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 1.h),

          // Subtitle
          Text(
            title != null
                ? 'Preencha os dados para cadastrar o cliente'
                : 'Preencha seus dados para começar',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: Colors.white.withAlpha(230),
            ),
          ),
        ],
      ),
    );
  }
}
