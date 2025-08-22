import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_orders_widget.dart';
import './widgets/order_card.dart';
import './widgets/order_skeleton_card.dart';
import './widgets/order_status_chip.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedStatus = 'Todos';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];

  final List<String> _statusOptions = [
    'Todos',
    'Pendentes',
    'Em Preparo',
    'Entregues',
    'Cancelados'
  ];

  // Mock data for orders
  final List<Map<String, dynamic>> _mockOrders = [
    {
      "id": 1,
      "orderNumber": "001234",
      "date": "14 de Agosto, 2025",
      "status": "entregue",
      "total": "R\$ 45,90",
      "items": [
        {
          "name": "Pão de Açúcar",
          "quantity": 2,
          "price": "R\$ 8,50",
          "image":
              "https://images.pexels.com/photos/1775043/pexels-photo-1775043.jpeg?auto=compress&cs=tinysrgb&w=800"
        },
        {
          "name": "Bolo de Chocolate",
          "quantity": 1,
          "price": "R\$ 28,90",
          "image":
              "https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg?auto=compress&cs=tinysrgb&w=800"
        }
      ]
    },
    {
      "id": 2,
      "orderNumber": "001235",
      "date": "13 de Agosto, 2025",
      "status": "em preparo",
      "total": "R\$ 32,50",
      "items": [
        {
          "name": "Torta de Frango",
          "quantity": 1,
          "price": "R\$ 18,90",
          "image":
              "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=800"
        },
        {
          "name": "Pão Francês",
          "quantity": 6,
          "price": "R\$ 13,60",
          "image":
              "https://images.pexels.com/photos/209206/pexels-photo-209206.jpeg?auto=compress&cs=tinysrgb&w=800"
        }
      ]
    },
    {
      "id": 3,
      "orderNumber": "001236",
      "date": "12 de Agosto, 2025",
      "status": "pendente",
      "total": "R\$ 67,80",
      "items": [
        {
          "name": "Bolo de Aniversário",
          "quantity": 1,
          "price": "R\$ 55,00",
          "image":
              "https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg?auto=compress&cs=tinysrgb&w=800"
        },
        {
          "name": "Brigadeiros",
          "quantity": 12,
          "price": "R\$ 12,80",
          "image":
              "https://images.pexels.com/photos/1998633/pexels-photo-1998633.jpeg?auto=compress&cs=tinysrgb&w=800"
        }
      ]
    },
    {
      "id": 4,
      "orderNumber": "001237",
      "date": "11 de Agosto, 2025",
      "status": "entregue",
      "total": "R\$ 24,70",
      "items": [
        {
          "name": "Croissant",
          "quantity": 3,
          "price": "R\$ 15,90",
          "image":
              "https://images.pexels.com/photos/2135/food-france-morning-breakfast.jpg?auto=compress&cs=tinysrgb&w=800"
        },
        {
          "name": "Café Expresso",
          "quantity": 2,
          "price": "R\$ 8,80",
          "image":
              "https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg?auto=compress&cs=tinysrgb&w=800"
        }
      ]
    },
    {
      "id": 5,
      "orderNumber": "001238",
      "date": "10 de Agosto, 2025",
      "status": "cancelado",
      "total": "R\$ 89,40",
      "items": [
        {
          "name": "Torta de Limão",
          "quantity": 1,
          "price": "R\$ 42,90",
          "image":
              "https://images.pexels.com/photos/1126359/pexels-photo-1126359.jpeg?auto=compress&cs=tinysrgb&w=800"
        },
        {
          "name": "Pão de Mel",
          "quantity": 8,
          "price": "R\$ 46,50",
          "image":
              "https://images.pexels.com/photos/1775043/pexels-photo-1775043.jpeg?auto=compress&cs=tinysrgb&w=800"
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreOrders();
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _orders = List.from(_mockOrders);
      _filteredOrders = List.from(_orders);
      _isLoading = false;
    });
  }

  Future<void> _loadMoreOrders() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading more orders
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshOrders() async {
    await _loadOrders();
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        final matchesSearch = _searchController.text.isEmpty ||
            (order['orderNumber'] as String)
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            ((order['items'] as List).any((item) => (item['name'] as String)
                .toLowerCase()
                .contains(_searchController.text.toLowerCase())));

        final matchesStatus = _selectedStatus == 'Todos' ||
            _getStatusForFilter(order['status'] as String) == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  String _getStatusForFilter(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return 'Pendentes';
      case 'em preparo':
        return 'Em Preparo';
      case 'entregue':
        return 'Entregues';
      case 'cancelado':
        return 'Cancelados';
      default:
        return 'Todos';
    }
  }

  int _getStatusCount(String status) {
    if (status == 'Todos') return _orders.length;
    return _orders
        .where(
            (order) => _getStatusForFilter(order['status'] as String) == status)
        .length;
  }

  void _onStatusSelected(String status) {
    setState(() {
      _selectedStatus = status;
    });
    _filterOrders();
  }

  void _onViewOrderDetails(Map<String, dynamic> order) {
    // Navigate to order details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalhes do pedido #${order['orderNumber']}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _onReorder(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Adicionando itens do pedido #${order['orderNumber']} ao carrinho...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _onMakeFirstOrder() {
    Navigator.pushNamed(context, '/product-catalog-home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Meus Pedidos',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Export orders functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exportando histórico de pedidos...'),
                ),
              );
            },
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(4.w),
            color: AppTheme.lightTheme.scaffoldBackgroundColor,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterOrders(),
              decoration: InputDecoration(
                hintText: 'Buscar por produto ou número do pedido...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _filterOrders();
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.lightTheme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Filter chips
          Container(
            height: 6.h,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _statusOptions.length,
              itemBuilder: (context, index) {
                final status = _statusOptions[index];
                return OrderStatusChip(
                  status: status,
                  count: _getStatusCount(status),
                  isSelected: _selectedStatus == status,
                  onTap: () => _onStatusSelected(status),
                );
              },
            ),
          ),

          SizedBox(height: 2.h),

          // Orders list
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => const OrderSkeletonCard(),
                  )
                : _filteredOrders.isEmpty
                    ? EmptyOrdersWidget(onMakeFirstOrder: _onMakeFirstOrder)
                    : RefreshIndicator(
                        onRefresh: _refreshOrders,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              _filteredOrders.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _filteredOrders.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final order = _filteredOrders[index];
                            return OrderCard(
                              order: order,
                              onViewDetails: () => _onViewOrderDetails(order),
                              onReorder: () => _onReorder(order),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        currentIndex: 2, // Pedidos tab active
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/product-catalog-home');
              break;
            case 1:
              Navigator.pushNamed(context, '/shopping-cart');
              break;
            case 2:
              // Current screen - do nothing
              break;
            case 3:
              Navigator.pushNamed(context, '/customer-profile');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'home',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'shopping_cart',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'shopping_cart',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Carrinho',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'receipt_long',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'receipt_long',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'person',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
