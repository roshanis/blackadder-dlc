-- E-001 organizations, E-002 org_members, feature_flags. RLS on, policies in the same file.
create extension if not exists pgcrypto;

create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);
alter table public.organizations enable row level security;

create table if not exists public.org_members (
  org_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','editor','viewer')),
  created_at timestamptz not null default now(),
  primary key (org_id, user_id)
);
alter table public.org_members enable row level security;

create table if not exists public.feature_flags (
  key text primary key,
  enabled boolean not null default false
);
alter table public.feature_flags enable row level security;

-- helper: is the caller a member of the org?
create or replace function public.is_org_member(org uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.org_members m where m.org_id = org and m.user_id = auth.uid());
$$;

create policy "members read their orgs" on public.organizations
  for select using (public.is_org_member(id));
create policy "members read membership" on public.org_members
  for select using (public.is_org_member(org_id));
create policy "flags are readable" on public.feature_flags
  for select using (true);
