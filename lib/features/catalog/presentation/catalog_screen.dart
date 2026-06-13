import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';

/// Home do cliente — esqueleto da fundação (Story 1.1).
///
/// A vitrine real (listagem, busca, detalhe) é entregue no Epic 2.
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Madame Jam'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(supabaseClientProvider).auth.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Catálogo',
                style: textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'A vitrine de produtos chega no Epic 2.',
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
