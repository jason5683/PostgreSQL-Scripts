SELECT *
FROM pg_stat_database;

SELECT *
FROM pg_stat_all_tables;

SELECT *
FROM pg_stat_all_indexes;

SELECT *
FROM pg_stat_progress_analyze pspa;

SELECT *
FROM pg_stat_progress_vacuum pspv;

SELECT *
FROM pg_stat_progress_cluster;

SELECT *
FROM pg_stat_progress_create_index pspci;

SELECT *
FROM pg_stat_progress_basebackup pspb;

SELECT *
FROM pg_stat_progress_copy pspc;

SELECT pid, phase,
100.0* ((backup_streamed*1.0)/backup_total) As "progress%"
FROM pg_stat_ progress_basebackup;

--Although copY doesn't show the phase, we can calculate the % progress like this:
--COPY FROM % progress will be as follows:
SELECT (SELECT relname FROM pg_class WHERE oid = relid),
100.0* ((bytes_processed*1.0)/bytes_total) As "progress%"
FROM pg_stat_progress_copy;

--COPY TO % progress will be as follows:
SELECT relname,
100.0* ((tuples_processed*1.0)/(case reltuples WHEN O THEN 10 WHEN -1 THEN 10 ELSE reltuples
END))
As "progress%"
FROM Pg_stat_progress_copy JOIN pg_class on oid = relid;

