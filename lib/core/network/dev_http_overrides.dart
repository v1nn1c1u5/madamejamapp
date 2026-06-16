import 'dart:io';

import 'package:flutter/foundation.dart';

/// Ignora erros de certificado SSL apenas em debug (ex.: proxy corporativo).
/// Nunca use em release — o app rejeitará certificados inválidos normalmente.
void setupDevHttpOverridesIfNeeded() {
  if (!kDebugMode) return;

  HttpOverrides.global = _DevHttpOverrides();
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (_, _, _) => true;
  }
}
