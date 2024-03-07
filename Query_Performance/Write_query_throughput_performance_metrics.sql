--Write_query_throughput_performance_metrics.sql

-- Rows inserted, updated, deleted by queries (per database)
SELECT datname, tup_inserted, tup_updated, tup_deleted FROM pg_stat_database;

-- Rows inserted, updated, deleted by queries (per table)
SELECT relname, n_tup_ins, n_tup_upd, n_tup_del FROM pg_stat_user_tables;

--Heap-only tuple (HOT) updates (per table)
SELECT relname, n_tup_hot_upd FROM pg_stat_user_tables;

-- Total commits and rollbacks across all databases
SELECT SUM(xact_commit) AS total_commits, SUM(xact_rollback) AS total_rollbacks FROM pg_stat_database;

