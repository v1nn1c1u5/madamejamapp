import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import './services/supabase_service.dart';

void main() async {
  // Platform detection for better debugging
  debugPrint('=== MADAME JAM APP STARTING ===');
  debugPrint('Platform: ${kIsWeb ? 'WEB' : 'MOBILE'}');
  debugPrint('Debug Mode: $kDebugMode');
  debugPrint('Release Mode: $kReleaseMode');
  debugPrint('Profile Mode: $kProfileMode');
  if (kIsWeb) {
    debugPrint('Running on Web Platform - Enhanced debugging enabled');
  }

  // Captura erros do Flutter framework
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('=== FLUTTER ERROR ===');
    debugPrint('Error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
    debugPrint('Context: ${details.context}');
    debugPrint('Platform: ${kIsWeb ? 'WEB' : 'MOBILE'}');
    debugPrint('====================');
  };

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    debugPrint('=== INITIALIZING SUPABASE ===');
    await SupabaseService.initialize();
    debugPrint('=== SUPABASE INITIALIZED SUCCESSFULLY ===');
  } catch (e, stackTrace) {
    debugPrint('=== SUPABASE INITIALIZATION FAILED ===');
    debugPrint('Error: $e');
    debugPrint('Stack: $stackTrace');
    debugPrint('========================================');
  }

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('=== CUSTOM ERROR WIDGET TRIGGERED ===');
    debugPrint('Error: ${details.exception}');
    debugPrint('=====================================');
    return CustomErrorWidget(
      errorDetails: details,
    );
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  try {
    debugPrint('=== SETTING ORIENTATION ===');
    Future.wait([
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    ]).then((value) {
      debugPrint('=== STARTING APP ===');
      runApp(MyApp());
    });
  } catch (e, stackTrace) {
    debugPrint('=== ORIENTATION SETTING FAILED ===');
    debugPrint('Error: $e');
    debugPrint('Stack: $stackTrace');
    debugPrint('====================================');
    // Tenta executar mesmo assim
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('=== BUILDING MyApp ===');

    try {
      return Sizer(builder: (context, orientation, screenType) {
        debugPrint('=== SIZER BUILDER CALLED ===');
        debugPrint('Orientation: $orientation, ScreenType: $screenType');

        try {
          return MaterialApp(
            title: 'Madame Jam',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
            builder: (context, child) {
              debugPrint('=== MATERIAL APP BUILDER CALLED ===');
              try {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(1.0),
                  ),
                  child: child!,
                );
              } catch (e, stackTrace) {
                debugPrint('=== ERROR IN BUILDER ===');
                debugPrint('Error: $e');
                debugPrint('Stack: $stackTrace');
                debugPrint('=======================');
                rethrow;
              }
            },
            // 🚨 END CRITICAL SECTION
            debugShowCheckedModeBanner: false,
            routes: AppRoutes.routes,
            initialRoute: AppRoutes.initial,
          );
        } catch (e, stackTrace) {
          debugPrint('=== ERROR CREATING MATERIAL APP ===');
          debugPrint('Error: $e');
          debugPrint('Stack: $stackTrace');
          debugPrint('====================================');
          rethrow;
        }
      });
    } catch (e, stackTrace) {
      debugPrint('=== ERROR IN SIZER ===');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('======================');
      rethrow;
    }
  }
}
