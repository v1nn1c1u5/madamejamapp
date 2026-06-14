import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../data/delivery_repository.dart';

class DeliveryConfigScreen extends ConsumerWidget {
  const DeliveryConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configuração de Entrega'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Zonas de entrega'),
              Tab(text: 'Datas bloqueadas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ZonesTab(),
            _BlockedDatesTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Zonas de entrega ─────────────────────────────────────────────────────────

class _ZonesTab extends ConsumerWidget {
  const _ZonesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(deliveryZonesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Adicionar zona'),
        onPressed: () => _showAddZoneDialog(context, ref),
      ),
      body: zones.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text('Nenhuma zona cadastrada.\nToque em + para adicionar.',
                    textAlign: TextAlign.center))
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(deliveryZonesProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) => _ZoneTile(
                    zone: list[i],
                    onDelete: () async {
                      await ref
                          .read(deliveryRepositoryProvider)
                          .deleteZone(list[i].id);
                      ref.invalidate(deliveryZonesProvider);
                    },
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _showAddZoneDialog(
      BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final stateCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final neighborhoodCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova zona de entrega'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: stateCtrl,
                decoration: const InputDecoration(labelText: 'Estado (sigla) *'),
                textCapitalization: TextCapitalization.characters,
                maxLength: 2,
                validator: (v) {
                  if ((v?.trim().length ?? 0) != 2) {
                    return 'Informe a sigla (ex: SP)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: 'Cidade *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    Validators.required(v, field: 'Cidade'),
              ),
              TextFormField(
                controller: neighborhoodCtrl,
                decoration:
                    const InputDecoration(labelText: 'Bairro *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    Validators.required(v, field: 'Bairro'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await ref.read(deliveryRepositoryProvider).addZone(
                      state: stateCtrl.text.trim().toUpperCase(),
                      city: cityCtrl.text.trim(),
                      neighborhood: neighborhoodCtrl.text.trim(),
                    );
                ref.invalidate(deliveryZonesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    stateCtrl.dispose();
    cityCtrl.dispose();
    neighborhoodCtrl.dispose();
  }
}

class _ZoneTile extends StatelessWidget {
  const _ZoneTile({required this.zone, required this.onDelete});
  final DeliveryZone zone;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${zone.neighborhood}, ${zone.city}/${zone.state}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Remover zona'),
                content: Text(
                  'Remover "${zone.neighborhood}, '
                  '${zone.city}/${zone.state}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Remover'),
                  ),
                ],
              ),
            );
            if (ok == true) onDelete();
          },
        ),
      ),
    );
  }
}

// ─── Datas bloqueadas ─────────────────────────────────────────────────────────

class _BlockedDatesTab extends ConsumerWidget {
  const _BlockedDatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dates = ref.watch(blockedDatesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.event_busy_outlined),
        label: const Text('Bloquear data'),
        onPressed: () => _pickAndBlock(context, ref),
      ),
      body: dates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text('Nenhuma data bloqueada.',
                    textAlign: TextAlign.center))
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(blockedDatesProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) => _BlockedDateTile(
                    blocked: list[i],
                    onDelete: () async {
                      await ref
                          .read(deliveryRepositoryProvider)
                          .removeBlockedDate(list[i].id);
                      ref.invalidate(blockedDatesProvider);
                    },
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _pickAndBlock(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !context.mounted) return;

    final reasonCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Bloquear ${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}',
        ),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
              labelText: 'Motivo (opcional)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref
                    .read(deliveryRepositoryProvider)
                    .addBlockedDate(
                      picked,
                      reason: reasonCtrl.text.trim().isEmpty
                          ? null
                          : reasonCtrl.text.trim(),
                    );
                ref.invalidate(blockedDatesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
              }
            },
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
    reasonCtrl.dispose();
  }
}

class _BlockedDateTile extends StatelessWidget {
  const _BlockedDateTile(
      {required this.blocked, required this.onDelete});
  final BlockedDate blocked;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final d = blocked.date;
    return Card(
      child: ListTile(
        title: Text(
          '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}',
        ),
        subtitle: blocked.reason != null
            ? Text(blocked.reason!)
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
