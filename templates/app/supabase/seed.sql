-- Prod-safe reference data only (lookup tables, feature flags defaults). No fake users here.
insert into public.feature_flags (key, enabled) values ('example_flag', false)
on conflict (key) do nothing;
