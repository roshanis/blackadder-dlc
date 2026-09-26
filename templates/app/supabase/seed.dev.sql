-- Local + preview only. Two tenants, three roles, fixed credentials the acceptance tests use.
-- Users are created through auth.users so RLS policies see real auth.uid() values.
-- password for all: "blackadder-dev"
insert into auth.users (id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data)
values
  ('00000000-0000-0000-0000-000000000001', 'alice@t1.test', crypt('blackadder-dev', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}'),
  ('00000000-0000-0000-0000-000000000002', 'bob@t1.test',   crypt('blackadder-dev', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}'),
  ('00000000-0000-0000-0000-000000000003', 'carol@t2.test', crypt('blackadder-dev', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}')
on conflict (id) do nothing;

insert into public.organizations (id, name) values
  ('10000000-0000-0000-0000-000000000001', 'Tenant One'),
  ('10000000-0000-0000-0000-000000000002', 'Tenant Two')
on conflict (id) do nothing;

insert into public.org_members (org_id, user_id, role) values
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'owner'),
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'viewer'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'owner')
on conflict do nothing;
