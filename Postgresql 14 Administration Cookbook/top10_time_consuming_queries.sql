--top10_time_consuming_queries.sql


select
  inet_client_addr() AS ip_address,
  current_database() AS database,
  ROUND((100 * total_time / SUM(total_time) OVER ())::NUMERIC, 2) AS percent,
  ROUND(total_time::NUMERIC, 2) AS total,
  calls,
  ROUND(mean_time::NUMERIC, 2) AS mean,
  SUBSTRING(query, 1, 500) AS short_query,
  CURRENT_DATE
FROM
  pg_stat_statements
ORDER BY
  total_time DESC
LIMIT 10;


select
  inet_client_addr() AS ip_address,
  current_database() AS database,
  ROUND((100 * total_exec_time / SUM(total_exec_time) OVER ())::NUMERIC, 2) AS percent,
  ROUND(total_exec_time::NUMERIC, 2) AS total,
  calls,
  ROUND(mean_exec_time::NUMERIC, 2) AS mean,
  SUBSTRING(query, 1, 500) AS short_query
FROM
  pg_stat_statements
ORDER BY
  total_exec_time DESC
LIMIT 10;


select *
 FROM
  pg_stat_statements