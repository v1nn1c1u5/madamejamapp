-- Madame Jam — Comparação de zona de entrega insensível a acentuação
--
-- Problema: a validação de cobertura usava `ilike`, que ignora
-- maiúsculas/minúsculas mas não diacríticos. Um bairro cadastrado como
-- "Pituacu" não batia com "Pituaçu" digitado pelo cliente (ou vice-versa),
-- dando a falsa impressão de que o app rejeitava acentuação.
--
-- Solução: função `delivery_zone_covered`, usada tanto pela Edge Function
-- quanto pelo fallback local do app, comparando com `unaccent()`.

create extension if not exists unaccent;

create or replace function public.delivery_zone_covered(
  p_state text,
  p_city text,
  p_neighborhood text
)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.delivery_zones
    where unaccent(lower(state)) = unaccent(lower(p_state))
      and unaccent(lower(city)) = unaccent(lower(p_city))
      and unaccent(lower(neighborhood)) = unaccent(lower(p_neighborhood))
  );
$$;

grant execute on function public.delivery_zone_covered(text, text, text)
  to anon, authenticated;
