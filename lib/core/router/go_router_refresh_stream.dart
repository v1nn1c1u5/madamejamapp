import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapta um [Stream] em um [Listenable] para o `refreshListenable` do
/// go_router — faz o roteador reavaliar os redirects quando o estado de
/// autenticação muda.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
