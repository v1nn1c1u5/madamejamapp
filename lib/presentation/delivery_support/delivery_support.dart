import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import './widgets/delivery_card_widget.dart';
import './widgets/delivery_filter_widget.dart';
import './widgets/delivery_map_widget.dart';
import './widgets/delivery_stats_widget.dart';
import './widgets/empty_deliveries_widget.dart';
import './widgets/support_ticket_widget.dart';

class DeliverySupport extends StatefulWidget {
  const DeliverySupport({Key? key}) : super(key: key);

  @override
  State<DeliverySupport> createState() => _DeliverySupportState();
}

class _DeliverySupportState extends State<DeliverySupport>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _deliveries = [];
  List<Map<String, dynamic>> _supportTickets = [];
  List<Map<String, dynamic>> _filteredDeliveries = [];

  String _selectedStatus = 'Todos';
  bool _isLoading = true;
  bool _isRefreshing = false;

  final List<String> _statusOptions = [
    'Todos',
    'Pendente',
    'Coletado',
    'Em Trânsito',
    'Entregue',
    'Problema'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await Future.wait([
        _loadDeliveries(),
        _loadSupportTickets(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $error'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  Future<void> _loadDeliveries() async {
    final client = SupabaseService.instance.client;
    final response = await client.from('deliveries').select('''
          *,
          customer_profiles(full_name, phone, customer_code),
          customer_addresses(street_address, neighborhood, city),
          user_profiles(full_name)
        ''').order('created_at', ascending: false);

    _deliveries = List<Map<String, dynamic>>.from(response);
    _filteredDeliveries = _deliveries;
    _applyFilters();
  }

  Future<void> _loadSupportTickets() async {
    final client = SupabaseService.instance.client;
    final response = await client.from('delivery_support_tickets').select('''
          *,
          customer_profiles(full_name, phone),
          deliveries(delivery_code, order_value)
        ''').eq('status', 'aberto').order('created_at', ascending: false);

    _supportTickets = List<Map<String, dynamic>>.from(response);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadData();

    setState(() {
      _isRefreshing = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredDeliveries = _deliveries.where((delivery) {
        if (_selectedStatus == 'Todos') return true;

        String status = delivery['delivery_status'] ?? '';
        switch (_selectedStatus) {
          case 'Pendente':
            return status == 'pendente';
          case 'Coletado':
            return status == 'coletado';
          case 'Em Trânsito':
            return status == 'em_transito';
          case 'Entregue':
            return status == 'entregue';
          case 'Problema':
            return status == 'problema';
          default:
            return true;
        }
      }).toList();
    });
  }

  void _onStatusFilterChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
    _applyFilters();
  }

  int _getStatusCount(String status) {
    if (status == 'Todos') return _deliveries.length;

    return _deliveries.where((delivery) {
      String deliveryStatus = delivery['delivery_status'] ?? '';
      switch (status) {
        case 'Pendente':
          return deliveryStatus == 'pendente';
        case 'Coletado':
          return deliveryStatus == 'coletado';
        case 'Em Trânsito':
          return deliveryStatus == 'em_transito';
        case 'Entregue':
          return deliveryStatus == 'entregue';
        case 'Problema':
          return deliveryStatus == 'problema';
        default:
          return false;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppTheme.lightTheme.primaryColor,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDeliveryManagementTab(),
                  _buildMapViewTab(),
                  _buildSupportTab(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back_ios',
          color: AppTheme.textPrimaryLight,
          size: 24,
        ),
      ),
      title: Text(
        'Suporte de Entrega',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Contactando suporte emergencial...')),
            );
          },
          icon: CustomIconWidget(
            iconName: 'emergency',
            color: Colors.red,
            size: 24,
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.lightTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondaryLight,
        indicatorColor: AppTheme.lightTheme.primaryColor,
        labelStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
        unselectedLabelStyle:
            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 12.sp,
        ),
        tabs: const [
          Tab(text: 'Entregas'),
          Tab(text: 'Mapa'),
          Tab(text: 'Suporte'),
        ],
      ),
    );
  }

  Widget _buildDeliveryManagementTab() {
    return Column(
      children: [
        DeliveryStatsWidget(deliveries: _deliveries),
        _buildFilterSection(),
        Expanded(child: _buildDeliveryList()),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      height: 8.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _statusOptions.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final status = _statusOptions[index];
          final count = _getStatusCount(status);
          return DeliveryFilterWidget(
            title: status,
            count: count,
            isSelected: _selectedStatus == status,
            onTap: () => _onStatusFilterChanged(status),
          );
        },
      ),
    );
  }

  Widget _buildDeliveryList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredDeliveries.isEmpty && _deliveries.isNotEmpty) {
      return const EmptyDeliveriesWidget(
        title: 'Nenhuma entrega encontrada',
        subtitle: 'Tente ajustar os filtros selecionados',
        showAddButton: false,
      );
    }

    if (_deliveries.isEmpty) {
      return EmptyDeliveriesWidget(
        title: 'Nenhuma entrega cadastrada',
        subtitle: 'As entregas aparecerão aqui automaticamente',
        onAddPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Redirecionando para criar pedido...')),
          );
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _filteredDeliveries.length,
      itemBuilder: (context, index) {
        final delivery = _filteredDeliveries[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: DeliveryCardWidget(
            delivery: delivery,
            onTap: () => _viewDeliveryDetails(delivery),
            onStatusUpdate: () => _updateDeliveryStatus(delivery),
            onContactCustomer: () => _contactCustomer(delivery),
            onTrackDelivery: () => _trackDelivery(delivery),
            onReportIssue: () => _reportIssue(delivery),
          ),
        );
      },
    );
  }

  Widget _buildMapViewTab() {
    return DeliveryMapWidget(
      deliveries: _deliveries,
      onDeliveryTap: _viewDeliveryDetails,
    );
  }

  Widget _buildSupportTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_supportTickets.isEmpty) {
      return const EmptyDeliveriesWidget(
        title: 'Nenhum ticket aberto',
        subtitle: 'Todos os problemas foram resolvidos',
        showAddButton: false,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _supportTickets.length,
      itemBuilder: (context, index) {
        final ticket = _supportTickets[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: SupportTicketWidget(
            ticket: ticket,
            onTap: () => _viewTicketDetails(ticket),
            onResolve: () => _resolveTicket(ticket),
            onAssign: () => _assignTicket(ticket),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Criando nova entrega...')),
        );
      },
      backgroundColor: AppTheme.lightTheme.primaryColor,
      child: CustomIconWidget(
        iconName: 'local_shipping',
        color: Colors.white,
        size: 24,
      ),
    );
  }

  void _viewDeliveryDetails(Map<String, dynamic> delivery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDeliveryDetailsModal(delivery),
    );
  }

  Widget _buildDeliveryDetailsModal(Map<String, dynamic> delivery) {
    final customer =
        delivery['customer_profiles'] as Map<String, dynamic>? ?? {};
    final address =
        delivery['customer_addresses'] as Map<String, dynamic>? ?? {};
    final assignedUser =
        delivery['user_profiles'] as Map<String, dynamic>? ?? {};

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDeliveryDetailHeader(delivery),
                  SizedBox(height: 3.h),
                  _buildDeliveryInfo(delivery, customer, address, assignedUser),
                  SizedBox(height: 3.h),
                  _buildDeliveryActions(delivery),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetailHeader(Map<String, dynamic> delivery) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: 'local_shipping',
            color: AppTheme.lightTheme.primaryColor,
            size: 24,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                delivery['delivery_code'] ?? 'Código não informado',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'R\$ ${delivery['order_value']?.toStringAsFixed(2) ?? '0,00'}',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 1.h),
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getDeliveryStatusColor(delivery['delivery_status']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getDeliveryStatusText(delivery['delivery_status']),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo(
    Map<String, dynamic> delivery,
    Map<String, dynamic> customer,
    Map<String, dynamic> address,
    Map<String, dynamic> assignedUser,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhes da Entrega',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildInfoRow('Cliente', customer['full_name'] ?? 'Não informado'),
            _buildInfoRow('Telefone', customer['phone'] ?? 'Não informado'),
            _buildInfoRow('Endereço',
                '${address['street_address'] ?? ''}\n${address['neighborhood'] ?? ''}, ${address['city'] ?? ''}'),
            _buildInfoRow(
                'Entregador', assignedUser['full_name'] ?? 'Não atribuído'),
            _buildInfoRow(
                'Instruções', delivery['delivery_instructions'] ?? 'Nenhuma'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryActions(Map<String, dynamic> delivery) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _contactCustomer(delivery),
                icon: CustomIconWidget(
                  iconName: 'call',
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text('Contatar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateDeliveryStatus(delivery),
                icon: CustomIconWidget(
                  iconName: 'update',
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text('Atualizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _trackDelivery(delivery),
                icon: CustomIconWidget(
                  iconName: 'location_on',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
                label: const Text('Rastrear'),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _reportIssue(delivery),
                icon: CustomIconWidget(
                  iconName: 'report_problem',
                  color: Colors.red,
                  size: 20,
                ),
                label: const Text('Problema'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getDeliveryStatusColor(String? status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'coletado':
        return Colors.blue;
      case 'em_transito':
        return Colors.purple;
      case 'entregue':
        return Colors.green;
      case 'problema':
        return Colors.red;
      case 'cancelado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getDeliveryStatusText(String? status) {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'coletado':
        return 'Coletado';
      case 'em_transito':
        return 'Em Trânsito';
      case 'entregue':
        return 'Entregue';
      case 'problema':
        return 'Problema';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Desconhecido';
    }
  }

  void _updateDeliveryStatus(Map<String, dynamic> delivery) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Atualizando status da entrega ${delivery['delivery_code']}'),
      ),
    );
  }

  void _contactCustomer(Map<String, dynamic> delivery) {
    Navigator.pop(context);
    final customer =
        delivery['customer_profiles'] as Map<String, dynamic>? ?? {};
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contatando ${customer['full_name'] ?? 'cliente'}'),
      ),
    );
  }

  void _trackDelivery(Map<String, dynamic> delivery) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rastreando entrega ${delivery['delivery_code']}'),
      ),
    );
  }

  void _reportIssue(Map<String, dynamic> delivery) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Reportando problema na entrega ${delivery['delivery_code']}'),
      ),
    );
  }

  void _viewTicketDetails(Map<String, dynamic> ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visualizando ticket ${ticket['ticket_number']}'),
      ),
    );
  }

  void _resolveTicket(Map<String, dynamic> ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Resolvendo ticket ${ticket['ticket_number']}'),
      ),
    );
  }

  void _assignTicket(Map<String, dynamic> ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Atribuindo ticket ${ticket['ticket_number']}'),
      ),
    );
  }
}
