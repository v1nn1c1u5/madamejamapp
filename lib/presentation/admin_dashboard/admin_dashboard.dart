import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/calendar_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/order_item_widget.dart';
import './widgets/revenue_chart_widget.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  String _selectedChartPeriod = 'Diário';
  bool _isRefreshing = false;

  // Mock data for dashboard metrics
  final List<Map<String, dynamic>> _metricsData = [
    {
      'title': 'Pedidos Hoje',
      'value': '24',
      'changePercentage': '+12',
      'isPositive': true,
      'cardColor': const Color(0xFFF7CAC9).withValues(alpha: 0.3),
      'iconName': 'shopping_bag',
    },
    {
      'title': 'Receita Hoje',
      'value': 'R\$ 1.850',
      'changePercentage': '+8',
      'isPositive': true,
      'cardColor': const Color(0xFFFFD700).withValues(alpha: 0.3),
      'iconName': 'attach_money',
    },
    {
      'title': 'Pendentes',
      'value': '7',
      'changePercentage': '-3',
      'isPositive': false,
      'cardColor': const Color(0xFFFFA726).withValues(alpha: 0.3),
      'iconName': 'pending',
    },
    {
      'title': 'Clientes',
      'value': '156',
      'changePercentage': '+5',
      'isPositive': true,
      'cardColor': const Color(0xFF4CAF50).withValues(alpha: 0.3),
      'iconName': 'people',
    },
  ];

  // Mock data for recent orders
  final List<Map<String, dynamic>> _recentOrders = [
    {
      'id': 1,
      'customerName': 'Maria Silva',
      'value': 'R\$ 85,50',
      'status': 'novo',
      'time': '14:30',
    },
    {
      'id': 2,
      'customerName': 'João Santos',
      'value': 'R\$ 120,00',
      'status': 'preparando',
      'time': '14:15',
    },
    {
      'id': 3,
      'customerName': 'Ana Costa',
      'value': 'R\$ 65,80',
      'status': 'pronto',
      'time': '14:00',
    },
    {
      'id': 4,
      'customerName': 'Carlos Oliveira',
      'value': 'R\$ 95,20',
      'status': 'novo',
      'time': '13:45',
    },
    {
      'id': 5,
      'customerName': 'Lucia Ferreira',
      'value': 'R\$ 78,90',
      'status': 'preparando',
      'time': '13:30',
    },
  ];

  // Mock data for revenue chart
  final List<Map<String, dynamic>> _chartData = [
    {'label': 'Seg', 'value': 850.0},
    {'label': 'Ter', 'value': 920.0},
    {'label': 'Qua', 'value': 780.0},
    {'label': 'Qui', 'value': 1050.0},
    {'label': 'Sex', 'value': 1200.0},
    {'label': 'Sáb', 'value': 1450.0},
    {'label': 'Dom', 'value': 980.0},
  ];

  // Mock data for calendar order density
  final Map<DateTime, int> _orderDensity = {
    DateTime(2025, 8, 10): 8,
    DateTime(2025, 8, 11): 12,
    DateTime(2025, 8, 12): 6,
    DateTime(2025, 8, 13): 15,
    DateTime(2025, 8, 14): 9,
    DateTime(2025, 8, 15): 4,
    DateTime(2025, 8, 16): 11,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.lightTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 2.h),
              _buildMetricsCards(),
              SizedBox(height: 3.h),
              _buildRecentOrdersSection(),
              SizedBox(height: 3.h),
              RevenueChartWidget(
                chartData: _chartData,
                selectedPeriod: _selectedChartPeriod,
                onPeriodChanged: (period) {
                  setState(() {
                    _selectedChartPeriod = period;
                  });
                },
              ),
              SizedBox(height: 3.h),
              CalendarWidget(
                orderDensity: _orderDensity,
                onDateSelected: (date) {
                  // Handle date selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Data selecionada: ${date.day}/${date.month}/${date.year}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              SizedBox(height: 10.h), // Space for bottom navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Painel Admin',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () {
                // Handle notifications
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('3 novas notificações'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.textPrimaryLight,
                size: 24,
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: AppTheme.errorLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            // Handle settings
            _showSettingsBottomSheet();
          },
          icon: CustomIconWidget(
            iconName: 'settings',
            color: AppTheme.textPrimaryLight,
            size: 24,
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final formattedDate = '${now.day}/${now.month}/${now.year}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoje, $formattedDate',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Bem-vinda de volta!',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                    color: AppTheme.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'access_time',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '7 pedidos ativos',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCards() {
    return Container(
      height: 12.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _metricsData.length,
        separatorBuilder: (context, index) => SizedBox(width: 3.w),
        itemBuilder: (context, index) {
          final metric = _metricsData[index];
          return MetricsCardWidget(
            title: metric['title'],
            value: metric['value'],
            changePercentage: metric['changePercentage'],
            isPositive: metric['isPositive'],
            cardColor: metric['cardColor'],
            iconName: metric['iconName'],
          );
        },
      ),
    );
  }

  Widget _buildRecentOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pedidos Recentes',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to orders screen
                  Navigator.pushNamed(context, '/admin-dashboard');
                },
                child: Text(
                  'Ver todos',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentOrders.length,
          itemBuilder: (context, index) {
            final order = _recentOrders[index];
            return OrderItemWidget(
              order: order,
              onStatusUpdate: () => _handleOrderStatusUpdate(order),
              onContactCustomer: () => _handleContactCustomer(order),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
          _handleBottomNavigation(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.lightTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryLight,
        selectedLabelStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 10.sp,
        ),
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: _selectedTabIndex == 0
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.textSecondaryLight,
              size: 24,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'receipt_long',
              color: _selectedTabIndex == 1
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.textSecondaryLight,
              size: 24,
            ),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'inventory_2',
              color: _selectedTabIndex == 2
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.textSecondaryLight,
              size: 24,
            ),
            label: 'Produtos',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'analytics',
              color: _selectedTabIndex == 3
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.textSecondaryLight,
              size: 24,
            ),
            label: 'Relatórios',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showQuickActionsBottomSheet(),
      backgroundColor: AppTheme.lightTheme.primaryColor,
      child: CustomIconWidget(
        iconName: 'add',
        color: AppTheme.lightTheme.colorScheme.surface,
        size: 28,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dashboard atualizado!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleOrderStatusUpdate(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status do pedido #${order['id']} atualizado'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleContactCustomer(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entrando em contato com ${order['customerName']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        // Navigate to orders
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navegando para Pedidos...'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 2:
        // Navigate to products
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navegando para Produtos...'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 3:
        // Navigate to reports
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navegando para Relatórios...'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
    }
  }

  void _showQuickActionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Ações Rápidas',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 3.h),
              _buildQuickActionItem('Adicionar Produto', 'add_box', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add-product');
              }),
              _buildQuickActionItem('Pedido Manual', 'edit_note', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manual-order-creation');
              }),
              _buildQuickActionItem('Base de Clientes', 'people', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/customer-database');
              }),
              _buildQuickActionItem('Suporte de Entrega', 'local_shipping', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/delivery-support');
              }),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionItem(
      String title, String iconName, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Configurações',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 3.h),
              _buildQuickActionItem('Perfil', 'person', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Acessando perfil...')),
                );
              }),
              _buildQuickActionItem('Notificações', 'notifications', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configurando notificações...')),
                );
              }),
              _buildQuickActionItem('Exportar Relatório', 'file_download', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Exportando relatório diário...')),
                );
              }),
              _buildQuickActionItem('Sair', 'logout', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin-login');
              }),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }
}
