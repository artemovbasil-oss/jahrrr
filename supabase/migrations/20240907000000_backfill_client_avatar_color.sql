alter table public.clients
  add column if not exists avatar_color text;

alter table public.clients
  add column if not exists color text;

update public.clients
  set avatar_color = color
  where (avatar_color is null or avatar_color = '')
    and color is not null
    and color <> '';

update public.clients
  set color = avatar_color
  where (color is null or color = '')
    and avatar_color is not null
    and avatar_color <> '';

select pg_notify('pgrst', 'reload schema');
