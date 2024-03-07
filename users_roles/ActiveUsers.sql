SELECT "FirstName", "LastName"
FROM audit."activeUsers";


SELECT "FirstName", "LastName",
       LOWER(CONCAT(SUBSTRING("FirstName", 1, 1), '', "LastName")) AS "pgUserName"
FROM audit."activeUsers";


CREATE VIEW active_users AS
SELECT "FirstName", "LastName",
       LOWER(CONCAT(SUBSTRING("FirstName", 1, 1), '', "LastName")) AS "initials_and_lastname",
       '10/20/2023'::date AS "compile_date"
FROM audit."activeUsers"
order by 3;

select * from active_users;

SELECT "FirstName", "LastName",
       LOWER(CONCAT(SUBSTRING("FirstName", 1, 1), ' ', "LastName")) AS "initials_and_lastname",
       '10/20/2023'::date AS "compile_date"
FROM audit."activeUsers";