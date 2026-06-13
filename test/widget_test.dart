// Smoke test da fundação (Story 1.1).
//
// Sem configuração de Supabase injetada via --dart-define, o app exibe a tela
// de configuração pendente. Este teste garante que o app sobe sem quebrar.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:madamejam/main.dart';

void main() {
  testWidgets('App inicializa sem configuração e exibe tela de pendência',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MadameJamApp()));
    await tester.pump();

    // Sem config de Supabase no ambiente de teste, cai na tela de pendência.
    expect(find.text('Configuração pendente'), findsOneWidget);
  });
}
