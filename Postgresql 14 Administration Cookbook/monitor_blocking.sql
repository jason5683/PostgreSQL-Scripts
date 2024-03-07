--SET ROLE SUPER;

--Monitor Blocking
SELECT psa.datname, psa.usename, psa.wait_event_type, psa.wait_event,psa.backend_type,
query
FROM pg_stat_activity psa
WHERE psa.wait_event_type IS NOT NULL
AND psa.wait_event_type NOT IN ('Activity', 'Client');

--Who or what is blocking
SELECT 
psa.datname, 
psa.usename, 
psa.wait_event_type, 
psa.wait_event,
pg_blocking_pids(PID) AS blocked_by,
psa.backend_type, 
query
FROM pg_stat_activity psa
WHERE psa.wait_event_type IS NOT NULL
AND psa.wait_event_type NOT IN ('Activity', 'Client');

-- pg_cancel_backend(pid)
-- pg_terminate_backend(pid)
-- 
