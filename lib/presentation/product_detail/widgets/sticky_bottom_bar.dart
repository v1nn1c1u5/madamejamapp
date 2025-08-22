import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class StickyBottomBar extends StatefulWidget {
  final Map<String, dynamic> product;
  final int quantity;
  final Map<String, dynamic> customizations;
  final Function() onAddToCart;
  final int cartItemCount;

  const StickyBottomBar({
    super.key,
    required this.product,
    required this.quantity,
    required this.customizations,
    required this.onAddToCart,
    this.cartItemCount = 0,
  });

  @override
  State<StickyBottomBar> createState() => _StickyBottomBarState();
}

class _StickyBottomBarState extends State<StickyBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    widget.onAddToCart();

    setState(() {
      _isLoading = false;
    });

    // Show success feedback
    _showSuccessSnackBar();
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          CustomIconWidget(
              iconName: 'check_circle', color: Colors.white, size: 5.w),
          SizedBox(width: 3.w),
          Expanded(
              child: Text('Produto adicionado ao carrinho!',
                  style: AppTheme.lightTheme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white))),
        ]),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        margin: EdgeInsets.all(4.w)));
  }

  double _calculateTotalPrice() {
    final String priceString = widget.product['price'] as String? ?? 'R\$ 0,00';
    final double basePrice = _extractPriceFromString(priceString);
    return basePrice * widget.quantity;
  }

  double _extractPriceFromString(String priceString) {
    // Remove R$ and convert comma to dot for parsing
    final cleanPrice = priceString
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  String _formatPrice(double price) {
    return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = (widget.product['available'] as bool? ?? true);
    final double totalPrice = _calculateTotalPrice();

    return Container(
        decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, -2)),
            ]),
        child: SafeArea(
            child: Container(
                padding: EdgeInsets.all(4.w),
                child: Row(children: [
                  // Cart Icon with Badge
                  GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/shopping-cart'),
                      child: Container(
                          width: 14.w,
                          height: 14.w,
                          decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(3.w),
                              border: Border.all(
                                  color: AppTheme.lightTheme.colorScheme.outline
                                      .withValues(alpha: 0.3))),
                          child: Stack(children: [
                            Center(
                                child: CustomIconWidget(
                                    iconName: 'shopping_cart',
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                    size: 6.w)),
                            if (widget.cartItemCount > 0)
                              Positioned(
                                  top: 1.w,
                                  right: 1.w,
                                  child: Container(
                                      height: 4.w,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 1.w),
                                      decoration: BoxDecoration(
                                          color: AppTheme
                                              .lightTheme.colorScheme.error,
                                          borderRadius:
                                              BorderRadius.circular(2.w)),
                                      child: Center(
                                          child: Text(
                                              widget.cartItemCount > 99
                                                  ? '99+'
                                                  : widget.cartItemCount
                                                      .toString(),
                                              style: AppTheme.lightTheme.textTheme.labelSmall
                                                  ?.copyWith(
                                                      color: AppTheme.lightTheme
                                                          .colorScheme.onError,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 8.sp))))),
                          ]))),

                  SizedBox(width: 3.w),

                  // Add to Cart Button
                  Expanded(
                      child: AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: SizedBox(
                                    height: 14.w,
                                    child: ElevatedButton(
                                        onPressed: isAvailable && !_isLoading
                                            ? _handleAddToCart
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: isAvailable
                                                ? AppTheme.lightTheme
                                                    .colorScheme.primary
                                                : AppTheme.lightTheme
                                                    .colorScheme.outline
                                                    .withValues(alpha: 0.3),
                                            foregroundColor: isAvailable
                                                ? AppTheme.lightTheme
                                                    .colorScheme.onPrimary
                                                : AppTheme.lightTheme
                                                    .colorScheme.outline,
                                            elevation: isAvailable ? 2 : 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        3.w))),
                                        child: _isLoading
                                            ? SizedBox(width: 5.w, height: 5.w, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightTheme.colorScheme.onPrimary)))
                                            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                if (!isAvailable) ...[
                                                  CustomIconWidget(
                                                      iconName: 'block',
                                                      color: AppTheme.lightTheme
                                                          .colorScheme.outline,
                                                      size: 5.w),
                                                  SizedBox(width: 2.w),
                                                  Text('Esgotado',
                                                      style: AppTheme.lightTheme
                                                          .textTheme.titleMedium
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppTheme
                                                                  .lightTheme
                                                                  .colorScheme
                                                                  .outline)),
                                                ] else ...[
                                                  CustomIconWidget(
                                                      iconName:
                                                          'add_shopping_cart',
                                                      color: AppTheme
                                                          .lightTheme
                                                          .colorScheme
                                                          .onPrimary,
                                                      size: 5.w),
                                                  SizedBox(width: 2.w),
                                                  Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Adicionar',
                                                            style: AppTheme
                                                                .lightTheme
                                                                .textTheme
                                                                .labelMedium
                                                                ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: AppTheme
                                                                        .lightTheme
                                                                        .colorScheme
                                                                        .onPrimary)),
                                                        Text(
                                                            _formatPrice(
                                                                totalPrice),
                                                            style: AppTheme
                                                                .lightTheme
                                                                .textTheme
                                                                .titleSmall
                                                                ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: AppTheme
                                                                        .lightTheme
                                                                        .colorScheme
                                                                        .onPrimary)),
                                                      ]),
                                                ],
                                              ]))));
                          })),
                ]))));
  }
}
