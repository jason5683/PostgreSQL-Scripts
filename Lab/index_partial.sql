SELECT title, length, rental_rate
FROM film
WHERE length = 50;

EXPLAIN ANALYSE SELECT title, length, rental_rate
FROM film
WHERE length = 50;

CREATE INDEX film_first ON film (length);

EXPLAIN ANALYSE SELECT title, length, rental_rate
FROM film
WHERE length = 50;

DROP INDEX film_first;

CREATE INDEX film_first_part ON film (length)
WHERE length < 60;

EXPLAIN ANALYSE SELECT title, length, rental_rate
FROM film
WHERE length = 50;

EXPLAIN ANALYSE SELECT title, length, rental_rate
FROM film
WHERE length = 70;

DROP INDEX film_first_part;