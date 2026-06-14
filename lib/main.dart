import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.hasSupabaseConfig) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  if (AppConfig.hasStripeConfig) {
    Stripe.publishableKey = AppConfig.stripePublishableKey;
    Stripe.merchantIdentifier = 'merchant.com.madamejam';
    await Stripe.instance.applySettings();
  }

  runApp(const ProviderScope(child: MadameJamApp()));
}

class MadameJamApp extends ConsumerWidget {
  const MadameJamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AppConfig.hasSupabaseConfig) {
      return MaterialApp(
        title: 'Madame Jam',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const _MissingConfigScreen(),
      );
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Madame Jam',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

class _MissingConfigScreen extends StatelessWidget {
  const _MissingConfigScreen();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Configuração pendente', style: textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                'Defina SUPABASE_URL, SUPABASE_ANON_KEY e '
                'STRIPE_PUBLISHABLE_KEY via --dart-define para iniciar o app.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
