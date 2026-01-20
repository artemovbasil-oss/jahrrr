create extension if not exists "pgcrypto";

create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  type text not null check (type in ('retainer', 'project')),
  contact_person text,
  phone text,
  email text,
  telegram text,
  planned_budget numeric,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.retainer_settings (
  client_id uuid primary key references public.clients(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  amount numeric not null check (amount > 0),
  frequency text not null check (frequency in ('once_month', 'twice_month')),
  next_payment_date date not null,
  is_enabled boolean not null default true,
  updated_at timestamptz not null default now()
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  client_id uuid not null references public.clients(id) on delete cascade,
  title text not null,
  amount numeric not null check (amount > 0),
  status text not null check (
    status in (
      'first_meeting',
      'deposit_received',
      'in_progress',
      'awaiting_feedback',
      'returned_for_revision',
      'renegotiating_budget',
      'project_on_hold',
      'payment_received_in_full'
    )
  ),
  deadline_date date,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.project_payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  amount numeric not null check (amount > 0),
  kind text not null check (kind in ('deposit', 'milestone', 'final', 'other')),
  status text not null check (status in ('planned', 'paid')),
  due_date date,
  paid_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at() returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

do $$
begin
  if not exists (
    select 1 from pg_trigger where tgname = 'set_clients_updated_at'
  ) then
    create trigger set_clients_updated_at
    before update on public.clients
    for each row execute procedure public.set_updated_at();
  end if;

  if not exists (
    select 1 from pg_trigger where tgname = 'set_projects_updated_at'
  ) then
    create trigger set_projects_updated_at
    before update on public.projects
    for each row execute procedure public.set_updated_at();
  end if;

  if not exists (
    select 1 from pg_trigger where tgname = 'set_project_payments_updated_at'
  ) then
    create trigger set_project_payments_updated_at
    before update on public.project_payments
    for each row execute procedure public.set_updated_at();
  end if;

  if not exists (
    select 1 from pg_trigger where tgname = 'set_retainer_settings_updated_at'
  ) then
    create trigger set_retainer_settings_updated_at
    before update on public.retainer_settings
    for each row execute procedure public.set_updated_at();
  end if;
end $$;

alter table public.clients enable row level security;
alter table public.retainer_settings enable row level security;
alter table public.projects enable row level security;
alter table public.project_payments enable row level security;

create policy "Clients read own" on public.clients
  for select using (user_id = auth.uid());
create policy "Clients insert own" on public.clients
  for insert with check (user_id = auth.uid());
create policy "Clients update own" on public.clients
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Clients delete own" on public.clients
  for delete using (user_id = auth.uid());

create policy "Retainers read own" on public.retainer_settings
  for select using (user_id = auth.uid());
create policy "Retainers insert own" on public.retainer_settings
  for insert with check (user_id = auth.uid());
create policy "Retainers update own" on public.retainer_settings
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Retainers delete own" on public.retainer_settings
  for delete using (user_id = auth.uid());

create policy "Projects read own" on public.projects
  for select using (user_id = auth.uid());
create policy "Projects insert own" on public.projects
  for insert with check (user_id = auth.uid());
create policy "Projects update own" on public.projects
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Projects delete own" on public.projects
  for delete using (user_id = auth.uid());

create policy "Payments read own" on public.project_payments
  for select using (user_id = auth.uid());
create policy "Payments insert own" on public.project_payments
  for insert with check (user_id = auth.uid());
create policy "Payments update own" on public.project_payments
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Payments delete own" on public.project_payments
  for delete using (user_id = auth.uid());
