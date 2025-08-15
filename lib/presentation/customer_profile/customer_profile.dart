import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bottom_navigation_widget.dart';
import './widgets/profile_action_widget.dart';
import './widgets/profile_field_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_section_widget.dart';
import './widgets/profile_toggle_widget.dart';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({Key? key}) : super(key: key);

  @override
  State<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  final ImagePicker _imagePicker = ImagePicker();
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;
  XFile? _capturedImage;

  // Mock customer data
  final Map<String, dynamic> customerData = {
    "id": 1,
    "fullName": "Maria Silva Santos",
    "email": "maria.santos@email.com",
    "phone": "+55 11 99876-5432",
    "profileImage":
        "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
    "memberSince": "agosto 2024",
    "address": {
      "complex": "Residencial Jardim das Flores",
      "building": "Bloco A",
      "apartment": "Apto 205",
      "street": "Rua das Palmeiras, 123",
      "neighborhood": "Vila Madalena",
      "city": "São Paulo",
      "state": "SP",
      "zipCode": "05435-040",
      "deliveryNotes": "Portão azul, interfone 205"
    },
    "preferences": {
      "orderUpdates": true,
      "promotions": false,
      "newProducts": true,
      "language": "Português (Brasil)"
    },
    "paymentMethods": [
      {
        "id": 1,
        "type": "credit",
        "brand": "Visa",
        "lastFour": "4532",
        "expiryMonth": "12",
        "expiryYear": "2026",
        "isDefault": true
      },
      {
        "id": 2,
        "type": "debit",
        "brand": "Mastercard",
        "lastFour": "8901",
        "expiryMonth": "08",
        "expiryYear": "2025",
        "isDefault": false
      }
    ]
  };

  // Notification preferences state
  bool _orderUpdatesEnabled = true;
  bool _promotionsEnabled = false;
  bool _newProductsEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _initializePreferences() {
    final preferences = customerData["preferences"] as Map<String, dynamic>;
    setState(() {
      _orderUpdatesEnabled = preferences["orderUpdates"] as bool;
      _promotionsEnabled = preferences["promotions"] as bool;
      _newProductsEnabled = preferences["newProducts"] as bool;
    });
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _showImagePickerDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 1.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Alterar Foto do Perfil',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  'Câmera',
                  'camera_alt',
                  () => _pickImageFromCamera(),
                ),
                _buildImageOption(
                  'Galeria',
                  'photo_library',
                  () => _pickImageFromGallery(),
                ),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(String title, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: 35.w,
        padding: EdgeInsets.symmetric(vertical: 3.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: iconName,
              size: 8.w,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      if (await _requestCameraPermission()) {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          maxWidth: 800,
          maxHeight: 800,
        );

        if (image != null) {
          setState(() {
            _capturedImage = image;
          });
          _showSuccessMessage('Foto atualizada com sucesso!');
        }
      } else {
        _showErrorMessage('Permissão de câmera necessária');
      }
    } catch (e) {
      _showErrorMessage('Erro ao capturar foto');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
        _showSuccessMessage('Foto atualizada com sucesso!');
      }
    } catch (e) {
      _showErrorMessage('Erro ao selecionar foto');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        title: Text(
          'Sair da Conta',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Tem certeza que deseja sair da sua conta?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/customer-login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  String _formatAddress() {
    final address = customerData["address"] as Map<String, dynamic>;
    return "${address["complex"]}, ${address["building"]}, ${address["apartment"]}\n${address["street"]}\n${address["neighborhood"]}, ${address["city"]} - ${address["state"]}\nCEP: ${address["zipCode"]}";
  }

  String _formatPaymentMethods() {
    final methods = customerData["paymentMethods"] as List;
    if (methods.isEmpty) return "Nenhum método cadastrado";

    final defaultMethod = methods.firstWhere(
      (method) => (method as Map<String, dynamic>)["isDefault"] == true,
      orElse: () => methods.first,
    ) as Map<String, dynamic>;

    return "${defaultMethod["brand"]} •••• ${defaultMethod["lastFour"]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Header
                    ProfileHeaderWidget(
                      customerName: customerData["fullName"] as String,
                      profileImageUrl: _capturedImage?.path ??
                          customerData["profileImage"] as String?,
                      onEditPressed: _showImagePickerDialog,
                    ),

                    SizedBox(height: 2.h),

                    // Account Information Section
                    ProfileSectionWidget(
                      title: 'Informações da Conta',
                      children: [
                        ProfileFieldWidget(
                          label: 'Nome Completo',
                          value: customerData["fullName"] as String,
                          iconName: 'person',
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                        ),
                        ProfileFieldWidget(
                          label: 'E-mail',
                          value: customerData["email"] as String,
                          iconName: 'email',
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                        ),
                        ProfileFieldWidget(
                          label: 'Telefone',
                          value: customerData["phone"] as String,
                          iconName: 'phone',
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                        ),
                        ProfileFieldWidget(
                          label: 'Endereço de Entrega',
                          value: _formatAddress(),
                          iconName: 'location_on',
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                        ),
                      ],
                    ),

                    // Security Section
                    ProfileSectionWidget(
                      title: 'Segurança',
                      children: [
                        ProfileActionWidget(
                          title: 'Alterar Senha',
                          subtitle: 'Última alteração: há 3 meses',
                          iconName: 'lock',
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                        ),
                      ],
                    ),

                    // Notification Preferences Section
                    ProfileSectionWidget(
                      title: 'Notificações',
                      children: [
                        ProfileToggleWidget(
                          title: 'Atualizações de Pedidos',
                          subtitle:
                              'Receber notificações sobre status dos pedidos',
                          iconName: 'notifications',
                          value: _orderUpdatesEnabled,
                          onChanged: (value) {
                            setState(() {
                              _orderUpdatesEnabled = value;
                            });
                          },
                        ),
                        ProfileToggleWidget(
                          title: 'Promoções',
                          subtitle: 'Receber ofertas especiais e descontos',
                          iconName: 'local_offer',
                          value: _promotionsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _promotionsEnabled = value;
                            });
                          },
                        ),
                        ProfileToggleWidget(
                          title: 'Novos Produtos',
                          subtitle:
                              'Ser notificado sobre novidades do cardápio',
                          iconName: 'fiber_new',
                          value: _newProductsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _newProductsEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),

                    // Payment Methods Section
                    ProfileSectionWidget(
                      title: 'Métodos de Pagamento',
                      children: [
                        ProfileFieldWidget(
                          label: 'Cartão Principal',
                          value: _formatPaymentMethods(),
                          iconName: 'credit_card',
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                        ),
                      ],
                    ),

                    // Language Section
                    ProfileSectionWidget(
                      title: 'Idioma e Região',
                      children: [
                        ProfileFieldWidget(
                          label: 'Idioma',
                          value:
                              customerData["preferences"]["language"] as String,
                          iconName: 'language',
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                        ),
                      ],
                    ),

                    // Support Section
                    ProfileSectionWidget(
                      title: 'Suporte',
                      children: [
                        ProfileActionWidget(
                          title: 'Central de Ajuda',
                          subtitle: 'FAQ e perguntas frequentes',
                          iconName: 'help',
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                        ),
                        ProfileActionWidget(
                          title: 'Fale Conosco',
                          subtitle: 'WhatsApp: (11) 99999-9999',
                          iconName: 'chat',
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                        ),
                        ProfileActionWidget(
                          title: 'Sobre o App',
                          subtitle: 'Versão 1.0.0',
                          iconName: 'info',
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                          showArrow: false,
                        ),
                      ],
                    ),

                    // Privacy Section
                    ProfileSectionWidget(
                      title: 'Privacidade',
                      children: [
                        ProfileActionWidget(
                          title: 'Política de Privacidade',
                          subtitle: 'LGPD - Lei Geral de Proteção de Dados',
                          iconName: 'privacy_tip',
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                        ),
                        ProfileActionWidget(
                          title: 'Exportar Dados',
                          subtitle: 'Baixar uma cópia dos seus dados',
                          iconName: 'download',
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                        ),
                        ProfileActionWidget(
                          title: 'Excluir Conta',
                          subtitle: 'Remover permanentemente sua conta',
                          iconName: 'delete_forever',
                          iconColor: AppTheme.lightTheme.colorScheme.error,
                          textColor: AppTheme.lightTheme.colorScheme.error,
                          onTap: () => _showErrorMessage(
                              'Funcionalidade em desenvolvimento'),
                        ),
                      ],
                    ),

                    // Logout Section
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(4.w),
                      child: ElevatedButton(
                        onPressed: _showLogoutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.error,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 3.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'logout',
                              size: 5.w,
                              color: Colors.white,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Sair da Conta',
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            BottomNavigationWidget(
              currentIndex: 4,
              onTap: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushNamed(context, '/product-catalog-home');
                    break;
                  case 1:
                    Navigator.pushNamed(context, '/product-category-list');
                    break;
                  case 2:
                    Navigator.pushNamed(context, '/shopping-cart');
                    break;
                  case 3:
                    Navigator.pushNamed(context, '/order-history');
                    break;
                  case 4:
                    // Already on profile screen
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
