import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../admin/data/delivery_repository.dart';
import '../../cart/application/cart_providers.dart';
import '../../cart/domain/cart_item.dart';
import '../../orders/domain/order.dart';

/// Dados passados via GoRouter extra para PaymentScreen.
class CheckoutData {
  const CheckoutData({
    required this.items,
    required this.deliveryDate,
    required this.deliveryAddress,
    required this.total,
  });

  final List<CartItem> items;
  final DateTime deliveryDate;
  final DeliveryAddress deliveryAddress;
  final double total;
}

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _complementCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();

  DateTime? _selectedDate;
  bool _validating = false;
  String? _coverageError;

  @override
  void dispose() {
    _streetCtrl.dispose();
    _numberCtrl.dispose();
    _complementCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
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

  Future<void> _validateAndProceed() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de entrega.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _validating = true;
      _coverageError = null;
    });

    try {
      final covered = await ref
          .read(deliveryRepositoryProvider)
          .validateDeliveryZone(
            state: _stateCtrl.text.trim(),
            city: _cityCtrl.text.trim(),
            neighborhood: _neighborhoodCtrl.text.trim(),
          );

      if (!covered) {
        setState(() => _coverageError =
            'Infelizmente ainda não entregamos neste endereço.');
        return;
      }

      final address = DeliveryAddress(
        state: _stateCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        neighborhood: _neighborhoodCtrl.text.trim(),
        street: _streetCtrl.text.trim(),
        number: _numberCtrl.text.trim(),
        complement: _complementCtrl.text.trim().isEmpty
            ? null
            : _complementCtrl.text.trim(),
      );

      final items = ref.read(cartProvider);
      final total = ref.read(cartTotalProvider);

      if (!mounted) return;
      context.push(
        AppRoutes.payment,
        extra: CheckoutData(
          items: items,
          deliveryDate: _selectedDate!,
          deliveryAddress: address,
          total: total,
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

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            // ── Data de entrega ───────────────────────────────────────
            Text('Data de entrega',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(_selectedDate == null
                  ? 'Selecionar data'
                  : '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                      '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                      '${_selectedDate!.year}'),
              onPressed: _pickDate,
            ),
            const SizedBox(height: 28),

            // ── Endereço ──────────────────────────────────────────────
            Text('Endereço de entrega',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
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
                    decoration:
                        const InputDecoration(labelText: 'Complemento'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _neighborhoodCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Bairro *'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        Validators.required(v, field: 'Bairro'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cityCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Cidade *'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        Validators.required(v, field: 'Cidade'),
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
