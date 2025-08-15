import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/customization_options.dart';
import './widgets/product_image_gallery.dart';
import './widgets/product_info_section.dart';
import './widgets/quantity_selector.dart';
import './widgets/reviews_section.dart';
import './widgets/sticky_bottom_bar.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({Key? key}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final ScrollController _scrollController = ScrollController();
  bool _isFavorite = false;
  int _quantity = 1;
  int _cartItemCount = 3;
  Map<String, dynamic> _customizations = {};
  bool _isLoading = true;

  // Mock product data
  final Map<String, dynamic> _productData = {
    "id": 1,
    "name": "Pão de Açúcar Artesanal",
    "description":
        """Um delicioso pão de açúcar artesanal, preparado com ingredientes selecionados e muito carinho. 
    
Massa macia e saborosa, perfeita para o café da manhã ou lanche da tarde. Feito diariamente em nosso forno a lenha, garantindo aquele sabor único e caseiro que você tanto ama.

Ideal para acompanhar com manteiga, geleia ou mel. Uma verdadeira experiência gastronômica que remete aos sabores da infância.""",
    "price": "R\$ 12,50",
    "category": "Pães Doces",
    "available": true,
    "preparation_time": "2-3 horas",
    "images": [
      "https://images.pexels.com/photos/1775043/pexels-photo-1775043.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "https://images.pexels.com/photos/209206/pexels-photo-209206.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "https://images.pexels.com/photos/1586947/pexels-photo-1586947.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    ],
    "ingredients": [
      "Farinha de trigo especial",
      "Açúcar cristal",
      "Ovos caipiras",
      "Manteiga sem sal",
      "Fermento biológico",
      "Leite integral",
      "Sal marinho",
      "Essência de baunilha"
    ],
    "nutritional_info": {
      "calories": "285 kcal por 100g",
      "carbs": "52g",
      "protein": "8g",
      "fat": "6g"
    }
  };

  final List<Map<String, dynamic>> _customizationOptions = [
    {
      "title": "Cobertura Especial",
      "type": "select",
      "required": false,
      "choices": [
        "Sem cobertura",
        "Açúcar cristal",
        "Canela e açúcar",
        "Chocolate granulado",
        "Coco ralado"
      ]
    },
    {
      "title": "Observações Especiais",
      "type": "text",
      "required": false,
      "placeholder": "Alguma observação especial para o preparo?"
    },
    {
      "title": "Embalagem",
      "type": "radio",
      "required": false,
      "choices": [
        "Embalagem padrão",
        "Embalagem para presente (+R\$ 2,00)",
        "Caixa personalizada (+R\$ 5,00)"
      ]
    }
  ];

  final List<Map<String, dynamic>> _reviews = [
    {
      "id": 1,
      "customer_name": "Maria Silva",
      "rating": 5.0,
      "comment":
          "Simplesmente perfeito! O pão chegou quentinho e com aquele sabor caseiro incrível. Minha família adorou, já virou nosso favorito para o café da manhã.",
      "date": DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      "id": 2,
      "customer_name": "João Santos",
      "rating": 4.0,
      "comment":
          "Muito bom! Massa macia e sabor autêntico. A entrega foi rápida e o produto chegou bem embalado. Recomendo!",
      "date": DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      "id": 3,
      "customer_name": "Ana Costa",
      "rating": 5.0,
      "comment":
          "Excelente qualidade! Dá para sentir que é feito com muito carinho. O sabor me lembrou da casa da minha avó. Voltarei a comprar com certeza.",
      "date": DateTime.now().subtract(const Duration(days: 8)),
    },
    {
      "id": 4,
      "customer_name": "Carlos Oliveira",
      "rating": 4.0,
      "comment":
          "Produto de ótima qualidade, sabor excepcional. Apenas achei o preço um pouco alto, mas vale a pena pela qualidade.",
      "date": DateTime.now().subtract(const Duration(days: 12)),
    },
    {
      "id": 5,
      "customer_name": "Lucia Ferreira",
      "rating": 5.0,
      "comment":
          "Maravilhoso! Textura perfeita, sabor incrível. Meus filhos pediram para comprar toda semana. Parabéns pela qualidade!",
      "date": DateTime.now().subtract(const Duration(days: 15)),
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProductData() async {
    // Simulate API loading
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: _isFavorite ? 'favorite' : 'favorite_border',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Text(
              _isFavorite
                  ? 'Adicionado aos favoritos!'
                  : 'Removido dos favoritos!',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: _isFavorite
            ? Colors.red
            : AppTheme.lightTheme.colorScheme.onSurface,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _shareProduct() {
    // Simulate sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'share',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            const Text(
              'Link do produto copiado!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _onQuantityChanged(int newQuantity) {
    setState(() {
      _quantity = newQuantity;
    });
  }

  void _onCustomizationChanged(Map<String, dynamic> customizations) {
    setState(() {
      _customizations = customizations;
    });
  }

  void _addToCart() {
    setState(() {
      _cartItemCount += _quantity;
    });
  }

  double _calculateAverageRating() {
    if (_reviews.isEmpty) return 0.0;

    double total = 0.0;
    for (var review in _reviews) {
      total += (review['rating'] as double? ?? 0.0);
    }
    return total / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Carregando produto...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<String> productImages =
        (_productData['images'] as List<dynamic>?)?.cast<String>() ?? [];
    final double averageRating = _calculateAverageRating();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 45.h,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.shadow,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: _shareProduct,
                    child: Container(
                      margin: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface
                            .withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lightTheme.colorScheme.shadow,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'share',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 6.w,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      margin: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface
                            .withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lightTheme.colorScheme.shadow,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName:
                              _isFavorite ? 'favorite' : 'favorite_border',
                          color: _isFavorite
                              ? Colors.red
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          size: 6.w,
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: productImages.isNotEmpty
                      ? ProductImageGallery(
                          images: productImages,
                          productName:
                              _productData['name'] as String? ?? 'Produto',
                        )
                      : Container(
                          color: AppTheme
                              .lightTheme.colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'image',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20.w,
                            ),
                          ),
                        ),
                ),
              ),

              // Product Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Product Info
                    ProductInfoSection(product: _productData),

                    Divider(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      thickness: 1,
                      indent: 4.w,
                      endIndent: 4.w,
                    ),

                    // Quantity Selector
                    QuantitySelector(
                      initialQuantity: _quantity,
                      maxQuantity: 10,
                      onQuantityChanged: _onQuantityChanged,
                      isEnabled: (_productData['available'] as bool? ?? true),
                    ),

                    Divider(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      thickness: 1,
                      indent: 4.w,
                      endIndent: 4.w,
                    ),

                    // Customization Options
                    CustomizationOptions(
                      options: _customizationOptions,
                      onCustomizationChanged: _onCustomizationChanged,
                    ),

                    Divider(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      thickness: 1,
                      indent: 4.w,
                      endIndent: 4.w,
                    ),

                    // Reviews Section
                    ReviewsSection(
                      reviews: _reviews,
                      averageRating: averageRating,
                      totalReviews: _reviews.length,
                    ),

                    // Bottom padding for sticky bar
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),

          // Sticky Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: StickyBottomBar(
              product: _productData,
              quantity: _quantity,
              customizations: _customizations,
              onAddToCart: _addToCart,
              cartItemCount: _cartItemCount,
            ),
          ),
        ],
      ),
    );
  }
}
