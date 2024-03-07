--SELECT *
--FROM pg_stat_all_tables;

--SELECT pg_stat_all_tables.relname, 
--relnamespace::regnamespace AS schema, relowner::regrole AS owner, seq_scan, 
--seq_tup_read, idx_scan, idx_tup_fetch, n_tup_ins, n_tup_upd, n_tup_del, n_live_tup, n_dead_tup, vacuum_count, analyze_count
--FROM pg_stat_all_tables
--INNER JOIN pg_class 
--ON pg_stat_all_tables.relid = pg_class.oid
--WHERE pg_stat_all_tables.relname != 'mytable';


SELECT 
inet_server_addr() as ip, 
current_database() as db,
relnamespace::regnamespace AS schema, 
pg_stat_all_tables.relname,
relowner::regrole AS owner, 
seq_scan AS seq_scan_full_table_scans, -- The number of sequential scans (full table scans) performed on the table.
seq_tup_read AS seq_tup_read_rows_read_seq_scan, -- The number of tuples (rows) read during sequential scans of the table.
idx_scan AS index_scans, -- The number of index scans performed on the table.
idx_tup_fetch AS index_scan_rows, --The number of tuples (rows) fetched during index scans of the table.
n_tup_ins AS rows_inserted, --The number of tuples (rows) inserted into the table.
n_tup_upd AS rows_updated, -- The number of tuples (rows) updated in the table.
n_tup_del AS rows_deleted,  --The number of tuples (rows) deleted from the table. 
n_tup_hot_upd AS rows_updated_in_place,  -- The number of tuples (rows) that were updated in-place in the table.
n_live_tup AS estimated_live_tuples, --The estimated number of live (not deleted) tuples in the table.
n_dead_tup AS estimated_dead_tuples, -- The estimated number of dead (deleted) tuples in the table.
vacuum_count, --The number of times the table has been vacuumed.
autovacuum_count, --The number of times the table has been vacuumed automatically by the system.
analyze_count, --The number of times the table has been analyzed.
autoanalyze_count, --The number of times the table has been analyzed automatically by the system.
last_vacuum,
last_autovacuum,
last_analyze,
last_autoanalyze,
CURRENT_TIMESTAMP
FROM pg_stat_all_tables
INNER JOIN pg_class ON pg_stat_all_tables.relid = pg_class.oid
INNER JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
WHERE pg_namespace.nspname NOT LIKE 'pg_%' 
AND pg_namespace.nspname != 'information_schema' 
AND pg_stat_all_tables.schemaname NOT LIKE 'pg_%' 
AND pg_stat_all_tables.schemaname != 'information_schema'
ORDER BY n_dead_tup desc;
