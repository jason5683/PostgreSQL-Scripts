-- no stats query
-- to display tables/columns which are without stats
-- so we can't estimate bloat
select
	table_schema,
	table_name,
	( pg_class.relpages = 0 ) as is_empty,
	( psut.relname is null
	or ( psut.last_analyze is null
	and psut.last_autoanalyze is null ) ) as never_analyzed,
	array_agg(column_name::text) as no_stats_columns
from
	information_schema.columns
join pg_class on
	columns.table_name = pg_class.relname
	and pg_class.relkind = 'r'
join pg_namespace on
	pg_class.relnamespace = pg_namespace.oid
	and nspname = table_schema
left outer join pg_stats
    on
	table_schema = pg_stats.schemaname
	and table_name = pg_stats.tablename
	and column_name = pg_stats.attname
left outer join pg_stat_user_tables as psut
        on
	table_schema = psut.schemaname
	and table_name = psut.relname
where
	pg_stats.attname is null
	and table_schema not in ('pg_catalog', 'information_schema')
	and ( pg_class.relpages = 0 ) != 'true'
group by
	table_schema,
	table_name,
	relpages,
	psut.relname,
	last_analyze,
	last_autoanalyze
order by
	table_schema,
	table_name;
