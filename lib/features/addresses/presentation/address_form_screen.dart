import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../../admin/data/delivery_repository.dart';
import '../data/address_repository.dart';
import '../domain/address.dart';

/// Formulário de criação/edição de um endereço salvo.
///
/// Retorna o [Address] salvo via `Navigator.pop` para quem a chamou
/// (checkout ou tela de gerenciamento de endereços).
class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key, this.existing});

  final Address? existing;

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _numberCtrl;
  late final TextEditingController _complementCtrl;
  late final TextEditingController _neighborhoodCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late bool _isDefault;
  bool _saving = false;
  String? _coverageError;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _labelCtrl = TextEditingController(text: e?.label ?? 'Casa');
    _streetCtrl = TextEditingController(text: e?.street ?? '');
    _numberCtrl = TextEditingController(text: e?.number ?? '');
    _complementCtrl = TextEditingController(text: e?.complement ?? '');
    _neighborhoodCtrl = TextEditingController(text: e?.neighborhood ?? '');
    _cityCtrl = TextEditingController(text: e?.city ?? '');
    _stateCtrl = TextEditingController(text: e?.state ?? '');
    _isDefault = e?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _streetCtrl.dispose();
    _numberCtrl.dispose();
    _complementCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _coverageError = null;
    });

    try {
      final covered =
          await ref.read(deliveryRepositoryProvider).validateDeliveryZone(
                state: _stateCtrl.text.trim(),
                city: _cityCtrl.text.trim(),
                neighborhood: _neighborhoodCtrl.text.trim(),
              );

      if (!covered) {
        setState(() => _coverageError =
            'Infelizmente ainda não entregamos neste endereço.');
        return;
      }

      final repo = ref.read(addressRepositoryProvider);
      final complement = _complementCtrl.text.trim();
      Address saved;
      if (widget.existing == null) {
        saved = await repo.addAddress(
          label: _labelCtrl.text.trim(),
          state: _stateCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          neighborhood: _neighborhoodCtrl.text.trim(),
          street: _streetCtrl.text.trim(),
          number: _numberCtrl.text.trim(),
          complement: complement.isEmpty ? null : complement,
          isDefault: _isDefault,
        );
      } else {
        saved = Address(
          id: widget.existing!.id,
          label: _labelCtrl.text.trim(),
          state: _stateCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          neighborhood: _neighborhoodCtrl.text.trim(),
          street: _streetCtrl.text.trim(),
          number: _numberCtrl.text.trim(),
          complement: complement.isEmpty ? null : complement,
          isDefault: _isDefault,
        );
        await repo.updateAddress(saved);
      }

      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar endereço: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.existing == null ? 'Novo endereço' : 'Editar endereço'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Identificação', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: Address.suggestedLabels.map((label) {
                  final selected = _labelCtrl.text == label;
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _labelCtrl.text = label),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _labelCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nome do endereço *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    Validators.required(v, field: 'Nome do endereço'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              Text('Endereço', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _streetCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Rua / Av. *'),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          Validators.required(v, field: 'Rua'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _numberCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Número *'),
                      validator: (v) =>
                          Validators.required(v, field: 'Número'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _complementCtrl,
                decoration: const InputDecoration(labelText: 'Complemento'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _neighborhoodCtrl,
                decoration: const InputDecoration(labelText: 'Bairro *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => Validators.required(v, field: 'Bairro'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: 'Cidade *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => Validators.required(v, field: 'Cidade'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stateCtrl,
                decoration:
                    const InputDecoration(labelText: 'Estado (sigla) *'),
                textCapitalization: TextCapitalization.characters,
                maxLength: 2,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.length != 2) {
                    return 'Informe a sigla do estado (ex: SP)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Definir como endereço padrão'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
              ),
              if (_coverageError != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_off_outlined,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_coverageError!,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Salvar endereço'),
                  onPressed: _saving ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
