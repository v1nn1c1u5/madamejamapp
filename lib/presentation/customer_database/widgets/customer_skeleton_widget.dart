import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CustomerSkeletonWidget extends StatefulWidget {
  const CustomerSkeletonWidget({super.key});

  @override
  State<CustomerSkeletonWidget> createState() => _CustomerSkeletonWidgetState();
}

class _CustomerSkeletonWidgetState extends State<CustomerSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildShimmerContainer(
                      width: 50,
                      height: 50,
                      isCircle: true,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerContainer(
                            width: 40.w,
                            height: 16,
                          ),
                          SizedBox(height: 1.h),
                          _buildShimmerContainer(
                            width: 20.w,
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                    _buildShimmerContainer(
                      width: 15.w,
                      height: 20,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildShimmerContainer(
                  width: 60.w,
                  height: 12,
                ),
                SizedBox(height: 1.h),
                _buildShimmerContainer(
                  width: 70.w,
                  height: 12,
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerContainer(
                      width: 25.w,
                      height: 30,
                    ),
                    _buildShimmerContainer(
                      width: 15.w,
                      height: 30,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => _buildShimmerContainer(
                      width: 15.w,
                      height: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    bool isCircle = false,
  }) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.borderLight,
          borderRadius: isCircle
              ? BorderRadius.circular(width / 2)
              : BorderRadius.circular(8),
        ),
      ),
    );
  }
}
