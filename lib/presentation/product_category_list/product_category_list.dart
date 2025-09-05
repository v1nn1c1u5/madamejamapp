import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/bakery_service.dart';
import '../../services/cart_service.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_modal_widget.dart';
import './widgets/product_card_widget.dart';
import './widgets/product_filter_chip_widget.dart';
import './widgets/skeleton_card_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';

class ProductCategoryList extends StatefulWidget {
  const ProductCategoryList({super.key});

  @override
  State<ProductCategoryList> createState() => _ProductCategoryListState();
}

class _ProductCategoryListState extends State<ProductCategoryList> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedCategoryId;
  String _selectedCategoryName = 'Todos';
  String _currentSort = 'relevance';
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 200);
  bool _showAvailableOnly = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  final int _itemsPerPage = 10;

  // Real data from Supabase
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  List<Map<String, dynamic>> _displayedProducts = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bakeryService = BakeryService.instance;

      // Get category name from route arguments before async operations
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      // Load categories and products in parallel
      final results = await Future.wait([
        bakeryService.getProductCategories(),
        bakeryService.getProducts(status: 'active'),
      ]);

      _categories = results[0];
      _allProducts = results[1];

      // Process route arguments after async operations
      if (args != null && args['categoryId'] != null) {
        _selectedCategoryId = args['categoryId'];
        final category = _categories.firstWhere(
          (cat) => cat['id'] == _selectedCategoryId,
          orElse: () => {'name': 'Categoria'},
        );
        _selectedCategoryName = category['name'];
      }

      _applyFilters();
    } catch (error) {
      debugPrint('Error loading products: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar produtos: $error'),
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  void _loadMoreProducts() {
    if (_isLoadingMore ||
        _displayedProducts.length >= _filteredProducts.length) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      final nextBatch = _filteredProducts
          .skip(_displayedProducts.length)
          .take(_itemsPerPage)
          .toList();

      setState(() {
        _displayedProducts.addAll(nextBatch);
        _isLoadingMore = false;
      });
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allProducts);

    // Filter by category
    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((product) => product['category_id'] == _selectedCategoryId)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        final description =
            product['description']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    // Filter by price range
    filtered = filtered.where((product) {
      final price = product['price'] ?? 0.0;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    // Filter by availability
    if (_showAvailableOnly) {
      filtered = filtered
          .where((product) =>
              product['status'] == 'active' &&
              (product['stock_quantity'] ?? 0) > 0)
          .toList();
    }

    // Sort products
    switch (_currentSort) {
      case 'price_low':
        filtered
            .sort((a, b) => (a['price'] ?? 0.0).compareTo(b['price'] ?? 0.0));
        break;
      case 'price_high':
        filtered
            .sort((a, b) => (b['price'] ?? 0.0).compareTo(a['price'] ?? 0.0));
        break;
      case 'name':
        filtered.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
        break;
      case 'newest':
        filtered.sort((a, b) => DateTime.parse(b['created_at'] ?? '1970-01-01')
            .compareTo(DateTime.parse(a['created_at'] ?? '1970-01-01')));
        break;
      default: // relevance
        // Keep original order or implement relevance scoring
        break;
    }

    setState(() {
      _filteredProducts = filtered;
      _displayedProducts = filtered.take(_itemsPerPage).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _priceRange = const RangeValues(0, 200);
      _showAvailableOnly = false;
      _searchController.clear();
    });
    _applyFilters();
  }

  List<Widget> _buildActiveFilters() {
    List<Widget> filters = [];

    if (_searchQuery.isNotEmpty) {
      filters.add(ProductFilterChipWidget(
        label: 'Busca: $_searchQuery',
        count: 0,
        onRemove: () {
          setState(() {
            _searchQuery = '';
            _searchController.clear();
          });
          _applyFilters();
        },
      ));
    }

    if (_priceRange.start > 0 || _priceRange.end < 200) {
      filters.add(ProductFilterChipWidget(
        label:
            'R\$ ${_priceRange.start.round()} - R\$ ${_priceRange.end.round()}',
        count: 0,
        onRemove: () {
          setState(() {
            _priceRange = const RangeValues(0, 200);
          });
          _applyFilters();
        },
      ));
    }

    if (_showAvailableOnly) {
      filters.add(ProductFilterChipWidget(
        label: 'Disponíveis',
        count: _filteredProducts
            .where((p) =>
                p['status'] == 'active' && (p['stock_quantity'] ?? 0) > 0)
            .length,
        onRemove: () {
          setState(() {
            _showAvailableOnly = false;
          });
          _applyFilters();
        },
      ));
    }

    return filters;
  }

  @override
  Widget build(BuildContext context) {
    final activeFilters = _buildActiveFilters();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            size: 24,
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
          ),
        ),
        title: Text(
          _selectedCategoryName,
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FilterModalWidget(
                  priceRange: _priceRange,
                  showAvailableOnly: _showAvailableOnly,
                  onFiltersChanged: (priceRange, showAvailableOnly) {
                    setState(() {
                      _priceRange = priceRange;
                      _showAvailableOnly = showAvailableOnly;
                    });
                    _applyFilters();
                  },
                ),
              );
            },
            icon: CustomIconWidget(
              iconName: 'tune',
              size: 24,
              color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(4.w),
            color: AppTheme.lightTheme.colorScheme.surface,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                          _applyFilters();
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          size: 20,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline,
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
            ),
          ),
          // Active filters
          if (activeFilters.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              color: AppTheme.lightTheme.colorScheme.surface,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: activeFilters,
                ),
              ),
            ),
          // Products list
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => const SkeletonCardWidget(),
                  )
                : _displayedProducts.isEmpty
                    ? EmptyStateWidget(onClearFilters: _clearFilters)
                    : RefreshIndicator(
                        onRefresh: () async {
                          _loadInitialData();
                        },
                        color: AppTheme.lightTheme.colorScheme.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _displayedProducts.length +
                              (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _displayedProducts.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final product = _displayedProducts[index];
                            return ProductCardWidget(
                              product: product,
                              onViewDetails: () {
                                HapticFeedback.lightImpact();
                                Navigator.pushNamed(
                                  context,
                                  '/product-detail',
                                  arguments: {'productId': product['id']},
                                );
                              },
                              onAddToCart: () async {
                                await _addToCart(product);
                              },
                              onFavorite: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${product['name']} adicionado aos favoritos'),
                                    backgroundColor:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                );
                              },
                              onShare: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Produto compartilhado'),
                                  ),
                                );
                              },
                              onSimilarItems: () {
                                HapticFeedback.lightImpact();
                                Navigator.pushNamed(
                                    context, '/product-category-list');
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => SortBottomSheetWidget(
              currentSort: _currentSort,
              onSortChanged: (sort) {
                setState(() {
                  _currentSort = sort;
                });
                _applyFilters();
              },
            ),
          );
        },
        child: CustomIconWidget(
          iconName: 'sort',
          size: 24,
          color: AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor!,
        ),
      ),
    );
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    try {
      HapticFeedback.mediumImpact();

      final cartService = CartService.instance;
      final images = product['product_images'] as List<dynamic>? ?? [];
      final primaryImage = images.isNotEmpty
          ? images.firstWhere(
              (img) => img['is_primary'] == true,
              orElse: () => images.first,
            )['image_url']
          : null;

      await cartService.addItem(
        productId: product['id'],
        name: product['name'] ?? 'Produto',
        price: (product['price'] ?? 0.0).toDouble(),
        imageUrl: primaryImage,
        description: product['description'],
        quantity: 1,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product['name']} adicionado ao carrinho',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'VER CARRINHO',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/shopping-cart');
              },
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar ao carrinho: $error'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }
}
