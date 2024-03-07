/*Catalog Views.sql */
/*https://www.postgresql.org/docs/14/monitoring-stats.html*/
select * from pg_catalog.pg_stat_user_tables;

select * from pg_catalog.pg_stat_user_indexes;

select * from pg_catalog.pg_statio_user_tables;

select * from pg_catalog.pg_statio_user_indexes;

select * from pg_catalog.pg_stat_database;

select * from pg_catalog.pg_stat_bgwriter;

select * from pg_catalog.pg_stat_activity;

select * from pg_catalog.pg_locks;

select * from pg_catalog.pg_settings;

select * from pg_catalog.pg_roles;