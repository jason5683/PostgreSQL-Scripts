--Schema
SELECT current_schema;

CREATE ROLE Chapo LOGIN SUPERUSER;

CREATE SCHEMA finance; 

--Set search_path
ALTER ROLE Chapo SET SEARCH_PATH = finance;

-- 
REVOKE ALL ON SCHEMA finance FROM public;
GRANT ALL ON SCHEMA Finance TO Chapo;