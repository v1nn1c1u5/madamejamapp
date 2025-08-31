import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/cart_service.dart';
import '../../services/bakery_service.dart';
import '../../services/customer_service.dart';
import '../../services/auth_service.dart';
import './widgets/boleto_payment_widget.dart';
import './widgets/credit_card_form_widget.dart';
import './widgets/order_summary_widget.dart';
import './widgets/payment_method_widget.dart';
import './widgets/pix_payment_widget.dart';
import './widgets/security_badges_widget.dart';

class CheckoutPayment extends StatefulWidget {
  const CheckoutPayment({super.key});

  @override
  State<CheckoutPayment> createState() => _CheckoutPaymentState();
}

class _CheckoutPaymentState extends State<CheckoutPayment> {
  String _selectedPaymentMethod = 'credit_card';
  bool _acceptTerms = false;
  bool _isProcessing = false;
  bool _isLoading = true;
  Map<String, String> _cardData = {};

  // Real data from services
  List<CartItem> _cartItems = [];
  Map<String, dynamic>? _customerData;
  Map<String, dynamic> _orderSummary = {};
  
  final Map<String, dynamic> _deliveryDetails = {
    'address': 'Rua das Flores, 123 - Vila Madalena',
    'building': 'Edifício Primavera',
    'apartment': '45B',
    'scheduledTime': 'Hoje, 16:30 - 17:30',
  };

  double get _totalAmount => _orderSummary['total_amount'] ?? 0.0;
  double get _subtotal => _orderSummary['subtotal'] ?? 0.0;
  double get _deliveryFee => _orderSummary['delivery_fee'] ?? 0.0;
  int get _totalItems => _orderSummary['total_items'] ?? 0;

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cartService = CartService.instance;
      final authService = AuthService.instance;
      final customerService = CustomerService.instance;

      // Get cart items
      _cartItems = cartService.items;
      _orderSummary = cartService.getOrderSummary();

      // Check if cart is empty
      if (_cartItems.isEmpty) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/shopping-cart');
        }
        return;
      }

      // Get customer data if user is logged in
      if (authService.isSignedIn) {
        final currentUser = authService.currentUser;
        if (currentUser != null) {
          _customerData = await customerService.getCustomerByUserProfileId(currentUser.id);
        }
      }
    } catch (error) {
      debugPrint('Error loading checkout data: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados do checkout: $error'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onPaymentMethodSelected(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  void _onCardDataChanged(Map<String, String> cardData) {
    setState(() {
      _cardData = cardData;
    });
  }

  bool _isFormValid() {
    if (!_acceptTerms) return false;

    switch (_selectedPaymentMethod) {
      case 'credit_card':
      case 'debit_card':
        return _cardData['cardNumber']?.isNotEmpty == true &&
            _cardData['expiry']?.isNotEmpty == true &&
            _cardData['cvv']?.isNotEmpty == true &&
            _cardData['name']?.isNotEmpty == true;
      case 'pix':
      case 'boleto':
        return true;
      default:
        return false;
    }
  }

  Future<void> _processPayment() async {
    if (!_isFormValid()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final bakeryService = BakeryService.instance;
      final cartService = CartService.instance;
      final authService = AuthService.instance;

      // Check if user is logged in
      if (!authService.isSignedIn) {
        throw Exception('Usuário não está logado');
      }

      // Ensure we have customer data
      if (_customerData == null) {
        throw Exception('Dados do cliente não encontrados');
      }

      // Generate order number
      final orderNumber = await bakeryService.generateOrderNumber();

      // Create order
      final orderData = {
        'order_number': orderNumber,
        'customer_id': _customerData!['id'],
        'created_by': authService.currentUser!.id,
        'status': 'pending',
        'total_amount': _totalAmount,
        'discount_amount': 0.0,
        'tax_amount': 0.0,
        'payment_method': _selectedPaymentMethod,
        'payment_status': 'pending',
        'delivery_date': DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0],
        'delivery_address': _deliveryDetails['address'],
        'special_instructions': null,
      };

      final createdOrder = await bakeryService.createOrder(orderData);

      // Add order items
      for (final cartItem in _cartItems) {
        await bakeryService.addOrderItem(
          createdOrder['id'],
          cartItem.productId,
          cartItem.quantity,
          cartItem.price,
        );
      }

      // Clear cart after successful order creation
      await cartService.clearCart();

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        _showPaymentSuccess(orderNumber);
      }
    } catch (error) {
      debugPrint('Error processing payment: $error');
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar pagamento: $error'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  void _showPaymentSuccess(String orderNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 48,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Pagamento Confirmado!',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Seu pedido $orderNumber foi confirmado.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Entrega prevista: ${_deliveryDetails['scheduledTime']}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/order-history');
                },
                child: const Text('Ver Pedidos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    switch (_selectedPaymentMethod) {
      case 'credit_card':
      case 'debit_card':
        return CreditCardFormWidget(
          onCardDataChanged: _onCardDataChanged,
        );
      case 'pix':
        return PixPaymentWidget(amount: _totalAmount);
      case 'boleto':
        return BoletoPaymentWidget(amount: _totalAmount);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pagamento'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.tertiary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'SSL',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando dados do checkout...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  OrderSummaryWidget(
                    cartItems: _cartItems.map((item) => {
                      'id': item.id,
                      'name': item.name,
                      'price': item.price,
                      'quantity': item.quantity,
                      'image': item.imageUrl ?? '',
                    }).toList(),
                    deliveryDetails: _deliveryDetails,
                    totalAmount: _totalAmount,
                  ),

            SizedBox(height: 3.h),

            // Payment Method Selection
            PaymentMethodWidget(
              onPaymentMethodSelected: _onPaymentMethodSelected,
              selectedMethod: _selectedPaymentMethod,
            ),

            SizedBox(height: 3.h),

            // Payment Form
            _buildPaymentForm(),

            SizedBox(height: 3.h),

            // Security Badges
            const SecurityBadgesWidget(),

            SizedBox(height: 3.h),

            // Terms and Conditions
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _acceptTerms = !_acceptTerms;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 3.w),
                        child: RichText(
                          text: TextSpan(
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                            children: [
                              const TextSpan(text: 'Eu aceito os '),
                              TextSpan(
                                text: 'Termos de Uso',
                                style: TextStyle(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: ' e '),
                              TextSpan(
                                text: 'Política de Privacidade',
                                style: TextStyle(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: ' da Madame Jam'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),



                  SizedBox(height: 4.h),

                  // Payment Button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      child: _isProcessing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                const Text('Processando...'),
                              ],
                            )
                          : Text(
                              'Confirmar Pagamento - R\$ ${_totalAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Footer Info
                  Text(
                    'Ao confirmar o pagamento, você concorda com nossos termos e condições. O pedido será processado imediatamente.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
    );
  }
}
