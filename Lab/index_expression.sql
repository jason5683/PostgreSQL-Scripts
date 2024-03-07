SELECT *
FROM film
WHERE title = 'Arizona Bang';

SELECT *
FROM film
WHERE title = 'arizona bang';

SELECT *
FROM film
WHERE lower(title) = 'arizona bang';

EXPLAIN ANALYSE SELECT *
FROM film
WHERE title = 'Arizona Bang';

EXPLAIN ANALYSE SELECT *
FROM film
WHERE lower(title) = 'arizona bang';

CREATE INDEX film_title_search ON film (title);

EXPLAIN ANALYSE SELECT *
FROM film
WHERE title = 'Arizona Bang';

EXPLAIN ANALYSE SELECT *
FROM film
WHERE lower(title) = 'arizona bang';

CREATE INDEX film_title_search_lower ON film (lower(title));

EXPLAIN ANALYSE SELECT *
FROM film
WHERE title = 'Arizona Bang';

EXPLAIN ANALYSE SELECT *
FROM film
WHERE lower(title) = 'arizona bang';

DROP INDEX film_title_search;
DROP INDEX film_title_search_lower;