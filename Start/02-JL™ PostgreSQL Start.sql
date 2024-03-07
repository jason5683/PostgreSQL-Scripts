
/* SHOW server_version,
   SHOW server_version_num
 */ 
SELECT 
current_database() as db,
current_user as user,
inet_server_addr() as ip, 
inet_server_port() port,
version() version,
date_trunc('second', current_timestamp - pg_postmaster_start_time()) as uptime
--pg_postmaster_start_time() as start_time 



