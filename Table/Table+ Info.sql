--set role = super;

SELECT 
  inet_client_addr() AS ip_address,
  current_database() as db_name,
  n.nspname AS schema_name,
  c.relname AS table_name,
  c.reltuples AS row_count,
  pg_size_pretty(pg_total_relation_size(n.nspname || '.' || c.relname)) AS total_size,
  pg_size_pretty(pg_total_relation_size(n.nspname || '.' || c.relname) - 
  pg_relation_size(n.nspname || '.' || c.relname)) AS data_size,
  pg_size_pretty(pg_relation_size(n.nspname || '.' || c.relname)) AS index_size,
  CURRENT_TIMESTAMP
FROM pg_class c
LEFT JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE c.relkind = 'r' -- Filter to only get tables (excluding indexes, etc.)
ORDER BY n.nspname, c.relname;

