-- https://www.postgresql.org/docs/14/monitoring-stats.html#MONITORING-PG-STAT-ACTIVITY-VIEW
SELECT 
datname, 
usename, 
client_addr, 
client_port,
application_name, 
query 
FROM pg_stat_activity
WHERE backend_type = 'client backend'
AND state = 'active'
AND wait_event IS NOT NULL;

SELECT pg_stat_get_backend_pid(s.backendid) AS pid,
       pg_stat_get_backend_activity(s.backendid) AS query
    FROM (SELECT pg_stat_get_backend_idset() AS backendid) AS s;

SELECT pg_backend_pid ();

SELECT pg_stat_get_activity(16630); 