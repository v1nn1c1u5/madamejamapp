# Madame Jam

App mobile (Flutter) da confeitaria Madame Jam — catálogo, carrinho, pagamento
(Stripe: cartão e PIX) e agendamento de entrega, com acompanhamento de produção
em tempo real e painel administrativo.

Documentação de planejamento (BMAD) em `_bmad-output/planning-artifacts/`:
PRD, arquitetura e épicos/histórias.

## Stack

- **Flutter** (iOS + Android)
- **Supabase** — Auth, PostgreSQL, Realtime, Storage, Edge Functions
- **Stripe** — pagamentos (cartão + PIX)
- **Riverpod** (estado) · **go_router** (navegação com guards por role)

## Configuração do ambiente

As credenciais são injetadas em build via `--dart-define` e **não** são
commitadas. Copie o exemplo e preencha com os valores do seu projeto:

```bash
cp dart_define.example.json dart_define.json   # dart_define.json é gitignored
```

Preencha:

- `SUPABASE_URL` e `SUPABASE_ANON_KEY` — do painel do projeto Supabase
  (Settings → API). A `anon key` é pública por design (protegida por RLS).
- `STRIPE_PUBLISHABLE_KEY` — chave publicável do Stripe (test mode).

> A `service_role` do Supabase e a `secret key` do Stripe **nunca** vão no app —
> vivem apenas nas Supabase Edge Functions.

## Rodando

```bash
flutter pub get
flutter run --dart-define-from-file=dart_define.json
```

Sem as variáveis do Supabase, o app sobe numa tela de "configuração pendente".

## Banco de dados

As migrations ficam em `supabase/migrations/`. Para aplicar no projeto Supabase
(via Supabase CLI):

```bash
supabase link --project-ref SEU-PROJETO
supabase db push
```

`0001_initial_schema.sql` cria o schema completo (produtos, SKUs, pedidos,
clientes, zonas de entrega) com Row Level Security em todas as tabelas.

## Estrutura

```
lib/
├── core/            # config, supabase, router, theme (design system)
├── features/        # auth, catalog, cart, checkout, orders, admin
└── shared/          # widgets e componentes de marca
supabase/
└── migrations/      # schema SQL versionado
```
