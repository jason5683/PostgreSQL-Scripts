
SELECT 
  
  nspname AS schema_name,
  relname AS table_name,
  pg_size_pretty(pg_total_relation_size(pg_class.oid)) AS total_size,
  pg_size_pretty(pg_total_relation_size(pg_class.oid) - pg_relation_size(pg_class.oid)) AS data_size,
  pg_size_pretty(pg_relation_size(pg_class.oid)) AS index_size,
  reltuples AS row_count,
  CURRENT_DATE AS current_date
FROM pg_class
INNER JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
WHERE relkind = 'r' -- Filter to only get tables (excluding indexes, etc.)
ORDER BY schema_name, table_name;
