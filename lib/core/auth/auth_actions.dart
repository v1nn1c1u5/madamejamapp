import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../router/app_router.dart';

/// Encerra a sessão; o redirect do GoRouter cuida da navegação.
Future<void> signOut(WidgetRef ref, {BuildContext? context}) async {
  await ref.read(authRepositoryProvider).signOut();
  if (context != null && context.mounted) {
    context.go(AppRoutes.catalog);
  }
}
