import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../cart/application/cart_providers.dart';
import 'checkout_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.checkoutData});

  final CheckoutData checkoutData;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _loading = false;
  String? _errorMessage;
  String? _pendingOrderId;
  StreamSubscription<dynamic>? _realtimeSub;

  @override
  void dispose() {
    _realtimeSub?.cancel();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final data = widget.checkoutData;

      // 1. Create order + PaymentIntent via Edge Function
      final response = await supabase.functions.invoke(
        'create-payment-intent',
        body: {
          'cart': data.items
              .map((i) => {
                    'skuId': i.sku.id,
                    'quantity': i.quantity,
                  })
              .toList(),
          'deliveryDate':
              data.deliveryDate.toIso8601String().substring(0, 10),
          'deliveryAddress': data.deliveryAddress.toJson(),
        },
      );

      final orderId = response.data['orderId'] as String;
      final clientSecret = response.data['clientSecret'] as String;

      setState(() => _pendingOrderId = orderId);

      // 2. Initialize Payment Sheet (card + PIX handled by Stripe UI)
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Madame Jam',
          style: ThemeMode.light,
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Watch Realtime for payment_status = 'paid'
      _watchOrderConfirmation(orderId);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        setState(() {
          _loading = false;
          _errorMessage = null;
        });
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = e.error.localizedMessage ?? 'Pagamento recusado.';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Erro ao processar pagamento: $e';
      });
    }
  }

  void _watchOrderConfirmation(String orderId) {
    final supabase = ref.read(supabaseClientProvider);
    _realtimeSub = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .listen((rows) {
          if (rows.isEmpty) return;
          final status = rows.first['payment_status'] as String?;
          if (status == 'paid') {
            _realtimeSub?.cancel();
            if (!mounted) return;
            // Clear cart and navigate to confirmation
            ref.read(cartProvider.notifier).clear();
            context.go(
              AppRoutes.orderConfirmationPath(orderId),
            );
          } else if (status == 'failed') {
            _realtimeSub?.cancel();
            if (!mounted) return;
            setState(() {
              _loading = false;
              _errorMessage =
                  'Pagamento não aprovado. Tente novamente.';
            });
          }
        });

    // Timeout after 10 minutes for PIX
    Future.delayed(const Duration(minutes: 10), () {
      if (mounted && _loading) {
        _realtimeSub?.cancel();
        setState(() {
          _loading = false;
          _errorMessage =
              'Tempo expirado. Verifique o status do seu pedido.';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento')),
      body: _loading
          ? _WaitingPayment(orderId: _pendingOrderId)
          : _PaymentBody(
              checkoutData: widget.checkoutData,
              errorMessage: _errorMessage,
              onPay: _pay,
            ),
    );
  }
}

class _WaitingPayment extends StatelessWidget {
  const _WaitingPayment({this.orderId});
  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              orderId == null
                  ? 'Criando pedido…'
                  : 'Aguardando confirmação do pagamento…',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (orderId != null) ...[
              const SizedBox(height: 12),
              Text(
                'Para PIX: após pagar no seu banco, '
                'esta tela será atualizada automaticamente.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentBody extends StatelessWidget {
  const _PaymentBody({
    required this.checkoutData,
    required this.onPay,
    this.errorMessage,
  });

  final CheckoutData checkoutData;
  final VoidCallback onPay;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final data = checkoutData;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Resumo ────────────────────────────────────────────────
          Text('Resumo', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Entrega',
            value:
                '${data.deliveryDate.day.toString().padLeft(2, '0')}/'
                '${data.deliveryDate.month.toString().padLeft(2, '0')}/'
                '${data.deliveryDate.year}',
          ),
          _InfoRow(
            label: 'Endereço',
            value: data.deliveryAddress.formatted,
          ),
          const SizedBox(height: 12),
          ...data.items.map(
            (item) => _InfoRow(
              label: '${item.productName} — ${item.sku.name} × ${item.quantity}',
              value: 'R\$ ${item.subtotal.toStringAsFixed(2)}',
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: textTheme.titleMedium),
              Text(
                'R\$ ${data.total.toStringAsFixed(2)}',
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.champagneDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(errorMessage!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          Text('Forma de pagamento', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Cartão de crédito/débito ou PIX — escolha no próximo passo.',
            style: textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.lock_outline),
              label: const Text('Pagar com segurança'),
              onPressed: onPay,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_outlined,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Pagamento seguro processado pelo Stripe',
                style: textTheme.bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
