import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../services/bakery_service.dart';
import '../../../routes/app_routes.dart';

class CustomerSelectionWidget extends StatefulWidget {
  final Map<String, dynamic>? selectedCustomer;
  final Function(Map<String, dynamic>) onCustomerSelected;

  const CustomerSelectionWidget({
    Key? key,
    required this.selectedCustomer,
    required this.onCustomerSelected,
  }) : super(key: key);

  @override
  State<CustomerSelectionWidget> createState() =>
      _CustomerSelectionWidgetState();
}

class _CustomerSelectionWidgetState extends State<CustomerSelectionWidget> {
  final _searchController = TextEditingController();
  final _bakeryService = BakeryService.instance;

  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final customers = await _bakeryService.getCustomers(limit: 100);
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Erro ao carregar clientes: ${error.toString().replaceAll('Exception: ', '')}';
      });
      _showErrorSnackBar(_errorMessage!);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = _customers;
        _isSearching = false;
      } else {
        _isSearching = true;
        _filteredCustomers = _customers.where((customer) {
          // Safe null checking for nested properties
          final userProfile =
              customer['user_profiles'] as Map<String, dynamic>?;
          final name =
              (userProfile?['full_name'] ?? '').toString().toLowerCase();
          final email = (userProfile?['email'] ?? '').toString().toLowerCase();
          final phone = (customer['phone'] ?? '').toString().toLowerCase();
          final city = (customer['city'] ?? '').toString().toLowerCase();

          return name.contains(query) ||
              email.contains(query) ||
              phone.contains(query) ||
              city.contains(query);
        }).toList();
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNewCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Criar Novo Cliente',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Deseja criar um novo cliente? Você será direcionado para a tela de cadastro.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCustomerRegistration();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B4513),
              foregroundColor: Colors.white,
            ),
            child: Text('Criar Cliente', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  void _navigateToCustomerRegistration() {
    Navigator.pushNamed(context, AppRoutes.customerRegistration,
        arguments: {'returnToManualOrder': true}).then((result) {
      // If customer was created, reload the customer list
      if (result == true) {
        _loadCustomers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cliente criado com sucesso! Selecione-o da lista.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Customer Display
          if (widget.selectedCustomer != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green[600], size: 3.h),
                      SizedBox(width: 2.w),
                      Text(
                        'Cliente Selecionado',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildCustomerCard(widget.selectedCustomer!,
                      isSelected: true),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            Divider(),
            SizedBox(height: 3.h),
          ],

          // Error message
          if (_errorMessage != null && !_isLoading) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red[600], size: 2.5.h),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _errorMessage = null),
                    icon: Icon(Icons.close, color: Colors.red[600]),
                    iconSize: 2.h,
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Search Section
          Text(
            widget.selectedCustomer == null
                ? 'Selecionar Cliente'
                : 'Alterar Cliente',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome, email, telefone ou cidade...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[400],
                ),
                prefixIcon: Icon(Icons.search, color: Color(0xFF8B4513)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              ),
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
          ),

          SizedBox(height: 3.h),

          // New Customer Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: OutlinedButton.icon(
              onPressed: _showNewCustomerDialog,
              icon: Icon(Icons.person_add, size: 2.5.h),
              label: Text(
                'Criar Novo Cliente',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF8B4513),
                side: BorderSide(color: Color(0xFF8B4513)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Retry button if error and not loading
          if (_errorMessage != null && !_isLoading) ...[
            SizedBox(
              width: double.infinity,
              height: 5.h,
              child: ElevatedButton.icon(
                onPressed: _loadCustomers,
                icon: Icon(Icons.refresh, size: 2.h),
                label: Text(
                  'Tentar Novamente',
                  style: GoogleFonts.inter(fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Customers List
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(8.h),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 2.h),
                    Text(
                      'Carregando clientes...',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            // Error state is already handled above with retry button
            SizedBox.shrink()
          else if (_filteredCustomers.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.w),
              child: Column(
                children: [
                  Icon(
                    _isSearching ? Icons.search_off : Icons.people_alt_outlined,
                    size: 8.h,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _isSearching
                        ? 'Nenhum cliente encontrado para "${_searchController.text}"'
                        : 'Nenhum cliente cadastrado',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isSearching) ...[
                    SizedBox(height: 2.h),
                    TextButton(
                      onPressed: () => _searchController.clear(),
                      child: Text(
                        'Limpar busca',
                        style: GoogleFonts.inter(color: Color(0xFF8B4513)),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clientes (${_filteredCustomers.length})',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredCustomers.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final customer = _filteredCustomers[index];
                    final isSelected = widget.selectedCustomer != null &&
                        widget.selectedCustomer!['id'] == customer['id'];

                    return GestureDetector(
                      onTap: () => widget.onCustomerSelected(customer),
                      child:
                          _buildCustomerCard(customer, isSelected: isSelected),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer,
      {bool isSelected = false}) {
    // Safe null checking for nested properties
    final userProfile = customer['user_profiles'] as Map<String, dynamic>?;
    final name = userProfile?['full_name'] ?? 'Cliente Sem Nome';
    final email = userProfile?['email'] ?? '';
    final phone = customer['phone'] ?? '';
    final city = customer['city'] ?? '';
    final isVip = customer['is_vip'] ?? false;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF8B4513).withAlpha(26) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Color(0xFF8B4513) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 3.h,
                backgroundColor: Color(0xFF8B4513).withAlpha(51),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'C',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVip) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.w),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'VIP',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber[800],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (email.isNotEmpty) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF8B4513),
                  size: 3.h,
                ),
            ],
          ),
          if (phone.isNotEmpty || city.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                if (phone.isNotEmpty) ...[
                  Icon(Icons.phone, size: 2.h, color: Colors.grey[500]),
                  SizedBox(width: 1.w),
                  Flexible(
                    child: Text(
                      phone,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (phone.isNotEmpty && city.isNotEmpty) ...[
                  SizedBox(width: 4.w),
                  Container(
                    width: 1,
                    height: 2.h,
                    color: Colors.grey[300],
                  ),
                  SizedBox(width: 4.w),
                ],
                if (city.isNotEmpty) ...[
                  Icon(Icons.location_on, size: 2.h, color: Colors.grey[500]),
                  SizedBox(width: 1.w),
                  Flexible(
                    child: Text(
                      city,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
