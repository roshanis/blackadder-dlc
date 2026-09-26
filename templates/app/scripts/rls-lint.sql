-- Fails if any table in the public schema lacks RLS or has zero policies.
DO $$
DECLARE
  bad text;
BEGIN
  SELECT string_agg(format('%I (rls=%s, policies=%s)', c.relname, c.relrowsecurity, p.n), ', ')
  INTO bad
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  LEFT JOIN (
    SELECT tablename, count(*) AS n FROM pg_policies WHERE schemaname = 'public' GROUP BY tablename
  ) p ON p.tablename = c.relname
  WHERE n.nspname = 'public' AND c.relkind = 'r'
    AND (c.relrowsecurity = false OR coalesce(p.n, 0) = 0);
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION 'RLS lint failed: %', bad;
  END IF;
END $$;
