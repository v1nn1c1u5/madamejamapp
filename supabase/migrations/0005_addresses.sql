-- Madame Jam — Endereços salvos do cliente
--
-- Antes, o endereço de entrega era sempre digitado do zero a cada pedido.
-- Esta migration adiciona um "livro de endereços" por cliente (padrão
-- Casa/Trabalho/Outro, como no iFood), reaproveitado nos próximos checkouts.
-- `orders.delivery_address` continua sendo um snapshot JSON independente,
-- então editar/excluir um endereço salvo não afeta pedidos já feitos.

create table public.addresses (
  id           uuid primary key default gen_random_uuid(),
  customer_id  uuid not null references public.customers(id) on delete cascade,
  label        text not null,
  state        text not null,
  city         text not null,
  neighborhood text not null,
  street       text not null,
  number       text not null,
  complement   text,
  is_default   boolean not null default false,
  created_at   timestamptz not null default now()
);

create index on public.addresses (customer_id);

alter table public.addresses enable row level security;

create policy "endereco proprio select" on public.addresses
  for select using (
    customer_id in (select id from public.customers where user_id = auth.uid())
  );
create policy "endereco proprio insert" on public.addresses
  for insert with check (
    customer_id in (select id from public.customers where user_id = auth.uid())
  );
create policy "endereco proprio update" on public.addresses
  for update using (
    customer_id in (select id from public.customers where user_id = auth.uid())
  ) with check (
    customer_id in (select id from public.customers where user_id = auth.uid())
  );
create policy "endereco proprio delete" on public.addresses
  for delete using (
    customer_id in (select id from public.customers where user_id = auth.uid())
  );

-- Garante um único endereço padrão por cliente.
create or replace function public.enforce_single_default_address()
returns trigger
language plpgsql
as $$
begin
  update public.addresses
    set is_default = false
    where customer_id = new.customer_id
      and id <> new.id
      and is_default = true;
  return new;
end;
$$;

create trigger addresses_single_default
  before insert or update of is_default on public.addresses
  for each row
  when (new.is_default = true)
  execute function public.enforce_single_default_address();
