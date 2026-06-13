/// Configuração de ambiente do app.
///
/// Os valores são injetados em tempo de build via `--dart-define` (ou um
/// arquivo `--dart-define-from-file`), nunca commitados no repositório.
///
/// Exemplo:
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJhbGci...
/// ```
///
/// A `anon key` é pública por design (protegida por RLS no banco). A
/// `service_role` do Supabase e a `secret key` do Stripe NUNCA entram no app —
/// vivem apenas nas Supabase Edge Functions.
abstract final class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Chave publicável do Stripe (também pública por design). Usada pelo
  /// flutter_stripe no cliente; a secret key fica nas Edge Functions.
  static const String stripePublishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasStripeConfig => stripePublishableKey.isNotEmpty;
}
