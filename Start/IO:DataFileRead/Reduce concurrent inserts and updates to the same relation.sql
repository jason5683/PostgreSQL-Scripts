/*Reduce concurrent inserts and updates to the same relation*/

/*First, determine whether there's an increase in tup_inserted and tup_updated metrics and an accompanying increase in this wait event. If so, check which relations are in high contention for insert and update operations. To determine this, query the pg_stat_all_tables view for the values in n_tup_ins and n_tup_upd fields. For information about the pg_stat_all_tables view, see pg_stat_all_tables in the PostgreSQL documentation.

To get more information about blocking and blocked queries, query pg_stat_activity as in the following example:*/

SELECT
    blocked.pid,
    blocked.usename,
    blocked.query,
    blocking.pid AS blocking_id,
    blocking.query AS blocking_query,
    blocking.wait_event AS blocking_wait_event,
    blocking.wait_event_type AS blocking_wait_event_type
FROM pg_stat_activity AS blocked
JOIN pg_stat_activity AS blocking ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
where
blocked.wait_event = 'extend'
and blocked.wait_event_type = 'Lock';
 
