--Reload Configuration File

SELECT 
name, 
setting, 
unit,
(source = 'default') AS is_default
FROM pg_settings
WHERE context = 'sighup'
AND (name LIKE '%delay' OR name LIKE '%timeout')
AND setting != '0'; 

SELECT pg_reload_conf();

