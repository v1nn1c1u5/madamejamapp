import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ProductCardWidget extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onViewDetails;
  final VoidCallback onAddToCart;
  final VoidCallback onFavorite;
  final VoidCallback onShare;
  final VoidCallback onSimilarItems;

  const ProductCardWidget({
    super.key,
    required this.product,
    required this.onViewDetails,
    required this.onAddToCart,
    required this.onFavorite,
    required this.onShare,
    required this.onSimilarItems,
  });

  @override
  State<ProductCardWidget> createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends State<ProductCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSwipeRevealed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSwipe() {
    if (_isSwipeRevealed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isSwipeRevealed = !_isSwipeRevealed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = (widget.product['available'] as bool? ?? true);
    final String price = widget.product['price'] as String? ?? 'R\$ 0,00';
    final String name = widget.product['name'] as String? ?? 'Produto';
    final String description = widget.product['description'] as String? ?? '';
    final String imageUrl = widget.product['image'] as String? ?? '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Stack(
        children: [
          // Quick actions background
          if (_isSwipeRevealed)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildQuickAction(
                      icon: 'favorite_border',
                      label: 'Favorito',
                      onTap: widget.onFavorite,
                    ),
                    _buildQuickAction(
                      icon: 'share',
                      label: 'Compartilhar',
                      onTap: widget.onShare,
                    ),
                    _buildQuickAction(
                      icon: 'category',
                      label: 'Similares',
                      onTap: widget.onSimilarItems,
                    ),
                    SizedBox(width: 4.w),
                  ],
                ),
              ),
            ),
          // Main card
          SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! > 0) {
                  _toggleSwipe();
                }
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image
                        Container(
                          width: double.infinity,
                          height: 25.h,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            color: AppTheme.lightTheme.colorScheme.surface,
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: imageUrl.isNotEmpty
                                ? CustomImageWidget(
                                    imageUrl: imageUrl,
                                    width: double.infinity,
                                    height: 25.h,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: AppTheme
                                        .lightTheme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    child: Center(
                                      child: CustomIconWidget(
                                        iconName: 'image',
                                        size: 48,
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        // Product details
                        Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                description,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    price,
                                    style: AppTheme
                                        .lightTheme.textTheme.titleLarge
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isAvailable ? 'Disponível' : 'Esgotado',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: isAvailable
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: widget.onViewDetails,
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 1.5.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Ver Detalhes',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isAvailable
                                          ? widget.onAddToCart
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 1.5.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        backgroundColor: isAvailable
                                            ? AppTheme
                                                .lightTheme.colorScheme.primary
                                            : AppTheme
                                                .lightTheme.colorScheme.outline,
                                      ),
                                      child: Text(
                                        isAvailable
                                            ? 'Adicionar'
                                            : 'Indisponível',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: isAvailable
                                              ? AppTheme.lightTheme.colorScheme
                                                  .onPrimary
                                              : AppTheme.lightTheme.colorScheme
                                                  .onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Unavailable overlay
                    if (!isAvailable)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'inventory_2',
                                  size: 48,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Esgotado',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                TextButton(
                                  onPressed: () {
                                    // Show notification setup
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Você será notificado quando o produto estiver disponível'),
                                        backgroundColor: AppTheme
                                            .lightTheme.colorScheme.primary,
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.2),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 1.h,
                                    ),
                                  ),
                                  child: Text(
                                    'Notificar quando disponível',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
