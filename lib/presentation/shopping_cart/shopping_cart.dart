import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/cart_item_card.dart';
import './widgets/delivery_scheduling_section.dart';
import './widgets/empty_cart_widget.dart';
import './widgets/order_summary_card.dart';
import './widgets/special_instructions_section.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({super.key});

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  List<Map<String, dynamic>> cartItems = [
    {
      "id": 1,
      "name": "Pão de Açúcar Artesanal",
      "price": 12.50,
      "quantity": 2,
      "image":
          "https://images.pexels.com/photos/1775043/pexels-photo-1775043.jpeg?auto=compress&cs=tinysrgb&w=800",
      "category": "Pães Pequenos"
    },
    {
      "id": 2,
      "name": "Bolo de Chocolate Belga",
      "price": 45.90,
      "quantity": 1,
      "image":
          "https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg?auto=compress&cs=tinysrgb&w=800",
      "category": "Bolos"
    },
    {
      "id": 3,
      "name": "Torta Salgada de Frango",
      "price": 28.75,
      "quantity": 1,
      "image":
          "https://images.pexels.com/photos/1109197/pexels-photo-1109197.jpeg?auto=compress&cs=tinysrgb&w=800",
      "category": "Tortas Salgadas"
    },
  ];

  DateTime? selectedDeliveryDate;
  String? selectedTimeSlot;
  String specialInstructions = '';

  final double deliveryFee = 8.50;
  final double taxRate = 0.08; // 8% tax
  final double minimumOrderValue = 50.0;

  double get subtotal {
    return cartItems.fold(
        0.0,
        (sum, item) =>
            sum + ((item['price'] as double) * (item['quantity'] as int)));
  }

  double get taxes {
    return subtotal * taxRate;
  }

  double get actualDeliveryFee {
    return subtotal >= minimumOrderValue ? 0.0 : deliveryFee;
  }

  double get total {
    return subtotal + actualDeliveryFee + taxes;
  }

  int get totalItemCount {
    return cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  void _updateQuantity(int itemId, int newQuantity) {
    setState(() {
      final itemIndex = cartItems.indexWhere((item) => item['id'] == itemId);
      if (itemIndex != -1) {
        cartItems[itemIndex]['quantity'] = newQuantity;
      }
    });
  }

  void _removeItem(int itemId) {
    setState(() {
      cartItems.removeWhere((item) => item['id'] == itemId);
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDeliveryDate = date;
    });
  }

  void _onTimeSlotSelected(String timeSlot) {
    setState(() {
      selectedTimeSlot = timeSlot;
    });
  }

  void _onInstructionsChanged(String instructions) {
    setState(() {
      specialInstructions = instructions;
    });
  }

  void _proceedToCheckout() {
    if (cartItems.isEmpty) return;

    if (selectedDeliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecione uma data de entrega'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    if (selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecione um horário de entrega'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    Navigator.pushNamed(context, '/checkout-payment');
  }

  void _continueShopping() {
    Navigator.pushNamed(context, '/product-catalog-home');
  }

  Future<void> _refreshCart() async {
    // Simulate refresh delay
    await Future.delayed(Duration(milliseconds: 500));

    // In a real app, this would fetch updated cart data from the server
    setState(() {
      // Refresh cart items, prices, availability, etc.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Carrinho',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            if (cartItems.isNotEmpty) ...[
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalItemCount',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: _continueShopping,
              child: Text(
                'Continuar',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? EmptyCartWidget(onContinueShopping: _continueShopping)
          : RefreshIndicator(
              onRefresh: _refreshCart,
              color: AppTheme.lightTheme.colorScheme.primary,
              child: Column(
                children: [
                  // Estimated Total Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    child: Text(
                      'Total estimado: R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: 1.h),

                          // Cart Items List
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return CartItemCard(
                                item: item,
                                onDelete: () => _removeItem(item['id'] as int),
                                onQuantityChanged: (newQuantity) =>
                                    _updateQuantity(
                                        item['id'] as int, newQuantity),
                              );
                            },
                          ),

                          SizedBox(height: 2.h),

                          // Delivery Scheduling
                          DeliverySchedulingSection(
                            selectedDate: selectedDeliveryDate,
                            selectedTimeSlot: selectedTimeSlot,
                            onDateSelected: _onDateSelected,
                            onTimeSlotSelected: _onTimeSlotSelected,
                          ),

                          // Special Instructions
                          SpecialInstructionsSection(
                            instructions: specialInstructions,
                            onInstructionsChanged: _onInstructionsChanged,
                          ),

                          // Order Summary
                          OrderSummaryCard(
                            subtotal: subtotal,
                            deliveryFee: actualDeliveryFee,
                            taxes: taxes,
                            total: total,
                            minimumOrderValue: minimumOrderValue,
                          ),

                          SizedBox(height: 10.h), // Space for bottom button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

      // Sticky Bottom Checkout Button
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _proceedToCheckout,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'payment',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Finalizar Pedido',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '• R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
