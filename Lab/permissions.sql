
-- Alter user jlove with password 'Jas282396':

CREATE USER jonathan;
Create a user with a password:

CREATE USER davide WITH PASSWORD 'jw8s0F4';
Create a user with a password that is valid until the end of 2004. After one second has ticked in 2005, the password is no longer valid.

CREATE USER miriam WITH PASSWORD 'jw8s0F4' VALID UNTIL '2005-01-01';
Create an account where the user can create databases:

CREATE USER manuel WITH PASSWORD 'jw8s0F4' CREATEDB;



GRANT pg_monitor,dbadmin,dbmaint,development,super to jlove;