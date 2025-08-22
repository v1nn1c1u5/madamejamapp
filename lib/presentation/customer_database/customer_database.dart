import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/customer_service.dart';
import './widgets/customer_card_widget.dart';
import './widgets/customer_filter_widget.dart';
import './widgets/customer_search_widget.dart';
import './widgets/customer_skeleton_widget.dart';
import './widgets/empty_customers_widget.dart';

class CustomerDatabase extends StatefulWidget {
  const CustomerDatabase({super.key});

  @override
  State<CustomerDatabase> createState() => _CustomerDatabaseState();
}

class _CustomerDatabaseState extends State<CustomerDatabase>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  String _selectedFilter = 'Todos';
  bool _isLoading = true;

  final List<String> _filterOptions = ['Todos', 'Ativos', 'Inativos', 'VIP'];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final customers = await CustomerService.instance.getAllCustomers(
        orderBy: 'created_at',
        ascending: false,
      );

      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _isLoading = false;
      });

      _applyFilters();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar clientes: $error'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadCustomers();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredCustomers = _customers.where((customer) {
        final userProfile =
            customer['user_profiles'] as Map<String, dynamic>? ?? {};
        // Fallback para campos flatten
        final fullName = (userProfile['full_name'] ?? customer['full_name'])
            ?.toString()
            .toLowerCase();
        final email = (userProfile['email'] ?? customer['email'])
            ?.toString()
            .toLowerCase();
        final isActive = userProfile.isNotEmpty
            ? userProfile['is_active']
            : customer['is_active'];

        bool matchesSearch = query.isEmpty ||
            (fullName?.contains(query) ?? false) ||
            (customer['phone']?.toString().toLowerCase().contains(query) ??
                false) ||
            (email?.contains(query) ?? false) ||
            (customer['id']?.toString().toLowerCase().contains(query) ?? false);

        bool matchesFilter = _selectedFilter == 'Todos' ||
            (_selectedFilter == 'Ativos' && (isActive == true)) ||
            (_selectedFilter == 'Inativos' && (isActive != true)) ||
            (_selectedFilter == 'VIP' && customer['is_vip'] == true);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }

  void _addNewCustomer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em desenvolvimento: Adicionar Cliente'),
      ),
    );
  }

  void _exportCustomers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando lista de clientes...'),
      ),
    );
  }

  int _getFilterCount(String filter) {
    if (filter == 'Todos') return _customers.length;
    return _customers.where((customer) {
      final userProfile =
          customer['user_profiles'] as Map<String, dynamic>? ?? {};
      final isActive = userProfile.isNotEmpty
          ? userProfile['is_active']
          : customer['is_active'];

      switch (filter) {
        case 'Ativos':
          return isActive == true;
        case 'Inativos':
          return isActive != true;
        case 'VIP':
          return customer['is_vip'] == true;
        default:
          return true;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.lightTheme.primaryColor,
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchSection(),
            _buildFilterSection(),
            Expanded(
              child: _buildCustomerList(),
            ),
          ],
        ),
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
        'Base de Clientes',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _exportCustomers,
          icon: CustomIconWidget(
            iconName: 'file_download',
            color: AppTheme.textPrimaryLight,
            size: 24,
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_customers.length clientes',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              Text(
                '$_filteredCustomers.length visíveis',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'trending_up',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${_customers.where((c) => c['is_vip'] == true).length} VIP',
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
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: CustomerSearchWidget(
        controller: _searchController,
        onVoicePressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Busca por voz em desenvolvimento'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      height: 8.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _filterOptions.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final count = _getFilterCount(filter);
          return CustomerFilterWidget(
            title: filter,
            count: count,
            isSelected: _selectedFilter == filter,
            onTap: () => _onFilterChanged(filter),
          );
        },
      ),
    );
  }

  Widget _buildCustomerList() {
    if (_isLoading) {
      return ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: const CustomerSkeletonWidget(),
          );
        },
      );
    }

    if (_filteredCustomers.isEmpty && _customers.isNotEmpty) {
      return const EmptyCustomersWidget(
        title: 'Nenhum cliente encontrado',
        subtitle: 'Tente ajustar os filtros ou busca',
        showAddButton: false,
      );
    }

    if (_customers.isEmpty) {
      return EmptyCustomersWidget(
        title: 'Nenhum cliente cadastrado',
        subtitle: 'Comece adicionando o primeiro cliente',
        onAddPressed: _addNewCustomer,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: CustomerCardWidget(
            customer: customer,
            onTap: () => _viewCustomerDetails(customer),
            onMessageTap: () => _sendMessage(customer),
            onCallTap: () => _callCustomer(customer),
            onEditTap: () => _editCustomer(customer),
            onOrderTap: () => _createOrder(customer),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _addNewCustomer,
      backgroundColor: AppTheme.lightTheme.primaryColor,
      child: CustomIconWidget(
        iconName: 'person_add',
        color: AppTheme.lightTheme.colorScheme.surface,
        size: 24,
      ),
    );
  }

  void _viewCustomerDetails(Map<String, dynamic> customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCustomerDetailsModal(customer),
    );
  }

  Widget _buildCustomerDetailsModal(Map<String, dynamic> customer) {
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
                  _buildCustomerDetailHeader(customer),
                  SizedBox(height: 3.h),
                  _buildCustomerDetailInfo(customer),
                  SizedBox(height: 3.h),
                  _buildCustomerActions(customer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailHeader(Map<String, dynamic> customer) {
    final userProfile =
        customer['user_profiles'] as Map<String, dynamic>? ?? {};

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.lightTheme.primaryColor,
          child: Text(
            (userProfile['full_name']
                    ?.toString()
                    .substring(0, 1)
                    .toUpperCase()) ??
                'C',
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProfile['full_name']?.toString() ?? 'Nome não informado',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                customer['id']?.toString().substring(0, 8) ?? '',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 1.h),
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                      customer['is_vip'], userProfile['is_active']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(customer['is_vip'], userProfile['is_active']),
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

  Widget _buildCustomerDetailInfo(Map<String, dynamic> customer) {
    final userProfile =
        customer['user_profiles'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações de Contato',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildInfoRow('Nome',
                userProfile['full_name']?.toString() ?? 'Não informado'),
            _buildInfoRow(
                'Email', userProfile['email']?.toString() ?? 'Não informado'),
            _buildInfoRow(
                'Telefone', customer['phone']?.toString() ?? 'Não informado'),
            _buildInfoRow(
                'Cidade', customer['city']?.toString() ?? 'Não informado'),
            _buildInfoRow(
                'Estado', customer['state']?.toString() ?? 'Não informado'),
            _buildInfoRow(
                'CEP', customer['postal_code']?.toString() ?? 'Não informado'),
            _buildInfoRow('VIP', customer['is_vip'] == true ? 'Sim' : 'Não'),
            if (customer['delivery_notes']?.toString().isNotEmpty == true)
              _buildInfoRow(
                  'Observações', customer['delivery_notes'].toString()),
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

  Widget _buildCustomerActions(Map<String, dynamic> customer) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _sendMessage(customer),
                icon: CustomIconWidget(
                  iconName: 'message',
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text('Mensagem'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _callCustomer(customer),
                icon: CustomIconWidget(
                  iconName: 'call',
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text('Ligar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
                onPressed: () => _createOrder(customer),
                icon: CustomIconWidget(
                  iconName: 'add_shopping_cart',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
                label: const Text('Novo Pedido'),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editCustomer(customer),
                icon: CustomIconWidget(
                  iconName: 'edit',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
                label: const Text('Editar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(bool? isVip, bool? isActive) {
    if (isVip == true) {
      return Colors.purple;
    }
    if (isActive == true) {
      return Colors.green;
    }
    return Colors.orange;
  }

  String _getStatusText(bool? isVip, bool? isActive) {
    if (isVip == true) {
      return 'VIP';
    }
    if (isActive == true) {
      return 'Ativo';
    }
    return 'Inativo';
  }

  void _sendMessage(Map<String, dynamic> customer) {
    final userProfile =
        customer['user_profiles'] as Map<String, dynamic>? ?? {};
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Enviando mensagem para ${userProfile['full_name'] ?? 'Cliente'}'),
      ),
    );
  }

  void _callCustomer(Map<String, dynamic> customer) {
    final userProfile =
        customer['user_profiles'] as Map<String, dynamic>? ?? {};
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ligando para ${userProfile['full_name'] ?? 'Cliente'}'),
      ),
    );
  }

  void _editCustomer(Map<String, dynamic> customer) {
    final userProfile =
        customer['user_profiles'] as Map<String, dynamic>? ?? {};
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editando ${userProfile['full_name'] ?? 'Cliente'}'),
      ),
    );
  }

  void _createOrder(Map<String, dynamic> customer) {
    final userProfile =
        customer['user_profiles'] as Map<String, dynamic>? ?? {};
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Criando pedido para ${userProfile['full_name'] ?? 'Cliente'}'),
      ),
    );
  }
}
