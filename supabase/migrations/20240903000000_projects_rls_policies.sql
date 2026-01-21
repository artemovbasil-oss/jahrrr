alter table public.projects enable row level security;

drop policy if exists "Projects insert own" on public.projects;
drop policy if exists "Projects read own" on public.projects;

create policy "Projects read own" on public.projects
  for select using (user_id = auth.uid());

create policy "Projects insert own" on public.projects
  for insert
  with check (
    user_id = auth.uid()
    and client_id in (
      select id from public.clients where user_id = auth.uid()
    )
  );
