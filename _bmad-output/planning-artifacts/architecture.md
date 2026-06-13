---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments: ["_bmad-output/planning-artifacts/prd.md", "_bmad-output/brainstorming/brainstorming-session-2026-05-06.md"]
workflowType: 'architecture'
project_name: 'madamejam'
user_name: 'Elton'
date: '2026-06-13'
---

# Architecture Decision Document — Madame Jam

**Arquiteto:** Winston (BMAD)
**Data:** 2026-06-13
**Versão:** 1.0

---

## Visão Técnica

O Madame Jam é um app mobile Flutter com Supabase como backend completo — banco, autenticação, realtime e storage. A escolha favorece velocidade de desenvolvimento e ausência de backend customizado para este escopo. O Stripe cobre cartão e PIX nativamente no Brasil, eliminando a necessidade de segundo gateway. A arquitetura é intencionalmente simples: escala adequada para 20–200 pedidos/semana sem reengenharia.

---

## Stack de Tecnologia

| Camada | Tecnologia | Justificativa |
|---|---|---|
| Mobile | Flutter 3.x (iOS + Android) | Código único, suporte iOS prioritário para admin |
| Backend | Supabase | Auth + PostgreSQL + Realtime + Storage em um serviço |
| Banco de dados | PostgreSQL (via Supabase) | Relacional, RLS nativo, queries complexas para painel admin |
| Autenticação | Supabase Auth | Email/senha, roles por custom claim |
| Pagamentos | Stripe | Cartão de crédito/débito + PIX (disponível no Brasil) |
| Storage | Supabase Storage | Imagens de produtos, bucket público |
| Realtime | Supabase Realtime | Status de produção ao vivo para o cliente |
| State management | Riverpod | Padrão dominante com Supabase Flutter |
| Navegação | go_router | Deep links, proteção de rotas por role |
| Pagamento Flutter | flutter_stripe | SDK oficial Stripe para Flutter |

---

## Decisões de Arquitetura

### 1. Supabase como BFF (Backend-for-Frontend)

O Flutter se conecta diretamente ao Supabase SDK — sem API intermediária. As regras de negócio críticas (criar payment intent, processar webhook Stripe) rodam em **Supabase Edge Functions** para manter o `STRIPE_SECRET_KEY` fora do cliente.

**Fluxo de chamada:**
```
Flutter → Supabase SDK (RLS enforced) → PostgreSQL
Flutter → Supabase Edge Function → Stripe API
Stripe Webhook → Supabase Edge Function → PostgreSQL (atualiza status)
```

### 2. Autenticação e Roles

- **Supabase Auth** com email + senha para clientes
- **Admin** identificado por custom claim `app_metadata.role = 'admin'` — configurado manualmente no Supabase Dashboard para a operadora da loja
- **RLS (Row Level Security):** clientes enxergam apenas seus próprios pedidos; admin enxerga tudo
- O app Flutter exibe navegação diferente com base no role detectado no token JWT

### 3. Pagamento com Stripe

**Cartão:**
1. Cliente confirma pedido no app
2. Flutter chama Edge Function `/create-payment-intent`
3. Edge Function cria PaymentIntent no Stripe, retorna `client_secret`
4. Flutter usa `flutter_stripe` para coletar dados do cartão e confirmar pagamento
5. Stripe notifica webhook → Edge Function atualiza `orders.payment_status = 'paid'`
6. Supabase Realtime notifica o app → exibe tela de confirmação

**PIX:**
1. Flutter chama Edge Function `/create-pix-payment`
2. Edge Function cria PaymentIntent com `payment_method_types: ['pix']` no Stripe
3. Stripe retorna QR Code + código copia-e-cola
4. Cliente paga no banco → Stripe processa → webhook atualiza status
5. App monitora via Supabase Realtime e exibe confirmação automaticamente

### 4. Status de Produção em Tempo Real

Supabase Realtime via **PostgreSQL Changes** — o app do cliente assina alterações na tabela `orders` filtradas pelo `id` do próprio pedido. Quando a admin atualiza o status, o cliente vê em segundos sem precisar recarregar.

```dart
supabase.from('orders')
  .stream(primaryKey: ['id'])
  .eq('id', orderId)
  .listen((data) => updateProductionStatus(data));
```

### 5. App Único com Modo Admin

Um único app Flutter com dois fluxos de navegação:
- **Modo cliente:** catálogo, carrinho, checkout, acompanhamento de pedidos
- **Modo admin:** visão semanal, visão diária, detalhe de pedido, atualização de status, gestão de produtos

O roteamento protegido pelo go_router verifica o role no JWT antes de liberar rotas admin.

---

## Modelo de Dados (PostgreSQL / Supabase)

```sql
-- Produtos e variantes
products (id, name, description, active, created_at)
skus     (id, product_id, name, price, min_quantity, active)
product_images (id, product_id, storage_url, position)

-- Configurações da loja
delivery_zones (id, state, city, neighborhood)
blocked_dates  (id, date, reason)

-- Clientes
customers (id, user_id [FK auth.users], name, phone)

-- Pedidos
orders (
  id, customer_id, delivery_date, delivery_address,
  payment_status  [pending | paid | failed | refunded],
  production_status [aguardando | em_producao | pronto | saiu_entrega | entregue],
  stripe_payment_intent_id, total, created_at
)
order_items (id, order_id, sku_id, quantity, unit_price)
```

**RLS Policies essenciais:**
- `orders`: `SELECT/UPDATE` apenas se `customer_id = auth.uid()` (cliente) ou `role = 'admin'`
- `order_items`: herdado via `order_id`
- `products/skus`: leitura pública; escrita apenas admin
- `delivery_zones/blocked_dates`: leitura pública; escrita apenas admin

---

## Estrutura do Projeto Flutter

```
lib/
├── core/
│   ├── supabase/        # cliente Supabase, inicialização
│   ├── stripe/          # configuração flutter_stripe
│   └── router/          # go_router com guards de role
├── features/
│   ├── auth/            # login, cadastro, recuperação de senha
│   ├── catalog/         # listagem de produtos, detalhe, variantes
│   ├── cart/            # carrinho, validação de mínimos
│   ├── checkout/        # endereço, data de entrega, pagamento
│   ├── orders/          # histórico, acompanhamento de produção
│   └── admin/
│       ├── orders/      # visão semanal, visão diária, detalhe
│       ├── production/  # atualização de status
│       └── products/    # cadastro e edição de produtos
└── shared/
    ├── widgets/         # componentes reutilizáveis com identidade visual
    └── theme/           # design system (cores, tipografia, mascote)
```

---

## Identidade Visual — Diretrizes para Implementação

| Elemento | Especificação |
|---|---|
| Paleta principal | Bege/champagne `#C4A882`, off-white `#F5F0EA`, carvão `#2C2C2C` |
| Tipografia | Serifada (display/títulos), sans-serif limpa (corpo/rótulos) |
| Estilo | Clean, sofisticado, artesanal — sem excessos decorativos |
| Mascote | Personagem 3D animado — usar em onboarding, estados vazios e confirmações |
| Logo | "Madame Jam" + subtítulo "Da minha família para a sua" |
| Ícone | Fouet + espiga de trigo em composição circular |
| Tom UX | Conduzir o cliente para finalizar o pedido em poucos cliques — CTA sempre visível |
| Imagens | Fotos de produtos em destaque; o app é vitrine da loja |

**Referência:** Instagram [@madame_jamm](https://www.instagram.com/madame_jamm/)

---

## Supabase Edge Functions

| Função | Responsabilidade |
|---|---|
| `create-payment-intent` | Cria PaymentIntent Stripe (cartão), retorna client_secret |
| `create-pix-payment` | Cria PaymentIntent PIX, retorna QR Code + código |
| `stripe-webhook` | Recebe eventos Stripe, atualiza `payment_status` do pedido |
| `validate-delivery-zone` | Verifica se endereço está na área de cobertura |

---

## Segurança

- Stripe secret key apenas em Edge Functions — nunca no cliente Flutter
- RLS habilitado em todas as tabelas — fallback de segurança no banco
- Admin role via `app_metadata` (JWT) — não alterável pelo cliente
- HTTPS enforced pelo Supabase
- Dados de cartão nunca passam pelo Supabase — tratados exclusivamente pelo Stripe SDK (PCI DSS via Stripe)

---

## Infraestrutura e Ambiente

| Item | Decisão |
|---|---|
| Supabase tier | Free tier para desenvolvimento; Pro (~$25/mês) para produção |
| Stripe | Conta Brasil (habilita PIX) — modo test → produção |
| Deploy mobile | App Store (iOS) + Google Play (Android) |
| Ambientes | `dev` (Supabase projeto separado) + `prod` |
| CI/CD | Fora do escopo MVP — build manual via `flutter build` |

---

## Fora do Escopo da Arquitetura MVP

- Push notifications (Firebase Cloud Messaging — pós-MVP)
- CDN para imagens de produto (Supabase Storage serve diretamente no MVP)
- Analytics / crash reporting (pós-MVP)
- Testes automatizados de integração (pós-MVP)
