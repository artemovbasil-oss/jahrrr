alter table public.clients
  add column if not exists color text;

update public.clients
  set color = avatar_color
  where (color is null or color = '')
    and avatar_color is not null
    and avatar_color <> '';
