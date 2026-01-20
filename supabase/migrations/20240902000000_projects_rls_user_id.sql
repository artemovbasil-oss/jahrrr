alter table public.projects alter column user_id set default auth.uid();

create or replace function public.set_project_user_id() returns trigger as $$
begin
  if new.user_id is null then
    new.user_id := auth.uid();
  end if;
  return new;
end;
$$ language plpgsql;

do $$
begin
  if not exists (
    select 1 from pg_trigger where tgname = 'set_projects_user_id'
  ) then
    create trigger set_projects_user_id
    before insert on public.projects
    for each row execute procedure public.set_project_user_id();
  end if;
end $$;

drop policy if exists "Projects insert own" on public.projects;
drop policy if exists "Projects update own" on public.projects;

create policy "Projects insert own" on public.projects
  for insert
  with check (
    user_id = auth.uid()
    and client_id in (
      select id from public.clients where user_id = auth.uid()
    )
  );

create policy "Projects update own" on public.projects
  for update
  using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    and client_id in (
      select id from public.clients where user_id = auth.uid()
    )
  );
