alter table public.clients
  add column if not exists avatar_color text;

update public.clients
  set avatar_color = '#2D6EF8'
  where avatar_color is null;

select pg_notify('pgrst', 'reload schema');
