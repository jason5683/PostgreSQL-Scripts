SELECT
  inet_client_addr() AS ip_address,
  current_database() AS database,
  n.nspname AS schema_name,
  c.relname AS table_name,
  i.relname AS index_name,
  CASE
      WHEN am.amname = 'btree' THEN 'B-tree'
      ELSE am.amname
  END AS index_type,
  CASE
      WHEN con.contype = 'p' THEN 'Primary Key'
      WHEN con.contype = 'u' THEN 'Unique Constraint'
      ELSE 'Index'
  END AS constraint_type,
  STRING_AGG(a.attname, ', ') AS column_names,
  pg_size_pretty(pg_relation_size(c.oid)) AS table_size,
  pg_size_pretty(pg_relation_size(i.oid)) AS index_size,
  c.reltuples AS estimated_row_count,
  current_timestamp 
FROM
  pg_class c
JOIN
  pg_namespace n ON c.relnamespace = n.oid
JOIN
  pg_index ix ON c.oid = ix.indrelid
JOIN
  pg_class i ON ix.indexrelid = i.oid
JOIN
  pg_am am ON i.relam = am.oid
LEFT JOIN
  pg_constraint con ON (con.conindid = ix.indexrelid)
LEFT JOIN
  pg_attribute a ON a.attnum = ANY(ix.indkey) AND a.attrelid = c.oid
WHERE
  c.relkind = 'r' -- Filter for tables
GROUP BY
  schema_name,
  table_name,
  index_name,
  index_type,
  constraint_type,
  c.oid,
  i.oid,
  c.reltuples
ORDER BY
  schema_name,
  table_name,
  index_name;
