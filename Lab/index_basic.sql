SELECT title, length
FROM film
WHERE length = 60;

EXPLAIN ANALYSE SELECT title, length
FROM film
WHERE length = 60;

CREATE INDEX idx_film_length ON film (length);

EXPLAIN ANALYSE SELECT title, length
FROM film
WHERE length = 60;

DROP INDEX idx_film_length; 
