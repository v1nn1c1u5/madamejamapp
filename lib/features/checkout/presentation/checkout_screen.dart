import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_routes.dart';
import '../../../core/auth/checkout_auth.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../admin/data/delivery_repository.dart';
import '../../addresses/data/address_repository.dart';
import '../../addresses/domain/address.dart';
import '../../addresses/presentation/address_list_screen.dart' show addressIcon;
import '../../cart/application/cart_providers.dart';
import '../../cart/domain/cart_item.dart';
import '../../orders/domain/order.dart';

/// Dados passados via GoRouter extra para PaymentScreen.
class CheckoutData {
  const CheckoutData({
    required this.items,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.deliveryAddress,
    required this.total,
    this.notes,
  });

  final List<CartItem> items;
  final DateTime deliveryDate;
  /// Horário desejado de entrega, formato "HH:mm".
  final String deliveryTime;
  final DeliveryAddress deliveryAddress;
  final double total;
  final String? notes;
}

String formatTimeOfDay(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _notesCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Address? _selectedAddress;
  bool _validating = false;
  String? _coverageError;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final blocked =
        await ref.read(deliveryRepositoryProvider).fetchBlockedDateStrings();

    if (!mounted) return;
    final now = DateTime.now();
    final firstDay = now.add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: firstDay,
      firstDate: firstDay,
      lastDate: now.add(const Duration(days: 90)),
      selectableDayPredicate: (day) {
        final str = day.toIso8601String().substring(0, 10);
        return !blocked.contains(str);
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _coverageError = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 14, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _validateAndProceed() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de entrega.')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o horário de entrega.')),
      );
      return;
    }
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione ou adicione um endereço de entrega.')),
      );
      return;
    }

    setState(() {
      _validating = true;
      _coverageError = null;
    });

    try {
      final selected = _selectedAddress!;
      // Revalida a cobertura no momento do checkout: a zona pode ter
      // mudado desde que o endereço foi salvo.
      final covered = await ref
          .read(deliveryRepositoryProvider)
          .validateDeliveryZone(
            state: selected.state,
            city: selected.city,
            neighborhood: selected.neighborhood,
          );

      if (!covered) {
        setState(() => _coverageError =
            'Infelizmente ainda não entregamos neste endereço.');
        return;
      }

      final items = ref.read(cartProvider);
      final total = ref.read(cartTotalProvider);

      if (!mounted) return;

      final session = ref.read(sessionProvider);
      if (session == null) {
        context.go(signInRouteWithRedirect(AppRoutes.payment));
        return;
      }

      final notes = _notesCtrl.text.trim();

      context.push(
        AppRoutes.payment,
        extra: CheckoutData(
          items: items,
          deliveryDate: _selectedDate!,
          deliveryTime: formatTimeOfDay(_selectedTime!),
          deliveryAddress: selected.toDeliveryAddress(),
          total: total,
          notes: notes.isEmpty ? null : notes,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao validar endereço: $e')),
      );
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  Future<void> _openAddressForm({Address? existing}) async {
    final result = await context.push<Address>(
      AppRoutes.addressForm,
      extra: existing,
    );
    if (result == null) return;
    ref.invalidate(myAddressesProvider);
    setState(() {
      _selectedAddress = result;
      _coverageError = null;
    });
  }

  Future<void> _deleteAddress(Address address) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover endereço'),
        content: Text('Remover "${address.label}"?'),
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
    if (ok != true) return;

    await ref.read(addressRepositoryProvider).deleteAddress(address.id);
    if (_selectedAddress?.id == address.id) {
      setState(() => _selectedAddress = null);
    }
    ref.invalidate(myAddressesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    // Pré-seleciona o endereço padrão (ou o primeiro salvo) assim que a
    // lista chega, sem sobrescrever uma escolha manual do usuário.
    ref.listen<AsyncValue<List<Address>>>(myAddressesProvider, (prev, next) {
      next.whenData((list) {
        if (_selectedAddress == null && list.isNotEmpty) {
          final def =
              list.firstWhere((a) => a.isDefault, orElse: () => list.first);
          setState(() => _selectedAddress = def);
        }
      });
    });
    final addressesAsync = ref.watch(myAddressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CheckoutIdentityBanner(),
            const SizedBox(height: 20),

            // ── Resumo ────────────────────────────────────────────────
            Text('Seu pedido',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...items.map((item) => _SummaryRow(item: item)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total',
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  style:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.champagneDark,
                            fontWeight: FontWeight.bold,
                          ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Data e horário de entrega ─────────────────────────────
            Text('Data e horário de entrega',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(_selectedDate == null
                        ? 'Selecionar data'
                        : '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                            '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                            '${_selectedDate!.year}'),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time_outlined),
                    label: Text(_selectedTime == null
                        ? 'Selecionar horário'
                        : formatTimeOfDay(_selectedTime!)),
                    onPressed: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Endereço ──────────────────────────────────────────────
            Text('Endereço de entrega',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            addressesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Erro ao carregar endereços: $e'),
              data: (list) => Column(
                children: [
                  ...list.map(
                    (a) => _AddressCard(
                      address: a,
                      selected: _selectedAddress?.id == a.id,
                      onTap: () => setState(() {
                        _selectedAddress = a;
                        _coverageError = null;
                      }),
                      onEdit: () => _openAddressForm(existing: a),
                      onDelete: () => _deleteAddress(a),
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('Adicionar novo endereço'),
                    onPressed: () => _openAddressForm(),
                  ),
                ],
              ),
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

            const SizedBox(height: 28),

            // ── Observações ───────────────────────────────────────────
            Text('Observações',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                hintText: 'Alguma informação complementar? (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: _validating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.payment_outlined),
                label: const Text('Ir para o pagamento'),
                onPressed: _validating || items.isEmpty
                    ? null
                    : _validateAndProceed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${item.productName} — ${item.sku.name} × ${item.quantity}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            'R\$ ${item.subtotal.toStringAsFixed(2)}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Address address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  selected ? AppColors.champagneDark : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            color: selected ? AppColors.champagneLight : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(addressIcon(address.label), color: AppColors.champagneDark),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address.label,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.champagne.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Padrão',
                                style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.formatted,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
