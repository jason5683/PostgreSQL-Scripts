-- find_users.sql

SELECT usename
FROM pg_user;

SELECT DISTINCT usename
FROM pg_stat_activity;