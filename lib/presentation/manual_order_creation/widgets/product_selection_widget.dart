import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/bakery_service.dart';

class ProductSelectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(Map<String, dynamic>, int) onAddToCart;
  final Function(int) onRemoveFromCart;
  final Function(int, int) onUpdateQuantity;
  final Function(int, String) onUpdateInstructions;

  const ProductSelectionWidget({
    Key? key,
    required this.cartItems,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.onUpdateQuantity,
    required this.onUpdateInstructions,
  }) : super(key: key);

  @override
  State<ProductSelectionWidget> createState() => _ProductSelectionWidgetState();
}

class _ProductSelectionWidgetState extends State<ProductSelectionWidget>
    with TickerProviderStateMixin {
  late TabController _categoryTabController;
  final _bakeryService = BakeryService.instance;
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _categoryTabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _bakeryService.getProductCategories();
      final products = await _bakeryService.getProducts(status: 'active');

      setState(() {
        _categories = [
          {'id': null, 'name': 'Todos'},
          ...categories
        ];
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });

      _categoryTabController =
          TabController(length: _categories.length, vsync: this);
      _categoryTabController.addListener(() {
        if (!_categoryTabController.indexIsChanging) {
          _onCategoryChanged(_categoryTabController.index);
        }
      });
    } catch (error) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erro ao carregar produtos: $error');
    }
  }

  void _onCategoryChanged(int index) {
    final categoryId = _categories[index]['id'];
    setState(() {
      _selectedCategoryId = categoryId;
      _filterProducts();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _filterProducts();
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase().trim();
    _isSearching = query.isNotEmpty;

    setState(() {
      _filteredProducts = _products.where((product) {
        // Category filter
        final categoryMatch = _selectedCategoryId == null ||
            product['category_id'] == _selectedCategoryId;

        // Search filter
        final searchMatch = query.isEmpty ||
            product['name'].toLowerCase().contains(query) ||
            (product['description'] ?? '').toLowerCase().contains(query);

        return categoryMatch && searchMatch;
      }).toList();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Cart Summary Bar
        if (widget.cartItems.isNotEmpty) ...[
          Container(
            color: Color(0xFF8B4513).withAlpha(26),
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Icon(Icons.shopping_cart, color: Color(0xFF8B4513), size: 3.h),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    '${widget.cartItems.length} item${widget.cartItems.length != 1 ? 's' : ''} no carrinho',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                ),
                Text(
                  'R\$ ${_calculateCartTotal().toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Search Bar
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(4.w),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar produtos...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[400],
              ),
              prefixIcon: Icon(Icons.search, color: Color(0xFF8B4513)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () => _searchController.clear(),
                      icon: Icon(Icons.clear, color: Colors.grey[400]),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF8B4513), width: 2),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            ),
            style: GoogleFonts.inter(fontSize: 14.sp),
          ),
        ),

        // Category Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _categoryTabController,
            isScrollable: true,
            labelColor: Color(0xFF8B4513),
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Color(0xFF8B4513),
            tabs: _categories
                .map((category) => Tab(text: category['name']))
                .toList(),
          ),
        ),

        // Products List
        Expanded(
          child: _filteredProducts.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: EdgeInsets.all(4.w),
                  itemCount: _filteredProducts.length,
                  separatorBuilder: (context, index) => SizedBox(height: 3.h),
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return _buildProductCard(product);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSearching ? Icons.search_off : Icons.inventory_2_outlined,
              size: 8.h,
              color: Colors.grey[400],
            ),
            SizedBox(height: 2.h),
            Text(
              _isSearching
                  ? 'Nenhum produto encontrado para "${_searchController.text}"'
                  : 'Nenhum produto disponível nesta categoria',
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
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final images = product['product_images'] as List<dynamic>? ?? [];
    final primaryImage = images.isNotEmpty
        ? images.firstWhere(
            (img) => img['is_primary'] == true,
            orElse: () => images.first,
          )
        : null;

    final cartQuantity = _getCartQuantity(product['id']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 20.h,
              width: double.infinity,
              child: primaryImage != null
                  ? CachedNetworkImage(
                      imageUrl: primaryImage['image_url'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF8B4513)),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey[400], size: 6.h),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.bakery_dining,
                          color: Colors.grey[400], size: 6.h),
                    ),
            ),
          ),

          // Product Info
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name and Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'R\$ ${product['price'].toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Add to Cart Controls
                    if (cartQuantity == 0)
                      ElevatedButton.icon(
                        onPressed: () => widget.onAddToCart(product, 1),
                        icon: Icon(Icons.add_shopping_cart, size: 2.h),
                        label: Text('Adicionar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8B4513),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF8B4513).withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFF8B4513)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                final index = _findCartItemIndex(product['id']);
                                if (index != -1) {
                                  widget.onUpdateQuantity(
                                      index, cartQuantity - 1);
                                }
                              },
                              icon: Icon(Icons.remove, size: 2.h),
                              color: Color(0xFF8B4513),
                            ),
                            Text(
                              cartQuantity.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                final index = _findCartItemIndex(product['id']);
                                if (index != -1) {
                                  widget.onUpdateQuantity(
                                      index, cartQuantity + 1);
                                }
                              },
                              icon: Icon(Icons.add, size: 2.h),
                              color: Color(0xFF8B4513),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Product Description
                if (product['description'] != null &&
                    product['description'].isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    product['description'],
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Product Features
                SizedBox(height: 2.h),
                Wrap(
                  spacing: 1.w,
                  runSpacing: 1.w,
                  children: [
                    if (product['is_gluten_free'] == true)
                      _buildFeatureChip(
                          'Sem Glúten', Icons.help_outline, Colors.green),
                    if (product['is_vegan'] == true)
                      _buildFeatureChip('Vegano', Icons.eco, Colors.green),
                    if (product['preparation_time_minutes'] != null)
                      _buildFeatureChip(
                          '${product['preparation_time_minutes']}min',
                          Icons.schedule,
                          Colors.blue),
                    if (product['stock_quantity'] != null &&
                        product['stock_quantity'] <=
                            (product['min_stock_level'] ?? 5))
                      _buildFeatureChip(
                          'Estoque Baixo', Icons.warning, Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 1.5.h, color: color),
          SizedBox(width: 1.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  int _getCartQuantity(String productId) {
    final item = widget.cartItems.firstWhere(
      (item) => item['product_id'] == productId,
      orElse: () => <String, dynamic>{},
    );
    return item['quantity'] ?? 0;
  }

  int _findCartItemIndex(String productId) {
    return widget.cartItems
        .indexWhere((item) => item['product_id'] == productId);
  }

  double _calculateCartTotal() {
    return widget.cartItems.fold(0.0, (sum, item) => sum + item['total_price']);
  }
}
