alter table if exists public.projects
  add column if not exists is_archived boolean not null default false;
