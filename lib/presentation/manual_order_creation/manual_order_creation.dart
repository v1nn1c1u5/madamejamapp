import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/bakery_service.dart';
import '../../theme/app_theme.dart';
import './widgets/cart_summary_widget.dart';
import './widgets/customer_selection_widget.dart';
import './widgets/delivery_details_widget.dart';
import './widgets/order_notes_widget.dart';
import './widgets/payment_options_widget.dart';
import './widgets/product_selection_widget.dart';

class ManualOrderCreation extends StatefulWidget {
  const ManualOrderCreation({super.key});

  @override
  State<ManualOrderCreation> createState() => _ManualOrderCreationState();
}

class _ManualOrderCreationState extends State<ManualOrderCreation>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;

  // Order data
  Map<String, dynamic>? _selectedCustomer;
  List<Map<String, dynamic>> _cartItems = [];
  Map<String, dynamic> _deliveryDetails = {};
  String _paymentMethod = 'cash';
  String _orderNotes = '';
  double _discountAmount = 0.0;
  String _discountReason = '';

  // Services
  final _bakeryService = BakeryService.instance;

  void _handleAddToCart(Map<String, dynamic> product, int quantity) {
    setState(() {
      // Check if product already exists in cart
      final existingIndex = _cartItems.indexWhere(
        (item) => item['product_id'] == product['id'],
      );

      if (existingIndex != -1) {
        // Update existing item quantity
        _cartItems[existingIndex]['quantity'] += quantity;
        _cartItems[existingIndex]['total_price'] =
            _cartItems[existingIndex]['quantity'] * product['price'];
      } else {
        // Add new item to cart
        _cartItems.add({
          'product_id': product['id'],
          'name': product['name'],
          'price': product['price'],
          'quantity': quantity,
          'total_price': product['price'] * quantity,
          'special_instructions': '',
        });
      }
    });
  }

  void _handleRemoveFromCart(int index) {
    setState(() {
      if (index >= 0 && index < _cartItems.length) {
        _cartItems.removeAt(index);
      }
    });
  }

  void _handleUpdateQuantity(int index, int newQuantity) {
    setState(() {
      if (index >= 0 && index < _cartItems.length) {
        if (newQuantity <= 0) {
          _cartItems.removeAt(index);
        } else {
          _cartItems[index]['quantity'] = newQuantity;
          _cartItems[index]['total_price'] =
              _cartItems[index]['price'] * newQuantity;
        }
      }
    });
  }

  void _handleUpdateInstructions(int index, String instructions) {
    setState(() {
      if (index >= 0 && index < _cartItems.length) {
        _cartItems[index]['special_instructions'] = instructions;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      if (!AuthService.instance.isSignedIn) {
        Navigator.pushReplacementNamed(context, '/admin-login');
        return;
      }

      final isAdmin = await AuthService.instance.isAdmin();
      if (!isAdmin) {
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      }
    } catch (e) {
      _showErrorMessage('Erro de autenticação: ${e.toString()}');
      Navigator.pushReplacementNamed(context, '/admin-login');
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            })));
  }

  void _handleCustomerSelected(Map<String, dynamic> customer) {
    setState(() {
      _selectedCustomer = customer;
    });
    _tabController.animateTo(1);
  }

  void _handlePaymentMethodSelected(String paymentMethod) {
    setState(() {
      _paymentMethod = paymentMethod;
    });
    _tabController.animateTo(4);
  }

  void _handleOrderNotes(String notes) {
    setState(() {
      _orderNotes = notes;
    });
    _tabController.animateTo(5);
  }

  Future<void> _createOrder() async {
    if (_selectedCustomer == null) {
      _showErrorMessage('Selecione um cliente primeiro');
      _tabController.animateTo(0);
      return;
    }

    if (_cartItems.isEmpty) {
      _showErrorMessage('Adicione pelo menos um produto ao pedido');
      _tabController.animateTo(1);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user for created_by field
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      // Calculate total
      double totalAmount = _cartItems.fold(
          0.0, (sum, item) => sum + (item['total_price'] as double));

      // Generate order number
      final orderNumber = await _bakeryService.generateOrderNumber();

      // Create order data
      final orderData = {
        'customer_id': _selectedCustomer!['id'],
        'created_by': currentUser.id,
        'order_number': orderNumber,
        'total_amount': totalAmount,
        'payment_method': _paymentMethod,
        'payment_status': 'pending',
        'status': 'pending',
        'internal_notes': _orderNotes.isNotEmpty ? _orderNotes : null,
        'delivery_address': _deliveryDetails['address'] ??
            _selectedCustomer!['address_line1'] ??
            '',
        'delivery_date':
            _deliveryDetails['date']?.toIso8601String()?.split('T')[0],
        'delivery_time_start': _deliveryDetails['start_time'],
        'delivery_time_end': _deliveryDetails['end_time'],
        'special_instructions': _deliveryDetails['instructions'],
        'tax_amount': 0,
        'discount_amount': 0,
      };

      // Create the order
      final createdOrder = await _bakeryService.createOrder(orderData);
      final orderId = createdOrder['id'];

      // Add order items
      for (final item in _cartItems) {
        await _bakeryService.addOrderItem(
          orderId,
          item['product_id'],
          item['quantity'],
          item['price'].toDouble(),
        );
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Pedido #$orderNumber criado com sucesso! Total: R\$ ${totalAmount.toStringAsFixed(2)}'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Ver Pedidos',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          },
        ),
      ));

      // Reset form
      setState(() {
        _selectedCustomer = null;
        _cartItems = [];
        _deliveryDetails = {};
        _paymentMethod = 'cash';
        _orderNotes = '';
        _discountAmount = 0.0;
        _discountReason = '';
      });

      _tabController.animateTo(0);
    } catch (e) {
      String errorMessage = 'Erro ao criar pedido';

      if (e.toString().contains('customer_id')) {
        errorMessage =
            'Cliente inválido. Por favor, selecione um cliente válido.';
      } else if (e.toString().contains('product_id')) {
        errorMessage =
            'Produto inválido no carrinho. Verifique os produtos selecionados.';
      } else if (e.toString().contains('total_amount')) {
        errorMessage =
            'Erro no cálculo do total. Verifique os preços dos produtos.';
      } else if (e.toString().contains('order_number')) {
        errorMessage = 'Erro ao gerar número do pedido. Tente novamente.';
      } else if (e.toString().contains('auth')) {
        errorMessage = 'Sessão expirou. Faça login novamente.';
        Navigator.pushReplacementNamed(context, '/admin-login');
        return;
      } else {
        errorMessage =
            'Erro inesperado: ${e.toString().replaceAll('Exception: ', '')}';
      }

      _showErrorMessage(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
            title: Text('Criar Pedido Manual',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600)),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
            bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppTheme.lightTheme.colorScheme.onPrimary,
                labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
                unselectedLabelColor: AppTheme.lightTheme.colorScheme.onPrimary
                    .withValues(alpha: 0.7),
                tabs: [
                  Tab(text: 'Cliente'),
                  Tab(text: 'Produtos'),
                  Tab(text: 'Resumo'),
                  Tab(text: 'Entrega'),
                  Tab(text: 'Pagamento'),
                  Tab(text: 'Finalizar'),
                ])),
        body: Column(
          children: [
            // Error message display
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                color: AppTheme.lightTheme.colorScheme.error.withAlpha(26),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: AppTheme.lightTheme.colorScheme.error),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: AppTheme.lightTheme.colorScheme.error),
                      onPressed: () => setState(() => _errorMessage = null),
                    ),
                  ],
                ),
              ),

            // Loading indicator
            if (_isLoading)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                color: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Processando pedido...',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Tab content
            Expanded(
              child: TabBarView(controller: _tabController, children: [
                // Tab 1: Customer Selection
                CustomerSelectionWidget(
                    selectedCustomer: _selectedCustomer,
                    onCustomerSelected: _handleCustomerSelected),

                // Tab 2: Product Selection
                ProductSelectionWidget(
                    cartItems: _cartItems,
                    onAddToCart: _handleAddToCart,
                    onRemoveFromCart: _handleRemoveFromCart,
                    onUpdateQuantity: _handleUpdateQuantity,
                    onUpdateInstructions: _handleUpdateInstructions),

                // Tab 3: Cart Summary
                CartSummaryWidget(
                    cartItems: _cartItems,
                    subtotal: _cartItems.fold(
                        0.0, (sum, item) => sum + item['total_price']),
                    discountAmount: 0.0,
                    total: _cartItems.fold(
                        0.0, (sum, item) => sum + item['total_price'])),

                // Tab 4: Delivery Details
                DeliveryDetailsWidget(
                    deliveryAddress:
                        _deliveryDetails['address'] as String? ?? '',
                    deliveryDate: _deliveryDetails['date'] as DateTime?,
                    deliveryTimeStart:
                        _deliveryDetails['start_time_obj'] as TimeOfDay?,
                    deliveryTimeEnd:
                        _deliveryDetails['end_time_obj'] as TimeOfDay?,
                    specialInstructions:
                        _deliveryDetails['instructions'] as String? ?? '',
                    onAddressChanged: (address) {
                      setState(() {
                        _deliveryDetails['address'] = address;
                      });
                    },
                    onDateChanged: (date) {
                      setState(() {
                        _deliveryDetails['date'] = date;
                      });
                    },
                    onStartTimeChanged: (time) {
                      setState(() {
                        _deliveryDetails['start_time'] = time?.format(context);
                        _deliveryDetails['start_time_obj'] = time;
                      });
                    },
                    onEndTimeChanged: (time) {
                      setState(() {
                        _deliveryDetails['end_time'] = time?.format(context);
                        _deliveryDetails['end_time_obj'] = time;
                      });
                    },
                    onInstructionsChanged: (instructions) {
                      setState(() {
                        _deliveryDetails['instructions'] = instructions;
                      });
                    }),

                // Tab 5: Payment Options
                PaymentOptionsWidget(
                    selectedPaymentMethod: _paymentMethod,
                    discountAmount: _discountAmount,
                    discountReason: _discountReason,
                    onPaymentMethodChanged: _handlePaymentMethodSelected,
                    onDiscountChanged: (amount, reason) {
                      setState(() {
                        _discountAmount = amount;
                        _discountReason = reason;
                      });
                    }),

                // Tab 6: Order Notes and Final Review
                OrderNotesWidget(
                  onNotesChanged: _handleOrderNotes,
                  internalNotes: _orderNotes,
                ),
              ]),
            ),

            // Create Order Button (shown on last tab)
            if (_tabController.index == 5)
              Container(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                      foregroundColor:
                          AppTheme.lightTheme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Criando Pedido...')
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle),
                              SizedBox(width: 8),
                              Text(
                                'Criar Pedido',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
          ],
        ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
