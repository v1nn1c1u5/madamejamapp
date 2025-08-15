import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './services/supabase_service.dart';
import 'core/app_export.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with better error handling
  try {
    await SupabaseService.initialize();
    if (kDebugMode) {
      print('✅ Supabase initialized successfully');

      // Test database connection
      final connectionOk = await SupabaseService.instance.testConnection();
      if (connectionOk) {
        print('✅ Database connection verified');
      } else {
        print(
            '⚠️  Database connection test failed - app will continue with limited functionality');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Supabase initialization failed: $e');
      print('🔧 Troubleshooting:');
      print('   1. Check if you are running with --dart-define arguments');
      print('   2. Verify SUPABASE_URL and SUPABASE_ANON_KEY are correct');
      print('   3. Check internet connection');
      print('   4. Verify Supabase project is active');
    }

    // Show error dialog in debug mode, continue app in release mode
    if (kDebugMode) {
      runApp(ErrorApp(error: e.toString()));
      return;
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
          title: 'Madame Jam',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          builder: (context, child) {
            return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!);
          });
    });
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Configuration Error',
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 20),
                Text(
                  'Supabase Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Please run the app with proper environment variables:',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Error details: $error',
                  style: TextStyle(fontSize: 12, color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
