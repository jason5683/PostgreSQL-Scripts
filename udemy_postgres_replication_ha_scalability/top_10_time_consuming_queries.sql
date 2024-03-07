SELECT round((100 * total_time / sum(total_time)                       
           OVER ())::numeric, 2) percent,                        
           round(total_time::numeric, 2) AS total,                  
           calls,                                                   
           round(mean_time::numeric, 2) AS mean,                    
           substring(query, 1, 200)                                  
 FROM  pg_stat_statements                                               
           ORDER BY total_time DESC                                               
           LIMIT 10;
           
          SELECT round((100 * total_exec_time / sum(total_exec_time)                       
           OVER ())::numeric, 2) percent,                        
           round(total_exec_time::numeric, 2) AS total,                  
           calls,                                                   
           round(mean_exec_time::numeric, 2) AS mean,                    
           substring(query, 1, 200)                                  
 FROM  pg_stat_statements                                               
           ORDER BY total_exec_time DESC                                               
           LIMIT 10;