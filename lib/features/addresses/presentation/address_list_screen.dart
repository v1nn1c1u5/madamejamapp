import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../data/address_repository.dart';
import '../domain/address.dart';

/// Tela de gerenciamento dos endereços salvos do cliente.
class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(myAddressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus endereços')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Adicionar'),
        onPressed: () async {
          final result =
              await context.push<Address>(AppRoutes.addressForm);
          if (result != null) ref.invalidate(myAddressesProvider);
        },
      ),
      body: addresses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text(
                  'Nenhum endereço salvo.\nToque em + para adicionar.',
                  textAlign: TextAlign.center,
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(myAddressesProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _AddressTile(
                    address: list[i],
                    onTap: () async {
                      final result = await context.push<Address>(
                        AppRoutes.addressForm,
                        extra: list[i],
                      );
                      if (result != null) ref.invalidate(myAddressesProvider);
                    },
                    onSetDefault: () async {
                      await ref
                          .read(addressRepositoryProvider)
                          .setDefault(list[i].id);
                      ref.invalidate(myAddressesProvider);
                    },
                    onDelete: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (dctx) => AlertDialog(
                          title: const Text('Remover endereço'),
                          content: Text('Remover "${list[i].label}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dctx, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(dctx, true),
                              child: const Text('Remover'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ref
                            .read(addressRepositoryProvider)
                            .deleteAddress(list[i].id);
                        ref.invalidate(myAddressesProvider);
                      }
                    },
                  ),
                ),
              ),
      ),
    );
  }
}

IconData addressIcon(String label) {
  switch (label.toLowerCase()) {
    case 'casa':
      return Icons.home_outlined;
    case 'trabalho':
      return Icons.work_outline;
    default:
      return Icons.place_outlined;
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

  final Address address;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(addressIcon(address.label),
            color: AppColors.champagneDark),
        title: Row(
          children: [
            Flexible(
              child: Text(
                address.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (address.isDefault) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.champagne.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Padrão', style: TextStyle(fontSize: 11)),
              ),
            ],
          ],
        ),
        subtitle: Text(address.formatted),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'default') onSetDefault();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            if (!address.isDefault)
              const PopupMenuItem(
                  value: 'default', child: Text('Definir como padrão')),
            const PopupMenuItem(value: 'delete', child: Text('Excluir')),
          ],
        ),
      ),
    );
  }
}
