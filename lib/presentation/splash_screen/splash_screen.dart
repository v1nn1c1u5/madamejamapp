import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _loadingAnimation;

  bool _isInitializing = true;
  String _loadingText = 'Carregando...';
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Loading animation controller
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

    // Loading progress animation
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start logo animation
    _logoAnimationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Start loading animation
      _loadingAnimationController.forward();

      // Simulate checking authentication status
      await _updateLoadingProgress(0.2, 'Verificando autenticação...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate loading user preferences
      await _updateLoadingProgress(0.4, 'Carregando preferências...');
      await Future.delayed(const Duration(milliseconds: 400));

      // Simulate fetching product catalog
      await _updateLoadingProgress(0.6, 'Buscando catálogo de produtos...');
      await Future.delayed(const Duration(milliseconds: 600));

      // Simulate preparing cached data
      await _updateLoadingProgress(0.8, 'Preparando dados...');
      await Future.delayed(const Duration(milliseconds: 400));

      // Complete loading
      await _updateLoadingProgress(1.0, 'Concluído!');
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate based on user status
      _navigateToNextScreen();
    } catch (e) {
      // Handle initialization error
      _handleInitializationError();
    }
  }

  Future<void> _updateLoadingProgress(double progress, String text) async {
    if (mounted) {
      setState(() {
        _loadingProgress = progress;
        _loadingText = text;
      });
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    // Mock authentication check - in real app this would check actual auth status
    final bool isAuthenticated = false; // Mock value
    final bool isAdmin = false; // Mock value

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Navigate based on user status
    if (isAuthenticated) {
      if (isAdmin) {
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/product-catalog-home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/customer-login');
    }
  }

  void _handleInitializationError() {
    if (!mounted) return;

    setState(() {
      _isInitializing = false;
      _loadingText = 'Erro ao carregar. Toque para tentar novamente.';
    });
  }

  void _retryInitialization() {
    setState(() {
      _isInitializing = true;
      _loadingProgress = 0.0;
      _loadingText = 'Carregando...';
    });

    // Reset and restart animations
    _loadingAnimationController.reset();
    _initializeApp();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.colorScheme.secondary,
              AppTheme.lightTheme.scaffoldBackgroundColor,
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: FadeTransition(
                          opacity: _logoFadeAnimation,
                          child: _buildLogo(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading section
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isInitializing) ...[
                        _buildLoadingIndicator(),
                        SizedBox(height: 3.h),
                        _buildLoadingText(),
                      ] else ...[
                        _buildRetryButton(),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom spacing
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'cake',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 12.w,
          ),
          SizedBox(height: 1.h),
          Text(
            'Madame',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          Text(
            'Jam',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.tertiary,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        // Custom progress indicator
        Container(
          width: 60.w,
          height: 0.8.h,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(0.4.h),
          ),
          child: AnimatedBuilder(
            animation: _loadingAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _loadingProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.lightTheme.colorScheme.primary,
                        AppTheme.lightTheme.colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(0.4.h),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 1.h),
        // Progress percentage
        Text(
          '${(_loadingProgress * 100).toInt()}%',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _loadingText,
        key: ValueKey(_loadingText),
        textAlign: TextAlign.center,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return Column(
      children: [
        CustomIconWidget(
          iconName: 'error_outline',
          color: AppTheme.lightTheme.colorScheme.error,
          size: 8.w,
        ),
        SizedBox(height: 2.h),
        Text(
          _loadingText,
          textAlign: TextAlign.center,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 3.h),
        ElevatedButton(
          onPressed: _retryInitialization,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Tentar Novamente',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
