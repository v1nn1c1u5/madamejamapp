import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/category_card_widget.dart';
import './widgets/featured_product_card_widget.dart';
import './widgets/hero_carousel_widget.dart';

class ProductCatalogHome extends StatefulWidget {
  const ProductCatalogHome({super.key});

  @override
  State<ProductCatalogHome> createState() => _ProductCatalogHomeState();
}

class _ProductCatalogHomeState extends State<ProductCatalogHome> {
  int _currentTabIndex = 0;
  int _cartItemCount = 3;
  bool _isRefreshing = false;

  // Mock data for featured products in hero carousel
  final List<Map<String, dynamic>> _heroFeaturedProducts = [
    {
      "id": 1,
      "name": "Bolo de Chocolate Artesanal",
      "price": "R\$ 45,00",
      "image":
          "https://images.unsplash.com/photo-1578985545062-69928b1d9587?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
    {
      "id": 2,
      "name": "Pão de Açúcar Especial",
      "price": "R\$ 12,50",
      "image":
          "https://images.pexels.com/photos/1775043/pexels-photo-1775043.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": 3,
      "name": "Torta Salgada de Frango",
      "price": "R\$ 38,00",
      "image":
          "https://cdn.pixabay.com/photo/2017/06/29/20/09/mexican-2456038_1280.jpg",
    },
  ];

  // Mock data for categories
  final List<Map<String, dynamic>> _categories = [
    {
      "id": 1,
      "title": "Pães Pequenos",
      "itemCount": 24,
      "image":
          "https://images.unsplash.com/photo-1509440159596-0249088772ff?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "route": "/product-category-list",
    },
    {
      "id": 2,
      "title": "Bolos",
      "itemCount": 18,
      "image":
          "https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "route": "/product-category-list",
    },
    {
      "id": 3,
      "title": "Tortas Salgadas",
      "itemCount": 12,
      "image":
          "https://cdn.pixabay.com/photo/2020/10/05/19/55/pie-5630646_1280.jpg",
      "route": "/product-category-list",
    },
  ];

  // Mock data for featured products section
  final List<Map<String, dynamic>> _featuredProducts = [
    {
      "id": 4,
      "name": "Pão Francês Tradicional",
      "price": "R\$ 8,50",
      "image":
          "https://images.unsplash.com/photo-1549931319-a545dcf3bc73?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
    {
      "id": 5,
      "name": "Bolo de Cenoura",
      "price": "R\$ 32,00",
      "image":
          "https://images.pexels.com/photos/1721932/pexels-photo-1721932.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
    {
      "id": 6,
      "name": "Empada de Camarão",
      "price": "R\$ 15,00",
      "image":
          "https://cdn.pixabay.com/photo/2019/09/26/18/23/pie-4506750_1280.jpg",
    },
    {
      "id": 7,
      "name": "Croissant Doce",
      "price": "R\$ 9,50",
      "image":
          "https://images.unsplash.com/photo-1555507036-ab794f4afe5e?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
  ];

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _onCategoryTap(Map<String, dynamic> category) {
    Navigator.pushNamed(context, '/product-category-list');
  }

  void _onProductTap(Map<String, dynamic> product) {
    Navigator.pushNamed(context, '/product-detail');
  }

  void _onAddToCart(Map<String, dynamic> product) {
    setState(() {
      _cartItemCount++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${(product['name'] as String?) ?? 'Produto'} adicionado ao carrinho'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _onSearchTap() {
    // Navigate to search screen or show search dialog
    showSearch(
      context: context,
      delegate: _ProductSearchDelegate(),
    );
  }

  void _onCartTap() {
    Navigator.pushNamed(context, '/shopping-cart');
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home - do nothing
        break;
      case 1:
        Navigator.pushNamed(context, '/order-history');
        break;
      case 2:
        Navigator.pushNamed(context, '/customer-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.colorScheme.primary,
          child: CustomScrollView(
            slivers: [
              // Sticky Header
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 2,
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                toolbarHeight: 8.h,
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Row(
                    children: [
                      // Bakery Logo
                      Container(
                        width: 12.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'MJ',
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Madame Jam',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Padaria Artesanal',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Search Icon
                      GestureDetector(
                        onTap: _onSearchTap,
                        child: Container(
                          width: 12.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'search',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      // Cart Icon with Badge
                      GestureDetector(
                        onTap: _onCartTap,
                        child: Container(
                          width: 12.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: CustomIconWidget(
                                  iconName: 'shopping_cart',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 24,
                                ),
                              ),
                              if (_cartItemCount > 0)
                                Positioned(
                                  top: 1.h,
                                  right: 2.w,
                                  child: Container(
                                    padding: EdgeInsets.all(0.5.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 4.w,
                                      minHeight: 2.h,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _cartItemCount.toString(),
                                        style: AppTheme
                                            .lightTheme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.onPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hero Carousel Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: HeroCarouselWidget(
                    featuredProducts: _heroFeaturedProducts,
                    onProductTap: _onProductTap,
                  ),
                ),
              ),

              // Categories Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categorias',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 3.w,
                          mainAxisSpacing: 2.h,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return CategoryCardWidget(
                            title: (category['title'] as String?) ?? '',
                            imageUrl: (category['image'] as String?) ?? '',
                            itemCount: (category['itemCount'] as int?) ?? 0,
                            onTap: () => _onCategoryTap(category),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Featured Products Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produtos em Destaque',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        height: 32.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _featuredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _featuredProducts[index];
                            return FeaturedProductCardWidget(
                              name: (product['name'] as String?) ?? '',
                              imageUrl: (product['image'] as String?) ?? '',
                              price: (product['price'] as String?) ?? '',
                              onTap: () => _onProductTap(product),
                              onAddToCart: () => _onAddToCart(product),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom spacing for tab bar
              SliverToBoxAdapter(
                child: SizedBox(height: 10.h),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: _onTabChanged,
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
          unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'home',
                color: _currentTabIndex == 0
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'receipt_long',
                color: _currentTabIndex == 1
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'person',
                color: _currentTabIndex == 2
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSearchDelegate extends SearchDelegate<String> {
  final List<String> _searchHistory = [
    'Pão francês',
    'Bolo de chocolate',
    'Torta salgada',
  ];

  @override
  String get searchFieldLabel => 'Buscar produtos...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: CustomIconWidget(
          iconName: 'clear',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 24,
        ),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: CustomIconWidget(
        iconName: 'arrow_back',
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 24,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        'Resultados para: "$query"',
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? _searchHistory
        : _searchHistory
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: CustomIconWidget(
            iconName: query.isEmpty ? 'history' : 'search',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          title: Text(
            suggestion,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }
}
