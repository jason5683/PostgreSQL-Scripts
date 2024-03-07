--Drop all connections from a database
SELECT pg_terminate_backend (pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'hamshackradio';

DROP DATABASE  hamshackradio;