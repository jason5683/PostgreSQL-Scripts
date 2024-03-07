SELECT title, length, rental_rate
FROM film
WHERE length = 60
ORDER BY rental_rate ASC;

EXPLAIN ANALYSE SELECT title, length, rental_rate
FROM film
WHERE length = 60
ORDER BY rental_rate DESC;

CREATE INDEX film_first ON film (length);

EXPLAIN ANALYSE SELECT title, length, rental_rate
FROM film
WHERE length = 60
ORDER BY rental_rate DESC;

CREATE INDEX film_second ON film (length, rental_rate DESC);

EXPLAIN ANALYSE SELECT title, length, rental_rate
FROM film
WHERE length = 60
ORDER BY rental_rate DESC;

CREATE INDEX film_third ON film (length, rental_rate DESC, title);

EXPLAIN ANALYSE SELECT title, length, rental_rate
FROM film
WHERE length = 60
ORDER BY rental_rate DESC;

DROP INDEX film_first;
DROP INDEX film_second;
DROP INDEX film_third;