import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_actions.dart';
import '../../../core/router/app_router.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Madame Jam · Admin'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(ref, context: context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavCard(
            icon: Icons.inventory_2_outlined,
            title: 'Produtos',
            subtitle: 'Cadastrar, editar e ativar produtos',
            onTap: () => context.push(AppRoutes.adminProducts),
          ),
          _NavCard(
            icon: Icons.calendar_view_week_outlined,
            title: 'Pedidos da semana',
            subtitle: 'Planejamento de insumos',
            onTap: () => context.push(AppRoutes.adminWeeklyOrders),
          ),
          _NavCard(
            icon: Icons.today_outlined,
            title: 'Pedidos do dia',
            subtitle: 'Organizar a produção',
            onTap: () => context.push(AppRoutes.adminDailyOrders),
          ),
          _NavCard(
            icon: Icons.local_shipping_outlined,
            title: 'Configuração de entrega',
            subtitle: 'Zonas e datas bloqueadas',
            onTap: () => context.push(AppRoutes.adminDeliveryConfig),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 8),
        leading: Icon(icon,
            size: 32,
            color: onTap != null
                ? Theme.of(context).colorScheme.primary
                : Colors.grey),
        title: Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: onTap == null ? Colors.grey : null)),
        subtitle: Text(subtitle),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right)
            : null,
        onTap: onTap,
      ),
    );
  }
}
