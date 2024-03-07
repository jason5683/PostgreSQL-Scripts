/*Find tables that are eligible to be autovacuumed*/
/*This query shows tables that need vacuuming and are eligible candidates.
  The following query lists all tables that are due to be processed by autovacuum. 
  During normal operation, this query should return very little. */
WITH  vbt AS (SELECT setting AS autovacuum_vacuum_threshold 
              FROM pg_settings WHERE name = 'autovacuum_vacuum_threshold')
    , vsf AS (SELECT setting AS autovacuum_vacuum_scale_factor 
              FROM pg_settings WHERE name = 'autovacuum_vacuum_scale_factor')
    , fma AS (SELECT setting AS autovacuum_freeze_max_age 
              FROM pg_settings WHERE name = 'autovacuum_freeze_max_age')
    , sto AS (SELECT opt_oid, split_part(setting, '=', 1) as param, 
                split_part(setting, '=', 2) as value 
              FROM (SELECT oid opt_oid, unnest(reloptions) setting FROM pg_class) opt)
SELECT
    '"'||ns.nspname||'"."'||c.relname||'"' as relation
    , pg_size_pretty(pg_table_size(c.oid)) as table_size
    , age(relfrozenxid) as xid_age
    , coalesce(cfma.value::float, autovacuum_freeze_max_age::float) autovacuum_freeze_max_age
    , (coalesce(cvbt.value::float, autovacuum_vacuum_threshold::float) + 
         coalesce(cvsf.value::float,autovacuum_vacuum_scale_factor::float) * c.reltuples) 
         as autovacuum_vacuum_tuples
    , n_dead_tup as dead_tuples
FROM pg_class c 
JOIN pg_namespace ns ON ns.oid = c.relnamespace
JOIN pg_stat_all_tables stat ON stat.relid = c.oid
JOIN vbt on (1=1) 
JOIN vsf ON (1=1) 
JOIN fma on (1=1)
LEFT JOIN sto cvbt ON cvbt.param = 'autovacuum_vacuum_threshold' AND c.oid = cvbt.opt_oid
LEFT JOIN sto cvsf ON cvsf.param = 'autovacuum_vacuum_scale_factor' AND c.oid = cvsf.opt_oid
LEFT JOIN sto cfma ON cfma.param = 'autovacuum_freeze_max_age' AND c.oid = cfma.opt_oid
WHERE c.relkind = 'r' 
AND nspname <> 'pg_catalog'
AND (
    age(relfrozenxid) >= coalesce(cfma.value::float, autovacuum_freeze_max_age::float)
    or
    coalesce(cvbt.value::float, autovacuum_vacuum_threshold::float) + 
      coalesce(cvsf.value::float,autovacuum_vacuum_scale_factor::float) * c.reltuples <= n_dead_tup
    -- or 1 = 1
)
ORDER BY age(relfrozenxid) DESC;