-- Madame Jam — Trigger de criação de cliente
--
-- Cria automaticamente um registro em public.customers quando um usuário é
-- criado no Supabase Auth, lendo nome/telefone do metadata informado no
-- cadastro (auth.signUp data). Roda como SECURITY DEFINER, contornando RLS
-- e funcionando mesmo quando há confirmação de e-mail pendente.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.customers (user_id, name, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', ''),
    new.raw_user_meta_data ->> 'phone'
  )
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();
