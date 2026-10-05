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
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
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
    await showDialog<void>(
      context: context,
      builder: (_) => const _AddZoneDialog(),
    );
  }
}

/// Diálogo com estado próprio: os controllers são descartados no `dispose`
/// do widget, depois da animação de fechamento. Descartá-los logo após o
/// `showDialog` retornar causava "'_dependents.isEmpty': is not true".
class _AddZoneDialog extends ConsumerStatefulWidget {
  const _AddZoneDialog();

  @override
  ConsumerState<_AddZoneDialog> createState() => _AddZoneDialogState();
}

class _AddZoneDialogState extends ConsumerState<_AddZoneDialog> {
  final _formKey = GlobalKey<FormState>();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();

  @override
  void dispose() {
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _neighborhoodCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(deliveryRepositoryProvider).addZone(
            state: _stateCtrl.text.trim().toUpperCase(),
            city: _cityCtrl.text.trim(),
            neighborhood: _neighborhoodCtrl.text.trim(),
          );
      ref.invalidate(deliveryZonesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova zona de entrega'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _stateCtrl,
              decoration:
                  const InputDecoration(labelText: 'Estado (sigla) *'),
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
              controller: _cityCtrl,
              decoration: const InputDecoration(labelText: 'Cidade *'),
              textCapitalization: TextCapitalization.words,
              validator: (v) => Validators.required(v, field: 'Cidade'),
            ),
            TextFormField(
              controller: _neighborhoodCtrl,
              decoration: const InputDecoration(labelText: 'Bairro *'),
              textCapitalization: TextCapitalization.words,
              validator: (v) => Validators.required(v, field: 'Bairro'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Adicionar'),
        ),
      ],
    );
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
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
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

    await showDialog<void>(
      context: context,
      builder: (_) => _BlockDateDialog(date: picked),
    );
  }
}

/// Diálogo com estado próprio para o controller não ser descartado antes
/// do fim da animação de fechamento (ver [_AddZoneDialog]).
class _BlockDateDialog extends ConsumerStatefulWidget {
  const _BlockDateDialog({required this.date});
  final DateTime date;

  @override
  ConsumerState<_BlockDateDialog> createState() => _BlockDateDialogState();
}

class _BlockDateDialogState extends ConsumerState<_BlockDateDialog> {
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reasonCtrl.text.trim();
    try {
      await ref.read(deliveryRepositoryProvider).addBlockedDate(
            widget.date,
            reason: reason.isEmpty ? null : reason,
          );
      ref.invalidate(blockedDatesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.date;
    return AlertDialog(
      title: Text(
        'Bloquear ${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}',
      ),
      content: TextField(
        controller: _reasonCtrl,
        decoration: const InputDecoration(labelText: 'Motivo (opcional)'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Bloquear'),
        ),
      ],
    );
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
