import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/bakery_service.dart';
import '../../services/analytics_service.dart';
import './widgets/calendar_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/order_item_widget.dart';
import './widgets/revenue_chart_widget.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  String _selectedChartPeriod = 'Diário';
  bool _isLoading = true;

  // Real data from Supabase
  List<Map<String, dynamic>> _dashboardMetrics = [];
  List<Map<String, dynamic>> _recentOrders = [];
  List<Map<String, dynamic>> _allOrders = [];
  List<Map<String, dynamic>> _products = [];

  // Real analytics data
  List<Map<String, dynamic>> _chartData = [];
  Map<DateTime, int> _orderDensity = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bakeryService = BakeryService.instance;
      final analyticsService = AnalyticsService.instance;

      // Load all data in parallel for better performance
      final results = await Future.wait([
        bakeryService.getDashboardMetrics(),
        bakeryService.getOrders(limit: 5),
        bakeryService.getOrders(limit: 50),
        bakeryService.getProducts(limit: 20),
        analyticsService.getRevenueChartData(
            period: _selectedChartPeriod.toLowerCase()),
        analyticsService.getOrderDensity(),
      ]);

      final metrics = results[0] as Map<String, dynamic>;
      final orders = results[1] as List<Map<String, dynamic>>;
      final allOrders = results[2] as List<Map<String, dynamic>>;
      final products = results[3] as List<Map<String, dynamic>>;
      final chartData = results[4] as List<Map<String, dynamic>>;
      final orderDensity = results[5] as Map<DateTime, int>;

      // Debug logs to check what data is being loaded
      debugPrint('Dashboard Debug - Orders loaded: ${orders.length}');
      debugPrint('Dashboard Debug - All Orders loaded: ${allOrders.length}');
      if (allOrders.isNotEmpty) {
        debugPrint('Dashboard Debug - First order: ${allOrders.first}');
      }

      // Transform metrics into display format
      final List<Map<String, dynamic>> metricsData = [
        {
          'title': 'Pedidos Total',
          'value': '${metrics['total_orders'] ?? 0}',
          'changePercentage':
              '+${_calculateGrowth(metrics['total_orders'], 20)}',
          'isPositive': true,
          'cardColor': const Color(0xFFF7CAC9).withValues(alpha: 0.3),
          'iconName': 'shopping_bag',
        },
        {
          'title': 'Receita Total',
          'value':
              'R\$ ${(metrics['total_revenue'] ?? 0.0).toStringAsFixed(2)}',
          'changePercentage':
              '+${_calculateGrowth(metrics['total_revenue'], 1500)}',
          'isPositive': true,
          'cardColor': const Color(0xFFFFD700).withValues(alpha: 0.3),
          'iconName': 'attach_money',
        },
        {
          'title': 'Pendentes',
          'value': '${metrics['pending_orders'] ?? 0}',
          'changePercentage':
              _calculateGrowthNegative(metrics['pending_orders'], 10),
          'isPositive': metrics['pending_orders'] < 10,
          'cardColor': const Color(0xFFFFA726).withValues(alpha: 0.3),
          'iconName': 'pending',
        },
        {
          'title': 'Clientes',
          'value': '${metrics['total_customers'] ?? 0}',
          'changePercentage':
              '+${_calculateGrowth(metrics['total_customers'], 100)}',
          'isPositive': true,
          'cardColor': const Color(0xFF4CAF50).withValues(alpha: 0.3),
          'iconName': 'people',
        },
      ];

      setState(() {
        _dashboardMetrics = metricsData;
        _recentOrders = orders;
        _allOrders = allOrders;
        _products = products;
        _chartData = chartData;
        _orderDensity = orderDensity;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error loading dashboard data: $error');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao carregar dados do dashboard: $error'),
            backgroundColor: AppTheme.errorLight));
      }
    }
  }

  int _calculateGrowth(dynamic current, int previous) {
    if (current == null || current == 0) return 0;
    return (((current - previous) / previous) * 100).round().abs();
  }

  String _calculateGrowthNegative(dynamic current, int previous) {
    if (current == null) return '0';
    int growth = (((current - previous) / previous) * 100).round();
    return growth >= 0 ? '+$growth' : '$growth';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked);
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedTabIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildOrdersContent();
      case 2:
        return _buildProductsContent();
      case 3:
        return _buildReportsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.lightTheme.primaryColor,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildHeader(),
              SizedBox(height: 2.h),
              _buildMetricsCards(),
              SizedBox(height: 3.h),
              _buildRecentOrdersSection(),
              SizedBox(height: 3.h),
              RevenueChartWidget(
                  chartData: _chartData,
                  selectedPeriod: _selectedChartPeriod,
                  onPeriodChanged: (period) async {
                    setState(() {
                      _selectedChartPeriod = period;
                    });
                    await _updateChartData();
                  }),
              SizedBox(height: 3.h),
              CalendarWidget(
                  orderDensity: _orderDensity,
                  onDateSelected: (date) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Data selecionada: ${date.day}/${date.month}/${date.year}'),
                        duration: const Duration(seconds: 2)));
                  }),
              SizedBox(height: 10.h),
            ])));
  }

  Widget _buildOrdersContent() {
    return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.lightTheme.primaryColor,
        child: Column(children: [
          Container(
              padding: EdgeInsets.all(4.w),
              child: Row(children: [
                Text('Gestão de Pedidos',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700, fontSize: 18.sp)),
                const Spacer(),
                IconButton(
                    onPressed: _handleRefresh,
                    icon: CustomIconWidget(
                        iconName: 'refresh',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 24)),
              ])),
          Expanded(
              child: _allOrders.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          CustomIconWidget(
                              iconName: 'receipt_long',
                              color: AppTheme.textSecondaryLight,
                              size: 64),
                          SizedBox(height: 2.h),
                          Text('Nenhum pedido encontrado',
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                      color: AppTheme.textSecondaryLight)),
                          SizedBox(height: 1.h),
                          Text(
                              'Os pedidos aparecerão aqui quando forem realizados',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                      color: AppTheme.textSecondaryLight),
                              textAlign: TextAlign.center),
                        ]))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: _allOrders.length,
                      itemBuilder: (context, index) {
                        final order = _allOrders[index];
                        return OrderItemWidget(
                            order: order,
                            onStatusUpdate: () =>
                                _handleOrderStatusUpdate(order),
                            onContactCustomer: () =>
                                _handleContactCustomer(order));
                      })),
        ]));
  }

  Widget _buildProductsContent() {
    return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.lightTheme.primaryColor,
        child: Column(children: [
          Container(
              padding: EdgeInsets.all(4.w),
              child: Row(children: [
                Expanded(
                  child: Text('Gestão de Produtos',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 18.sp)),
                ),
                SizedBox(width: 2.w),
                ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-product');
                    },
                    icon: CustomIconWidget(
                        iconName: 'add',
                        color: AppTheme.lightTheme.colorScheme.surface,
                        size: 16),
                    label: Text('Novo',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.primaryColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        minimumSize: Size(0, 5.h))),
              ])),
          Expanded(
              child: _products.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          CustomIconWidget(
                              iconName: 'inventory_2',
                              color: AppTheme.textSecondaryLight,
                              size: 64),
                          SizedBox(height: 2.h),
                          Text('Nenhum produto encontrado',
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                      color: AppTheme.textSecondaryLight)),
                          SizedBox(height: 1.h),
                          Text('Clique no botão "Novo" para adicionar produtos',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                      color: AppTheme.textSecondaryLight),
                              textAlign: TextAlign.center),
                        ]))
                  : GridView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 3.w,
                          mainAxisSpacing: 2.h,
                          childAspectRatio: 0.75),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return _buildProductCard(product);
                      })),
        ]));
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final images = product['product_images'] as List<dynamic>? ?? [];
    final primaryImage =
        images.isNotEmpty ? images.first['image_url'] ?? '' : '';

    return Container(
        decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              flex: 3,
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      color: AppTheme.borderLight),
                  child: primaryImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: CustomImageWidget(
                              imageUrl: primaryImage, fit: BoxFit.cover))
                      : Center(
                          child: CustomIconWidget(
                              iconName: 'image',
                              color: AppTheme.textSecondaryLight,
                              size: 32)))),
          Container(
              padding: EdgeInsets.all(2.5.w),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(product['name'] ?? 'Produto sem nome',
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w600, fontSize: 11.sp),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: 0.5.h),
                    Text('R\$ ${(product['price'] ?? 0.0).toStringAsFixed(2)}',
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(
                                color: AppTheme.lightTheme.primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 10.sp)),
                    SizedBox(height: 1.h),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.5.w, vertical: 0.3.h),
                                decoration: BoxDecoration(
                                    color: (product['status'] == 'active'
                                            ? AppTheme.primaryLight
                                            : AppTheme.errorLight)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                    product['status'] == 'active'
                                        ? 'Ativo'
                                        : 'Inativo',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                            color: product['status'] == 'active'
                                                ? AppTheme.primaryLight
                                                : AppTheme.errorLight,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 8.sp))),
                          ),
                          SizedBox(width: 1.w),
                          Text('Est: ${product['stock_quantity'] ?? 0}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                      color: AppTheme.textSecondaryLight,
                                      fontSize: 8.sp)),
                        ]),
                  ])),
        ]));
  }

  Widget _buildReportsContent() {
    return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.lightTheme.primaryColor,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('Relatórios & Análises',
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.sp)),
                        const Spacer(),
                        IconButton(
                            onPressed: _exportReport,
                            icon: CustomIconWidget(
                                iconName: 'file_download',
                                color: AppTheme.lightTheme.primaryColor,
                                size: 24)),
                      ]),
                      SizedBox(height: 3.h),
                      _buildMetricsCards(),
                      SizedBox(height: 3.h),
                      RevenueChartWidget(
                          chartData: _chartData,
                          selectedPeriod: _selectedChartPeriod,
                          onPeriodChanged: (period) async {
                            setState(() {
                              _selectedChartPeriod = period;
                            });
                            await _updateChartData();
                          }),
                      SizedBox(height: 3.h),
                      _buildReportSummary(),
                      SizedBox(height: 10.h),
                    ]))));
  }

  Widget _buildReportSummary() {
    if (_dashboardMetrics.isEmpty) return Container();

    final totalRevenue = _dashboardMetrics[1]['value'].toString();
    final totalOrders = _dashboardMetrics[0]['value'].toString();
    final totalCustomers = _dashboardMetrics[3]['value'].toString();

    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Resumo Executivo',
              style: AppTheme.lightTheme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16.sp)),
          SizedBox(height: 2.h),
          Text('Receita Total: $totalRevenue',
              style: AppTheme.lightTheme.textTheme.bodyLarge
                  ?.copyWith(fontSize: 14.sp)),
          SizedBox(height: 1.h),
          Text('Total de Pedidos: $totalOrders',
              style: AppTheme.lightTheme.textTheme.bodyLarge
                  ?.copyWith(fontSize: 14.sp)),
          SizedBox(height: 1.h),
          Text('Base de Clientes: $totalCustomers clientes',
              style: AppTheme.lightTheme.textTheme.bodyLarge
                  ?.copyWith(fontSize: 14.sp)),
          SizedBox(height: 2.h),
          Text(
              'Produtos mais vendidos e métricas de performance podem ser adicionadas aqui conforme necessário.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight, fontSize: 12.sp)),
        ]));
  }

  PreferredSizeWidget _buildAppBar() {
    final titles = ['Painel Admin', 'Pedidos', 'Produtos', 'Relatórios'];

    return AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(titles[_selectedTabIndex],
            style: AppTheme.lightTheme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700, fontSize: 18.sp)),
        actions: [
          Stack(children: [
            IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('3 novas notificações'),
                      duration: Duration(seconds: 2)));
                },
                icon: CustomIconWidget(
                    iconName: 'notifications',
                    color: AppTheme.textPrimaryLight,
                    size: 24)),
            Positioned(
                right: 8,
                top: 8,
                child: Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                        color: AppTheme.errorLight, shape: BoxShape.circle))),
          ]),
          IconButton(
              onPressed: _showSettingsBottomSheet,
              icon: CustomIconWidget(
                  iconName: 'settings',
                  color: AppTheme.textPrimaryLight,
                  size: 24)),
          SizedBox(width: 2.w),
        ]);
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final formattedDate = '${now.day}/${now.month}/${now.year}';

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hoje, $formattedDate',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight, fontSize: 12.sp)),
          SizedBox(height: 1.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Text('Bem-vinda de volta!',
                    style: AppTheme.lightTheme.textTheme.headlineSmall
                        ?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20.sp,
                            color: AppTheme.textPrimaryLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  CustomIconWidget(
                      iconName: 'access_time',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 16),
                  SizedBox(width: 1.w),
                  Text(
                      '${_dashboardMetrics.isNotEmpty ? _dashboardMetrics[2]['value'] : 0} pedidos pendentes',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp)),
                ])),
          ]),
        ]));
  }

  Widget _buildMetricsCards() {
    if (_dashboardMetrics.isEmpty) {
      return SizedBox(
          height: 12.h,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: 4,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                return Container(
                    width: 40.w,
                    decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: CircularProgressIndicator()));
              }));
    }

    return SizedBox(
        height: 12.h,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: _dashboardMetrics.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final metric = _dashboardMetrics[index];
              return MetricsCardWidget(
                  title: metric['title'],
                  value: metric['value'],
                  changePercentage: metric['changePercentage'],
                  isPositive: metric['isPositive'],
                  cardColor: metric['cardColor'],
                  iconName: metric['iconName']);
            }));
  }

  Widget _buildRecentOrdersSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Pedidos Recentes',
                style: AppTheme.lightTheme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16.sp)),
            TextButton(
                onPressed: () {
                  setState(() {
                    _selectedTabIndex = 1;
                  });
                },
                child: Text('Ver todos',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp))),
          ])),
      SizedBox(height: 1.h),
      _recentOrders.isEmpty
          ? Container(
              padding: EdgeInsets.all(4.w),
              child: Center(
                  child: Text('Nenhum pedido recente encontrado',
                      style: AppTheme.lightTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textSecondaryLight))))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentOrders.length,
              itemBuilder: (context, index) {
                final order = _recentOrders[index];
                return OrderItemWidget(
                    order: order,
                    onStatusUpdate: () => _handleOrderStatusUpdate(order),
                    onContactCustomer: () => _handleContactCustomer(order));
              }),
    ]);
  }

  Widget _buildBottomNavigationBar() {
    return Container(
        decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2)),
            ]),
        child: BottomNavigationBar(
            currentIndex: _selectedTabIndex,
            onTap: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppTheme.lightTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondaryLight,
            selectedLabelStyle: AppTheme.lightTheme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600, fontSize: 10.sp),
            unselectedLabelStyle: AppTheme.lightTheme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w400, fontSize: 10.sp),
            items: [
              BottomNavigationBarItem(
                  icon: CustomIconWidget(
                      iconName: 'dashboard',
                      color: _selectedTabIndex == 0
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.textSecondaryLight,
                      size: 24),
                  label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: CustomIconWidget(
                      iconName: 'receipt_long',
                      color: _selectedTabIndex == 1
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.textSecondaryLight,
                      size: 24),
                  label: 'Pedidos'),
              BottomNavigationBarItem(
                  icon: CustomIconWidget(
                      iconName: 'inventory_2',
                      color: _selectedTabIndex == 2
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.textSecondaryLight,
                      size: 24),
                  label: 'Produtos'),
              BottomNavigationBarItem(
                  icon: CustomIconWidget(
                      iconName: 'analytics',
                      color: _selectedTabIndex == 3
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.textSecondaryLight,
                      size: 24),
                  label: 'Relatórios'),
            ]));
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
        onPressed: () => _showQuickActionsBottomSheet(),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        child: CustomIconWidget(
            iconName: 'add',
            color: AppTheme.lightTheme.colorScheme.surface,
            size: 28));
  }

  Future<void> _handleRefresh() async {
    await _loadDashboardData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Dashboard atualizado!'),
          duration: Duration(seconds: 2)));
    }
  }

  Future<void> _handleOrderStatusUpdate(Map<String, dynamic> order) async {
    try {
      final bakeryService = BakeryService.instance;
      String newStatus = _getNextStatus(order['status']);

      await bakeryService.updateOrderStatus(order['id'], newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Status do pedido ${order['order_number']} atualizado para $newStatus'),
            duration: const Duration(seconds: 2)));
      }

      await _loadDashboardData();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao atualizar status: $error'),
            backgroundColor: AppTheme.errorLight));
      }
    }
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return 'confirmed';
      case 'confirmed':
        return 'preparing';
      case 'preparing':
        return 'ready';
      case 'ready':
        return 'completed';
      default:
        return 'confirmed';
    }
  }

  void _handleContactCustomer(Map<String, dynamic> order) {
    final customer = order['customers'];
    final userProfile = customer?['user_profiles'];
    final customerName = userProfile?['full_name'] ?? 'Cliente';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Entrando em contato com $customerName'),
        duration: const Duration(seconds: 2)));
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Exportando relatório diário...'),
        duration: Duration(seconds: 2)));
  }

  void _showQuickActionsBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Container(
              padding: EdgeInsets.all(4.w),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 12.w,
                    height: 0.5.h,
                    decoration: BoxDecoration(
                        color: AppTheme.borderLight,
                        borderRadius: BorderRadius.circular(10))),
                SizedBox(height: 3.h),
                Text('Ações Rápidas',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 16.sp)),
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
                _buildQuickActionItem('Suporte de Entrega', 'local_shipping',
                    () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/delivery-support');
                }),
                SizedBox(height: 2.h),
              ]));
        });
  }

  Widget _buildQuickActionItem(
      String title, String iconName, VoidCallback onTap) {
    return ListTile(
        leading: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.primaryColor,
                size: 24)),
        title: Text(title,
            style: AppTheme.lightTheme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500, fontSize: 14.sp)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)));
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Container(
              padding: EdgeInsets.all(4.w),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 12.w,
                    height: 0.5.h,
                    decoration: BoxDecoration(
                        color: AppTheme.borderLight,
                        borderRadius: BorderRadius.circular(10))),
                SizedBox(height: 3.h),
                Text('Configurações',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 16.sp)),
                SizedBox(height: 3.h),
                _buildQuickActionItem('Perfil', 'person', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Acessando perfil...')));
                }),
                _buildQuickActionItem('Notificações', 'notifications', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Configurando notificações...')));
                }),
                _buildQuickActionItem('Exportar Relatório', 'file_download',
                    () {
                  Navigator.pop(context);
                  _exportReport();
                }),
                _buildQuickActionItem('Sair', 'logout', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin-login');
                }),
                SizedBox(height: 2.h),
              ]));
        });
  }

  Future<void> _updateChartData() async {
    try {
      final analyticsService = AnalyticsService.instance;
      final chartData = await analyticsService.getRevenueChartData(
        period: _selectedChartPeriod.toLowerCase(),
      );

      setState(() {
        _chartData = chartData;
      });
    } catch (error) {
      debugPrint('Error updating chart data: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar gráfico: $error'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }
}
