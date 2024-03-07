SELECT 
    inet_client_addr() AS ip_address,
    n.nspname || '.' || ct.relname AS "table", 
    ci.relname AS "dup index",
    pg_get_indexdef(i.indexrelid) AS "dup index definition", 
    i.indkey AS "dup index attributes",
    cii.relname AS "encompassing index", 
    pg_get_indexdef(ii.indexrelid) AS "encompassing index definition",
    ii.indkey AS "enc index attributes",
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS "dup index size",
    pg_size_pretty(pg_relation_size(ii.indexrelid)) AS "enc index size"
FROM 
    pg_index i
    JOIN pg_class ct ON i.indrelid = ct.oid
    JOIN pg_class ci ON i.indexrelid = ci.oid
    JOIN pg_namespace n ON ci.relnamespace = n.oid  -- Changed alias to 'n' for clarity
    JOIN pg_index ii ON ii.indrelid = i.indrelid 
                      AND ii.indexrelid != i.indexrelid 
                      AND (array_to_string(ii.indkey, ' ') || ' ') LIKE (array_to_string(i.indkey, ' ') || ' %')
                      AND (array_to_string(ii.indcollation, ' ') || ' ') LIKE (array_to_string(i.indcollation, ' ') || ' %')
                      AND (array_to_string(ii.indclass, ' ') || ' ') LIKE (array_to_string(i.indclass, ' ') || ' %')
                      AND (array_to_string(ii.indoption, ' ') || ' ') LIKE (array_to_string(i.indoption, ' ') || ' %')
                      AND NOT (ii.indkey::integer[] @> ARRAY[0])
                      AND NOT (i.indkey::integer[] @> ARRAY[0])
                      AND i.indpred IS NULL 
                      AND ii.indpred IS NULL 
                      AND (i.indisunique AND ii.indisunique AND array_to_string(ii.indkey, ' ') = array_to_string(i.indkey, ' ') OR NOT i.indisunique)
    JOIN pg_class ctii ON ii.indrelid = ctii.oid
    JOIN pg_class cii ON ii.indexrelid = cii.oid
WHERE 
    ct.relname NOT LIKE 'pg_%'
    AND NOT i.indisprimary
ORDER BY 
    1, 2, 3;
