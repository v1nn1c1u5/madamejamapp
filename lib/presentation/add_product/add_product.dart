import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import '../../services/bakery_service.dart';
import './widgets/advanced_options_widget.dart';
import './widgets/inventory_section_widget.dart';
import './widgets/product_form_widget.dart';
import './widgets/product_image_upload_widget.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _bakeryService = BakeryService.instance;
  final _authService = AuthService.instance;

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _preparationTimeController = TextEditingController();

  // Form state
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  int _stockQuantity = 0;
  int _minStockLevel = 5;
  bool _isAvailable = true;
  int _preparationTime = 30;
  final List<String> _allergens = [];
  bool _isGlutenFree = false;
  bool _isVegan = false;
  int? _weightGrams;
  final List<XFile> _productImages = [];
  bool _isLoading = false;
  bool _isSaving = false;

  final List<String> _availableAllergens = [
    'Glúten',
    'Leite',
    'Ovos',
    'Soja',
    'Amendoim',
    'Castanhas',
    'Peixes',
    'Crustáceos',
    'Gergelim',
    'Sulfitos',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _preparationTimeController.text = _preparationTime.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _preparationTimeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _bakeryService.getProductCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erro ao carregar categorias: $error');
    }
  }

  Future<void> _handleImagePicker() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _productImages.addAll(images);
        });
      }
    } catch (error) {
      _showErrorSnackBar('Erro ao selecionar imagens: $error');
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      _productImages.removeAt(index);
    });
  }

  void _handleAllergenToggle(String allergen) {
    setState(() {
      if (_allergens.contains(allergen)) {
        _allergens.remove(allergen);
      } else {
        _allergens.add(allergen);
      }
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      _showErrorSnackBar('Por favor, selecione uma categoria');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      // Parse price and cost price
      final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
      final costPrice =
          double.tryParse(_costPriceController.text.replaceAll(',', '.'));

      if (price == null || price <= 0) {
        throw Exception('Preço deve ser um valor válido maior que zero');
      }

      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category_id': _selectedCategoryId,
        'price': price,
        'cost_price': costPrice,
        'stock_quantity': _stockQuantity,
        'min_stock_level': _minStockLevel,
        'status': _isAvailable ? 'active' : 'inactive',
        'preparation_time_minutes': _preparationTime,
        'allergens': _allergens,
        'is_gluten_free': _isGlutenFree,
        'is_vegan': _isVegan,
        'weight_grams': _weightGrams,
        'created_by': currentUser.id,
      };

      // Create product
      final product = await _bakeryService.createProduct(productData);
      final productId = product['id'];

      // Upload images if any
      for (int i = 0; i < _productImages.length; i++) {
        try {
          final image = _productImages[i];
          final bytes = await image.readAsBytes();
          final fileName =
              '${productId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

          final imageUrl =
              await _bakeryService.uploadProductImage(fileName, bytes);
          await _bakeryService.addProductImage(
            productId,
            imageUrl,
            altText: _nameController.text.trim(),
            isPrimary: i == 0, // First image is primary
          );
        } catch (imageError) {
          debugPrint('Erro ao fazer upload da imagem ${i + 1}: $imageError');
        }
      }

      setState(() => _isSaving = false);

      // Show success dialog
      await _showSuccessDialog(product);
    } catch (error) {
      setState(() => _isSaving = false);
      _showErrorSnackBar('Erro ao salvar produto: $error');
    }
  }

  Future<void> _showSuccessDialog(Map<String, dynamic> product) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 3.h),
            SizedBox(width: 2.w),
            Text(
              'Produto Criado!',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O produto "${product['name']}" foi criado com sucesso.',
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome: ${product['name']}',
                      style: GoogleFonts.inter(fontSize: 12.sp)),
                  Text('Preço: R\$ ${product['price'].toStringAsFixed(2)}',
                      style: GoogleFonts.inter(fontSize: 12.sp)),
                  Text('Estoque: ${product['stock_quantity']} unidades',
                      style: GoogleFonts.inter(fontSize: 12.sp)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
            },
            child: Text(
              'Criar Outro',
              style: GoogleFonts.inter(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Voltar ao Dashboard',
              style: GoogleFonts.inter(),
            ),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _costPriceController.clear();
    _preparationTimeController.text = '30';

    setState(() {
      _selectedCategoryId = null;
      _stockQuantity = 0;
      _minStockLevel = 5;
      _isAvailable = true;
      _preparationTime = 30;
      _allergens.clear();
      _isGlutenFree = false;
      _isVegan = false;
      _weightGrams = null;
      _productImages.clear();
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Adicionar Produto',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(4.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Upload Section
                    ProductImageUploadWidget(
                      images: _productImages,
                      onAddImage: _handleImagePicker,
                      onRemoveImage: _removeImage,
                    ),

                    SizedBox(height: 4.h),

                    // Basic Product Information
                    ProductFormWidget(
                      nameController: _nameController,
                      descriptionController: _descriptionController,
                      priceController: _priceController,
                      costPriceController: _costPriceController,
                      categories: _categories,
                      selectedCategoryId: _selectedCategoryId,
                      onCategoryChanged: (value) =>
                          setState(() => _selectedCategoryId = value),
                    ),

                    SizedBox(height: 4.h),

                    // Inventory Management
                    InventorySectionWidget(
                      stockQuantity: _stockQuantity,
                      minStockLevel: _minStockLevel,
                      isAvailable: _isAvailable,
                      onStockQuantityChanged: (value) =>
                          setState(() => _stockQuantity = value),
                      onMinStockChanged: (value) =>
                          setState(() => _minStockLevel = value),
                      onAvailabilityChanged: (value) =>
                          setState(() => _isAvailable = value ?? true),
                    ),

                    SizedBox(height: 4.h),

                    // Advanced Options
                    AdvancedOptionsWidget(
                      preparationTimeController: _preparationTimeController,
                      allergens: _allergens,
                      availableAllergens: _availableAllergens,
                      isGlutenFree: _isGlutenFree,
                      isVegan: _isVegan,
                      weightGrams: _weightGrams,
                      onPreparationTimeChanged: (value) =>
                          setState(() => _preparationTime = value ?? 30),
                      onAllergenToggle: _handleAllergenToggle,
                      onGlutenFreeChanged: (value) =>
                          setState(() => _isGlutenFree = value ?? false),
                      onVeganChanged: (value) =>
                          setState(() => _isVegan = value ?? false),
                      onWeightChanged: (value) =>
                          setState(() => _weightGrams = value),
                    ),

                    SizedBox(height: 6.h),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8B4513),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? SizedBox(
                                height: 2.h,
                                width: 2.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Salvar Produto',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
    );
  }
}
