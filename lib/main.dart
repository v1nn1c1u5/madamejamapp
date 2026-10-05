import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/network/http_overrides.dart';
import 'core/router/app_router.dart';
import 'core/scaffold/root_scaffold_messenger.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Proxy/antivírus corporativo pode injetar certificado autoassinado.
  setupDevHttpOverridesIfNeeded();

  if (AppConfig.hasSupabaseConfig) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );

    // A sessão persistida é restaurada mesmo vencida e só renovada depois,
    // em segundo plano. Sem aguardar, as primeiras consultas ao reabrir o
    // app falham com "JWT expired" (PGRST303).
    final auth = Supabase.instance.client.auth;
    if (auth.currentSession?.isExpired ?? false) {
      try {
        await auth.refreshSession();
      } catch (_) {
        // Sem rede ou refresh token inválido: o GoTrue trata a sessão e o
        // fluxo de login normal assume a partir daqui.
      }
    }
  }

  // flutter_stripe só tem implementação nativa em iOS e Android.
  if (AppConfig.hasStripeConfig &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android)) {
    Stripe.publishableKey = AppConfig.stripePublishableKey;
    Stripe.merchantIdentifier = 'merchant.br.com.madamejam.app';
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
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
        locale: const Locale('pt', 'BR'),
        home: const _MissingConfigScreen(),
      );
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Madame Jam',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
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
