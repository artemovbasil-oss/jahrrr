alter table public.clients
  add column if not exists avatar_color text;

select pg_notify('pgrst', 'reload schema');
