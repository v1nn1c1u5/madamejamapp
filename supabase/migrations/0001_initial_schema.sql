-- Madame Jam — Schema inicial
-- Arquitetura: PostgreSQL via Supabase, com RLS em todas as tabelas.
-- Referência: architecture.md (Modelo de Dados) e epics.md.
--
-- Convenção de role admin: app_metadata.role = 'admin' no JWT.
-- Helper abaixo lê esse claim para as policies.

-- ---------------------------------------------------------------------------
-- Helper: is_admin()
-- ---------------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
stable
as $$
  select coalesce(
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin',
    false
  );
$$;

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.payment_status as enum (
  'pending', 'paid', 'failed', 'refunded'
);

create type public.production_status as enum (
  'aguardando', 'em_producao', 'pronto', 'saiu_entrega', 'entregue'
);

-- ---------------------------------------------------------------------------
-- Produtos e variantes
-- ---------------------------------------------------------------------------
create table public.products (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text,
  active      boolean not null default true,
  created_at  timestamptz not null default now()
);

create table public.skus (
  id           uuid primary key default gen_random_uuid(),
  product_id   uuid not null references public.products(id) on delete cascade,
  name         text not null,
  price        numeric(10, 2) not null check (price >= 0),
  min_quantity integer not null default 1 check (min_quantity >= 1),
  active       boolean not null default true
);

create table public.product_images (
  id          uuid primary key default gen_random_uuid(),
  product_id  uuid not null references public.products(id) on delete cascade,
  storage_url text not null,
  position    integer not null default 0
);

create index on public.skus (product_id);
create index on public.product_images (product_id);

-- ---------------------------------------------------------------------------
-- Configuração da loja: cobertura e datas bloqueadas
-- ---------------------------------------------------------------------------
create table public.delivery_zones (
  id           uuid primary key default gen_random_uuid(),
  state        text not null,
  city         text not null,
  neighborhood text not null
);

create table public.blocked_dates (
  id     uuid primary key default gen_random_uuid(),
  date   date not null unique,
  reason text
);

-- ---------------------------------------------------------------------------
-- Clientes (1:1 com auth.users)
-- ---------------------------------------------------------------------------
create table public.customers (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null unique references auth.users(id) on delete cascade,
  name       text not null,
  phone      text,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Pedidos
-- ---------------------------------------------------------------------------
create table public.orders (
  id                       uuid primary key default gen_random_uuid(),
  customer_id              uuid not null references public.customers(id) on delete restrict,
  delivery_date            date not null,
  delivery_address         jsonb not null,
  payment_status           public.payment_status not null default 'pending',
  production_status        public.production_status not null default 'aguardando',
  stripe_payment_intent_id text,
  total                    numeric(10, 2) not null check (total >= 0),
  created_at               timestamptz not null default now()
);

create table public.order_items (
  id         uuid primary key default gen_random_uuid(),
  order_id   uuid not null references public.orders(id) on delete cascade,
  sku_id     uuid not null references public.skus(id) on delete restrict,
  quantity   integer not null check (quantity >= 1),
  unit_price numeric(10, 2) not null check (unit_price >= 0)
);

create index on public.orders (customer_id);
create index on public.orders (delivery_date);
create index on public.order_items (order_id);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.products       enable row level security;
alter table public.skus           enable row level security;
alter table public.product_images enable row level security;
alter table public.delivery_zones enable row level security;
alter table public.blocked_dates  enable row level security;
alter table public.customers      enable row level security;
alter table public.orders         enable row level security;
alter table public.order_items    enable row level security;

-- Catálogo e config de entrega: leitura pública, escrita só admin.
create policy "catalogo leitura publica" on public.products
  for select using (true);
create policy "catalogo escrita admin" on public.products
  for all using (public.is_admin()) with check (public.is_admin());

create policy "skus leitura publica" on public.skus
  for select using (true);
create policy "skus escrita admin" on public.skus
  for all using (public.is_admin()) with check (public.is_admin());

create policy "imagens leitura publica" on public.product_images
  for select using (true);
create policy "imagens escrita admin" on public.product_images
  for all using (public.is_admin()) with check (public.is_admin());

create policy "zonas leitura publica" on public.delivery_zones
  for select using (true);
create policy "zonas escrita admin" on public.delivery_zones
  for all using (public.is_admin()) with check (public.is_admin());

create policy "datas leitura publica" on public.blocked_dates
  for select using (true);
create policy "datas escrita admin" on public.blocked_dates
  for all using (public.is_admin()) with check (public.is_admin());

-- Clientes: cada um vê/edita o próprio registro; admin vê todos.
create policy "cliente proprio registro" on public.customers
  for select using (user_id = auth.uid() or public.is_admin());
create policy "cliente insere proprio" on public.customers
  for insert with check (user_id = auth.uid());
create policy "cliente atualiza proprio" on public.customers
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Pedidos: cliente vê os próprios; admin vê e gerencia todos.
create policy "pedido leitura propria" on public.orders
  for select using (
    public.is_admin()
    or customer_id in (
      select id from public.customers where user_id = auth.uid()
    )
  );
create policy "pedido cliente insere" on public.orders
  for insert with check (
    customer_id in (
      select id from public.customers where user_id = auth.uid()
    )
  );
create policy "pedido admin gerencia" on public.orders
  for update using (public.is_admin()) with check (public.is_admin());

-- Itens do pedido: herdam o acesso do pedido.
create policy "itens leitura" on public.order_items
  for select using (
    public.is_admin()
    or order_id in (
      select o.id from public.orders o
      join public.customers c on c.id = o.customer_id
      where c.user_id = auth.uid()
    )
  );
create policy "itens cliente insere" on public.order_items
  for insert with check (
    order_id in (
      select o.id from public.orders o
      join public.customers c on c.id = o.customer_id
      where c.user_id = auth.uid()
    )
  );
