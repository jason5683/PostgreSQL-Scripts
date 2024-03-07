Postgres Commands

## Dead Tuples 

SELECT 
        relname AS TableName
        ,n_live_tup AS LiveTuples
        ,n_dead_tup AS DeadTuples
FROM pg_stat_user_tables;


## checking connection states

SELECT count(*), 
       state 
FROM pg_stat_activity 
GROUP BY 2;

## show client_addr
SELECT count(*), state, client_addr from pg_stat_activity group by 2,3;

SELECT count(*), 
       state,
       query 
FROM pg_stat_activity 
GROUP BY 2, 3;

SELECT pid, age(clock_timestamp(), query_start),  query 
FROM pg_stat_activity 
WHERE query = 'active' AND query ILIKE '%SELECT u0."user_id"%' 
ORDER BY query_start desc;

select state, query, wait_event, wait_event_type, count(*) from pg_stat_activity group by 1,2,3 order by query;
---
## replication lag

select now()-pg_last_xact_replay_timestamp() as replication_lag;

-----
## query count

select state, query, count(1) from pg_stat_activity  group by 1,2 order by 1,2;

-----

## Long running query

SELECT
  pid,
  now() - pg_stat_activity.query_start AS duration,
  query,
  state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';


--------------

## check for sequencial scan

SELECT schemaname, relname, seq_scan, seq_tup_read, idx_scan, seq_tup_read / seq_scan AS avg FROM pg_stat_user_tables
WHERE seq_scan > 0 ORDER BY idx_scan  DESC;


--Query to check bloated index for potential reindexing.
--------------------

-- Adapted from: https://github.com/ioguix/pgsql-bloat-estimation/blob/master/btree/btree_bloat-superuser.sql
--
-- This query must be exected by a superuser because it relies on the
-- pg_statistic table.

WITH idx_data AS (
  SELECT ci.relname AS idxname
       , ci.reltuples
       , ci.relpages
       , i.indrelid AS tbloid
       , i.indexrelid AS idxoid
       , co.conname as pkconname
       , coalesce(substring(
         array_to_string(ci.reloptions, ' ')
         FROM 'fillfactor=([0-9]+)')::smallint, 90) AS fillfactor
       , i.indnatts
       , string_to_array(textin(int2vectorout(i.indkey)),' ')::int[] AS indkey
  FROM pg_index i JOIN
       pg_class ci ON ci.oid=i.indexrelid LEFT JOIN
       pg_catalog.pg_constraint co ON co.conindid = i.indexrelid
  WHERE ci.relam=(SELECT oid FROM pg_am WHERE amname = 'btree')
    AND ci.relpages > 0
), idx_data_att_series AS (
  SELECT idxname
       , reltuples
       , relpages
       , tbloid
       , idxoid
       , pkconname
       , fillfactor
       , indkey
       , indnatts
       , generate_series(1, indnatts) AS i
  FROM idx_data
), i AS (
  SELECT idxname
       , reltuples
       , relpages
       , tbloid
       , idxoid
       , pkconname
       , fillfactor
       , CASE WHEN indkey[i]=0 THEN idxoid ELSE tbloid END AS att_rel
       , CASE WHEN indkey[i]=0 THEN i ELSE indkey[i] END AS att_pos
  FROM idx_data_att_series
), row_data_stats AS (
  SELECT n.nspname
       , ct.relname AS tblname
       , i.idxname
       , i.reltuples
       , i.relpages
       , i.idxoid
       , i.pkconname
       , i.fillfactor
       , current_setting('block_size')::numeric AS bs
       , CASE -- MAXALIGN: 4 on 32bits, 8 on 64bits (and mingw32 ?)
         WHEN version() ~ 'mingw32' OR version() ~ '64-bit|x86_64|ppc64|ia64|amd64' THEN 8
         ELSE 4
         END AS maxalign
       /* per page header, fixed size: 20 for 7.X, 24 for others */
       , 24 AS pagehdr
       /* per page btree opaque data */
       , 16 AS pageopqdata
       /* per tuple header: add IndexAttributeBitMapData if some cols are null-able */
       , CASE
         WHEN max(coalesce(s.stanullfrac,0)) = 0 THEN 2 -- IndexTupleData size
         ELSE 2 + (( 32 + 8 - 1 ) / 8) -- IndexTupleData size + IndexAttributeBitMapData size ( max num filed per index + 8 - 1 /8)
         END AS index_tuple_hdr_bm
       /* data len: we remove null values save space using it fractionnal part from stats */
       , sum( (1-coalesce(s.stanullfrac, 0)) * coalesce(s.stawidth, 1024)) AS nulldatawidth
       , max( CASE WHEN a.atttypid = 'pg_catalog.name'::regtype THEN 1 ELSE 0 END ) > 0 AS is_na
  FROM i
  JOIN pg_attribute a ON a.attrelid = i.att_rel AND a.attnum = i.att_pos
  JOIN pg_statistic s ON s.starelid = i.att_rel AND s.staattnum = i.att_pos
  JOIN pg_class ct ON ct.oid = i.tbloid
  JOIN pg_namespace n ON ct.relnamespace = n.oid
  GROUP BY 1,2,3,4,5,6,7,8,9,10
), rows_hdr_pdg_stats AS (
  SELECT maxalign
       , bs
       , nspname
       , tblname
       , idxname
       , reltuples
       , relpages
       , idxoid
       , pkconname
       , fillfactor
       , ( index_tuple_hdr_bm +
           maxalign - CASE -- Add padding to the index tuple header to align on MAXALIGN
                      WHEN index_tuple_hdr_bm%maxalign = 0 THEN maxalign
                      ELSE index_tuple_hdr_bm%maxalign
                      END
          + nulldatawidth
          + maxalign - CASE -- Add padding to the data to align on MAXALIGN
                       WHEN nulldatawidth = 0 THEN 0
                       WHEN nulldatawidth::integer%maxalign = 0 THEN maxalign
                       ELSE nulldatawidth::integer%maxalign
                       END
         )::numeric AS nulldatahdrwidth
       , pagehdr
       , pageopqdata
       , is_na
       -- DEBUG INFO
       -- , index_tuple_hdr_bm
       -- , nulldatawidth
 FROM row_data_stats
), relation_stats AS (
  SELECT coalesce(
           -- ItemIdData size + computed avg size of a tuple (nulldatahdrwidth)
           1 + ceil(
             reltuples / floor(
               (bs-pageopqdata-pagehdr) / (4+nulldatahdrwidth)::float
             )
           )
         , 0
         ) AS est_pages
       , coalesce(
           1 + ceil(
             reltuples / floor(
                 (bs-pageopqdata-pagehdr)
               * fillfactor / (100*(4+nulldatahdrwidth)::float)
             )
           )
         , 0
         ) AS est_pages_ff
       , bs
       , nspname
       , tblname
       , idxoid
       , idxname
       , pkconname
       , relpages
       , fillfactor
       , is_na
       -- DEBUG INFO
       -- , pgstatindex(idxoid) AS pst
       -- , index_tuple_hdr_bm
       -- , maxalign
       -- , pagehdr
       -- , nulldatawidth
       -- , nulldatahdrwidth
       -- , reltuples
  FROM rows_hdr_pdg_stats
), index_bloat AS (
  SELECT nspname
       , tblname
       , idxoid
       , idxname
       , pkconname
       , CASE WHEN relpages > est_pages_ff
         THEN bs*(relpages-est_pages_ff)
         ELSE 0
         END AS bloat_size
       , ROUND(100 * (relpages-est_pages_ff)::float / relpages) AS bloat_ratio
    -- , 100-(pst).avg_leaf_density AS pst_avg_bloat, est_pages, index_tuple_hdr_bm, maxalign, pagehdr, nulldatawidth, nulldatahdrwidth, reltuples, relpages -- (DEBUG INFO)
  FROM relation_stats
  WHERE nspname != 'pg_catalog'
  ORDER BY bloat_size DESC
)
SELECT idxoid
     , current_database()   AS datname
     , quote_ident(nspname) AS schemaname
     , quote_ident(tblname) AS tblname
     , quote_ident(idxname) AS idxname
--    'REINDEX INDEX CONCURRENTLY '
--    || quote_ident(nspname)
--    || '.'
--    || quote_ident(idxname)
--    || ';' AS reindex_cmd
     , pg_size_pretty(bloat_size::numeric) AS bloat_size
     , bloat_ratio
FROM index_bloat
WHERE bloat_size::numeric > 1024 * 1024
ORDER BY bloat_size::numeric ASC
;



## Five 5 biggest TABLES

SELECT
    relname AS "relation",
    pg_size_pretty (
        pg_total_relation_size (C .oid)
    ) AS "total_size"
FROM
    pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C .relnamespace)
WHERE
    nspname NOT IN (
        'pg_catalog',
        'information_schema'
    )
AND C .relkind <> 'i'
AND nspname !~ '^pg_toast'
ORDER BY
    pg_total_relation_size (C .oid) DESC
LIMIT 5;


## Search particular index

SELECT
    tablename,
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    indexname LIKE 'index_9%'
ORDER BY
    tablename,
    indexname;

--------------------------------

## CHECK Index Size

select relname as table_name,
       pg_size_pretty(pg_indexes_size(relid)) as index_size
from pg_catalog.pg_statio_user_tables;


-------------------------------------
## Sequence status check -- this is important because if sequences are maxed out postgres DB crashes
-------------------------------------

WITH
  sequences_manual AS

  (

    SELECT

      table_schema                      AS schema_name,

      table_schema || '.' || table_name AS table_name,

      column_name,

      data_type,

      udt_name,

      ( CASE WHEN udt_name = 'int4' then          2147483647.00

             WHEN udt_name = 'int8' then 9223372036690727166.00

        END

      ) AS max_value,

      substring( column_default FROM '''(.+)''' ) AS sequence_name

    FROM

      information_schema.columns

    WHERE

      column_default LIKE ('nextval%')

      AND table_schema = 'public'

    ORDER BY

      table_name,

      column_name,

      data_type,

      udt_name,

      sequence_name

  )

SELECT

  M.sequence_name                                         AS "sequence_name",

  M.table_name                                            AS "table_name",

  M.data_type                                             AS "data_type",

--M.udt_name                                              AS "udt_name",

  PGSEQ.last_value                                        AS "last_value",

  ROUND( ( PGSEQ.last_value / M.max_value ) * 100.00, 3 ) AS "used_percent"

FROM

  pg_sequences PGSEQ

  JOIN sequences_manual M on M.sequence_name = PGSEQ.sequencename

WHERE

  PGSEQ.last_value IS NOT NULL

  AND M.data_type = 'integer'

ORDER BY

  used_percent DESC

;



--------------------------------------


## Greater than 30% index bloat script
======================================



-- Adapted from: https://github.com/ioguix/pgsql-bloat-estimation/blob/master/btree/btree_bloat-superuser.sql
--
-- This query must be exected by a superuser because it relies on the
-- pg_statistic table.
WITH idx_data AS (
  SELECT ci.relname AS idxname
       , ci.reltuples
       , ci.relpages
       , i.indrelid AS tbloid
       , i.indexrelid AS idxoid
       , co.conname as pkconname
       , coalesce(substring(
         array_to_string(ci.reloptions, ' ')
         FROM 'fillfactor=([0-9]+)')::smallint, 90) AS fillfactor
       , i.indnatts
       , string_to_array(textin(int2vectorout(i.indkey)),' ')::int[] AS indkey
  FROM pg_index i JOIN
       pg_class ci ON ci.oid=i.indexrelid LEFT JOIN
       pg_catalog.pg_constraint co ON co.conindid = i.indexrelid
  WHERE ci.relam=(SELECT oid FROM pg_am WHERE amname = 'btree')
    AND ci.relpages > 0
), idx_data_att_series AS (
  SELECT idxname
       , reltuples
       , relpages
       , tbloid
       , idxoid
       , pkconname
       , fillfactor
       , indkey
       , indnatts
       , generate_series(1, indnatts) AS i
  FROM idx_data
), i AS (
  SELECT idxname
       , reltuples
       , relpages
       , tbloid
       , idxoid
       , pkconname
       , fillfactor
       , CASE WHEN indkey[i]=0 THEN idxoid ELSE tbloid END AS att_rel
       , CASE WHEN indkey[i]=0 THEN i ELSE indkey[i] END AS att_pos
  FROM idx_data_att_series
), row_data_stats AS (
  SELECT n.nspname
       , ct.relname AS tblname
       , i.idxname
       , i.reltuples
       , i.relpages
       , i.idxoid
       , i.pkconname
       , i.fillfactor
       , current_setting('block_size')::numeric AS bs
       , CASE -- MAXALIGN: 4 on 32bits, 8 on 64bits (and mingw32 ?)
         WHEN version() ~ 'mingw32' OR version() ~ '64-bit|x86_64|ppc64|ia64|amd64' THEN 8
         ELSE 4
         END AS maxalign
       /* per page header, fixed size: 20 for 7.X, 24 for others */
       , 24 AS pagehdr
       /* per page btree opaque data */
       , 16 AS pageopqdata
       /* per tuple header: add IndexAttributeBitMapData if some cols are null-able */
       , CASE
         WHEN max(coalesce(s.stanullfrac,0)) = 0 THEN 2 -- IndexTupleData size
         ELSE 2 + (( 32 + 8 - 1 ) / 8) -- IndexTupleData size + IndexAttributeBitMapData size ( max num filed per index + 8 - 1 /8)
         END AS index_tuple_hdr_bm
       /* data len: we remove null values save space using it fractionnal part from stats */
       , sum( (1-coalesce(s.stanullfrac, 0)) * coalesce(s.stawidth, 1024)) AS nulldatawidth
       , max( CASE WHEN a.atttypid = 'pg_catalog.name'::regtype THEN 1 ELSE 0 END ) > 0 AS is_na
  FROM i
  JOIN pg_attribute a ON a.attrelid = i.att_rel AND a.attnum = i.att_pos
  JOIN pg_statistic s ON s.starelid = i.att_rel AND s.staattnum = i.att_pos
  JOIN pg_class ct ON ct.oid = i.tbloid
  JOIN pg_namespace n ON ct.relnamespace = n.oid
  GROUP BY 1,2,3,4,5,6,7,8,9,10
), rows_hdr_pdg_stats AS (
  SELECT maxalign
       , bs
       , nspname
       , tblname
       , idxname
       , reltuples
       , relpages
       , idxoid
       , pkconname
       , fillfactor
       , ( index_tuple_hdr_bm +
           maxalign - CASE -- Add padding to the index tuple header to align on MAXALIGN
                      WHEN index_tuple_hdr_bm%maxalign = 0 THEN maxalign
                      ELSE index_tuple_hdr_bm%maxalign
                      END
          + nulldatawidth
          + maxalign - CASE -- Add padding to the data to align on MAXALIGN
                       WHEN nulldatawidth = 0 THEN 0
                       WHEN nulldatawidth::integer%maxalign = 0 THEN maxalign
                       ELSE nulldatawidth::integer%maxalign
                       END
         )::numeric AS nulldatahdrwidth
       , pagehdr
       , pageopqdata
       , is_na
       -- DEBUG INFO
       -- , index_tuple_hdr_bm
       -- , nulldatawidth
 FROM row_data_stats
), relation_stats AS (
  SELECT coalesce(
           -- ItemIdData size + computed avg size of a tuple (nulldatahdrwidth)
           1 + ceil(
             reltuples / floor(
               (bs-pageopqdata-pagehdr) / (4+nulldatahdrwidth)::float
             )
           )
         , 0
         ) AS est_pages
       , coalesce(
           1 + ceil(
             reltuples / floor(
                 (bs-pageopqdata-pagehdr)
fillfactor / (100*(4+nulldatahdrwidth)::float)
             )
           )
         , 0
         ) AS est_pages_ff
       , bs
       , nspname
       , tblname
       , idxoid
       , idxname
       , pkconname
       , relpages
       , fillfactor
       , is_na
       -- DEBUG INFO
       -- , pgstatindex(idxoid) AS pst
       -- , index_tuple_hdr_bm
       -- , maxalign
       -- , pagehdr
       -- , nulldatawidth
       -- , nulldatahdrwidth
       -- , reltuples
  FROM rows_hdr_pdg_stats
), index_bloat AS (
  SELECT nspname
       , tblname
       , idxoid
       , idxname
       , pkconname
       , CASE WHEN relpages > est_pages_ff
         THEN bs*(relpages-est_pages_ff)
         ELSE 0
         END AS bloat_size
       , ROUND(100 * (relpages-est_pages_ff)::float / relpages) AS bloat_ratio
    -- , 100-(pst).avg_leaf_density AS pst_avg_bloat, est_pages, index_tuple_hdr_bm, maxalign, pagehdr, nulldatawidth, nulldatahdrwidth, reltuples, relpages -- (DEBUG INFO)
     , 'reindex_' ||  md5(random()::TEXT) AS tmp_index_name
  FROM relation_stats
  WHERE nspname != 'pg_catalog'
  ORDER BY bloat_size DESC
)
SELECT idxoid
     , current_database()   AS datname
     , quote_ident(nspname) AS schemaname
     , quote_ident(tblname) AS tblname
     , quote_ident(idxname) AS idxname
     , bloat_size
     , bloat_ratio
--   , tmp_index_name
--   , REGEXP_REPLACE(pg_catalog.pg_get_indexdef(idxoid), 'INDEX .+? ON', 'INDEX CONCURRENTLY ' ||  tmp_index_name || ' ON') AS reindex_query
--   , pkconname
FROM index_bloat
WHERE bloat_ratio >= 30
;
