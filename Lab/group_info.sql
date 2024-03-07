SELECT  datname, array(select privs from unnest(ARRAY[
( CASE WHEN has_database_privilege(c.oid,'CONNECT') THEN 'CONNECT' ELSE NULL END),
(CASE WHEN has_database_privilege(c.oid,'CREATE') THEN 'CREATE' ELSE NULL END),
(CASE WHEN has_database_privilege(c.oid,'TEMPORARY') THEN 'TEMPORARY' ELSE NULL END),
(CASE WHEN has_database_privilege(c.oid,'TEMP') THEN 'CONNECT' ELSE NULL END)])foo(privs) WHERE privs IS NOT NULL) FROM pg_database c WHERE 
has_database_privilege(c.oid,'CONNECT,CREATE,TEMPORARY,TEMP') AND datname not in ('template0');