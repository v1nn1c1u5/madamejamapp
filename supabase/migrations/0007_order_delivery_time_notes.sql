-- Madame Jam — Horário de entrega e observações do pedido
--
-- Nullable para não quebrar pedidos já existentes; o app exige o
-- preenchimento do horário no checkout para pedidos novos.

alter table public.orders
  add column delivery_time time,
  add column notes text;
