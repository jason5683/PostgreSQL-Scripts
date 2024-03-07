
--Number of index scans (per index and per table)
SELECT indexrelname, relname, idx_scan FROM pg_stat_user_indexes;

--Number of sequential scans (per table)
SELECT relname, seq_scan FROM pg_stat_user_tables;

-- Rows fetched by queries (per database)
SELECT datname, tup_fetched FROM pg_stat_database;

-- Rows returned by queries (per database)
SELECT datname, tup_returned FROM pg_stat_database; 

--Bytes written temporarily to disk to execute queries (per database)*
SELECT datname, temp_bytes FROM pg_stat_database;

