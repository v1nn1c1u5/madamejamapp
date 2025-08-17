# Alteração do Método de Pagamento: Fiado → Reserva de 50%

## Resumo da Mudança

Substituímos o método de pagamento "Fiado" por "Reserva de 50%" para melhor refletir o modelo de negócio onde o cliente paga 50% no momento do pedido e 50% na entrega.

## Arquivos Modificados

### 1. Frontend (Flutter)
- **Arquivo**: `lib/presentation/manual_order_creation/widgets/payment_options_widget.dart`
- **Mudanças**:
  - Valor do método: `'credit'` → `'reservation'`
  - Título: `'Fiado'` → `'Reserva de 50%'`
  - Descrição: `'Conta do cliente'` → `'Paga 50% agora, 50% na entrega'`

### 2. Backend (Supabase)
- **Arquivo**: `supabase/migrations/20250817000001_update_payment_method_enum.sql`
- **Mudanças**:
  - Atualização do ENUM `payment_method`
  - Migração de dados existentes de `'credit'` para `'reservation'`
  - Remoção do valor `'credit'` do ENUM

## Como Funciona o Novo Método

### Reserva de 50%
- **Pagamento Inicial**: 50% do valor total no momento do pedido
- **Pagamento Final**: 50% restante na entrega do produto
- **Status de Pagamento**: Permanece como `'pending'` até a conclusão total
- **Vantagens**:
  - Garante o comprometimento do cliente
  - Reduz o risco de cancelamentos
  - Melhora o fluxo de caixa da padaria

## Impacto no Sistema

### Dados Existentes
- Todos os pedidos com método `'credit'` serão automaticamente migrados para `'reservation'`
- Não há perda de dados ou funcionalidade

### Interface do Usuário
- Nova opção aparece como "Reserva de 50%" no seletor de métodos de pagamento
- Descrição clara do funcionamento do método
- Mesmo ícone (conta/carteira) mantido para familiaridade

### Considerações Futuras

Para implementação completa, considere adicionar:

1. **Lógica de Pagamento Parcial**:
   ```dart
   // Calcular valores de entrada e saída
   double initialPayment = totalAmount * 0.5;
   double finalPayment = totalAmount * 0.5;
   ```

2. **Status de Pagamento Detalhado**:
   - `'partial_paid'` - 50% pago
   - `'fully_paid'` - 100% pago

3. **Notificações**:
   - Lembrete para o cliente sobre pagamento restante
   - Controle interno de pagamentos pendentes

4. **Relatórios**:
   - Acompanhamento de reservas pendentes
   - Fluxo de caixa previsto vs realizado

## Data da Alteração
17 de Agosto de 2025
