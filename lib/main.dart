import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  runApp(const ProviderScope(child: MadameJamApp()));
}

class MadameJamApp extends ConsumerWidget {
  const MadameJamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sem configuração do Supabase, exibe uma tela orientando o setup do
    // ambiente em vez de quebrar na inicialização.
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
                'Defina SUPABASE_URL e SUPABASE_ANON_KEY via --dart-define '
                'para iniciar o app. Veja o README.',
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
