-- Madame Jam — Habilita Realtime na tabela orders
--
-- Sem isso, o app (payment_screen.dart) nunca recebe o evento de UPDATE
-- quando a Edge Function stripe-webhook confirma o pagamento e atualiza
-- orders.payment_status = 'paid'. O usuário vê o pedido "pago" no Stripe,
-- o banco fica correto, mas a tela de checkout fica presa em "Aguardando
-- confirmação..." até o timeout de 3 minutos, pois o .stream() nunca dispara.
--
-- Verificação condicional: evita erro caso a tabela já tenha sido
-- adicionada manualmente pelo painel (Database → Replication).
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'orders'
  ) then
    alter publication supabase_realtime add table public.orders;
  end if;
end $$;
