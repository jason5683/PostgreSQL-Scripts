-- create_user.sql

CREATE ROLE jlove;

Alter ROLE jlove WITH LOGIN PASSWORD 'Passsword123!' VALID UNTIL '2023-10-12 11:59:59';

ALTER ROLE jlove VALID UNTIL 'epoch';

ALTER ROLE jlove PASSWORD NULL;

-- Grant read access 
GRANT pg_read_all_data TO jlove;

-- DROP ROLE jlove;