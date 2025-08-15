import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_modal_widget.dart';
import './widgets/product_card_widget.dart';
import './widgets/product_filter_chip_widget.dart';
import './widgets/skeleton_card_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';

class ProductCategoryList extends StatefulWidget {
  const ProductCategoryList({Key? key}) : super(key: key);

  @override
  State<ProductCategoryList> createState() => _ProductCategoryListState();
}

class _ProductCategoryListState extends State<ProductCategoryList> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'Pães Pequenos';
  String _currentSort = 'relevance';
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 200);
  bool _showAvailableOnly = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Mock data for bakery products
  final List<Map<String, dynamic>> _allProducts = [
    {
      "id": 1,
      "name": "Pão Francês Artesanal",
      "description":
          "Pão francês tradicional feito com fermentação natural e ingredientes selecionados. Crocante por fora, macio por dentro.",
      "price": "R\$ 0,80",
      "priceValue": 0.80,
      "category": "Pães Pequenos",
      "available": true,
      "image":
          "https://images.pexels.com/photos/209206/pexels-photo-209206.jpeg?auto=compress&cs=tinysrgb&w=800",
      "popularity": 95,
    },
    {
      "id": 2,
      "name": "Pão de Açúcar Integral",
      "description":
          "Pão doce integral com açúcar mascavo e canela. Rico em fibras e sabor único da casa.",
      "price": "R\$ 1,20",
      "priceValue": 1.20,
      "category": "Pães Pequenos",
      "available": true,
      "image":
          "https://images.pexels.com/photos/1775043/pexels-photo-1775043.jpeg?auto=compress&cs=tinysrgb&w=800",
      "popularity": 88,
    },
    {
      "id": 3,
      "name": "Bolo de Chocolate Belga",
      "description":
          "Bolo úmido de chocolate belga com cobertura cremosa. Perfeito para ocasiões especiais.",
      "price": "R\$ 45,00",
      "priceValue": 45.00,
      "category": "Bolos",
      "available": true,
      "image":
          "https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg?auto=compress&cs=tinysrgb&w=800",
      "popularity": 92,
    },
    {
      "id": 4,
      "name": "Torta Salgada de Frango",
      "description":
          "Torta salgada com recheio de frango desfiado, legumes e temperos especiais da casa.",
      "price": "R\$ 32,00",
      "priceValue": 32.00,
      "category": "Tortas Salgadas",
      "available": false,
      "image":
          "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=800",
      "popularity": 85,
    },
    {
      "id": 5,
      "name": "Pão de Queijo Mineiro",
      "description":
          "Pão de queijo tradicional mineiro, feito com polvilho doce e queijo minas curado.",
      "price": "R\$ 2,50",
      "priceValue": 2.50,
      "category": "Pães Pequenos",
      "available": true,
      "image":
          "https://images.pexels.com/photos/4686818/pexels-photo-4686818.jpeg?auto=compress&cs=tinysrgb&w=800",
      "popularity": 90,
    },
    {
      "id": 6,
      "name": "Bolo Red Velvet",
      "description":
          "Bolo red velvet com cream cheese e decoração artesanal. Uma delícia americana com toque brasileiro.",
      "price": "R\$ 55,00",
      "priceValue": 55.00,
      "category": "Bolos",
      "available": true,
      "image":
          "https://images.pexels.com/photos/1721932/pexels-photo-1721932.jpeg?auto=compress&cs=tinysrgb&w=800",
      "popularity": 87,
    },
    {
      "id": 7,
      "name": "Torta de Palmito",
      "description":
          "Torta salgada vegetariana com palmito, queijo e ervas finas. Opção saudável e saborosa.",
      "price": "R\$ 28,00",
      "priceValue": 28.00,
      "category": "Tortas Salgadas",
      "available": true,
      "image":
          "https://images.pexels.com/photos/1640772/pexels-photo-1640772.jpeg?auto=compress&cs=tinysrgb&w=800",
      "popularity": 78,
    },
    {
      "id": 8,
      "name": "Pão Doce com Goiabada",
      "description":
          "Pão doce recheado com goiabada caseira. Tradicional sabor brasileiro em cada mordida.",
      "price": "R\$ 3,50",
      "priceValue": 3.50,
      "category": "Pães Pequenos",
      "available": false,
      "image":
          "https://images.pexels.com/photos/2067396/pexels-photo-2067396.jpeg?auto=compress&cs=tinysrgb&w=800",
      "popularity": 83,
    },
    {
      "id": 9,
      "name": "Bolo de Cenoura com Chocolate",
      "description":
          "Clássico bolo de cenoura brasileiro com cobertura de chocolate. Receita da vovó.",
      "price": "R\$ 38,00",
      "priceValue": 38.00,
      "category": "Bolos",
      "available": true,
      "image":
          "https://images.pexels.com/photos/1721932/pexels-photo-1721932.jpeg?auto=compress&cs=tinysrgb&w=800",
      "popularity": 94,
    },
    {
      "id": 10,
      "name": "Quiche Lorraine",
      "description":
          "Quiche francesa com bacon, queijo gruyère e creme de leite. Sofisticação em cada fatia.",
      "price": "R\$ 35,00",
      "priceValue": 35.00,
      "category": "Tortas Salgadas",
      "available": true,
      "image":
          "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=800",
      "popularity": 81,
    },
  ];

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

  void _loadInitialData() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      _applyFilters();
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  void _loadMoreProducts() {
    if (_isLoadingMore || _displayedProducts.length >= _filteredProducts.length)
      return;

    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      final nextItems = _filteredProducts
          .skip(_displayedProducts.length)
          .take(_itemsPerPage)
          .toList();

      setState(() {
        _displayedProducts.addAll(nextItems);
        _isLoadingMore = false;
      });
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = _allProducts.where((product) {
      // Category filter
      if (product['category'] != _selectedCategory) return false;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final name = (product['name'] as String).toLowerCase();
        final description = (product['description'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !description.contains(query)) return false;
      }

      // Price filter
      final price = product['priceValue'] as double;
      if (price < _priceRange.start || price > _priceRange.end) return false;

      // Availability filter
      if (_showAvailableOnly && !(product['available'] as bool)) return false;

      return true;
    }).toList();

    // Apply sorting
    switch (_currentSort) {
      case 'price_low':
        filtered.sort((a, b) =>
            (a['priceValue'] as double).compareTo(b['priceValue'] as double));
        break;
      case 'price_high':
        filtered.sort((a, b) =>
            (b['priceValue'] as double).compareTo(a['priceValue'] as double));
        break;
      case 'popular':
        filtered.sort((a, b) =>
            (b['popularity'] as int).compareTo(a['popularity'] as int));
        break;
      case 'relevance':
      default:
        // Keep original order for relevance
        break;
    }

    setState(() {
      _filteredProducts = filtered;
      _displayedProducts = filtered.take(_itemsPerPage).toList();
      _currentPage = 1;
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
        count: _filteredProducts.where((p) => p['available'] as bool).length,
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
          _selectedCategory,
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
                                Navigator.pushNamed(context, '/product-detail');
                              },
                              onAddToCart: () {
                                HapticFeedback.mediumImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${product['name']} adicionado ao carrinho'),
                                    backgroundColor:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
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
}
