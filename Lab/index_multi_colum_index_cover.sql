SELECT title, length, rating, replacement_cost, rental_rate
FROM film
WHERE length BETWEEN 60 AND 70 AND rating = 'G';

EXPLAIN ANALYSE SELECT title, length, rating, replacement_cost, rental_rate
FROM film
WHERE length BETWEEN 60 AND 70 AND rating = 'G';

CREATE INDEX idx_film_length ON film (length);

EXPLAIN ANALYSE SELECT title, length, rating, replacement_cost, rental_rate
FROM film
WHERE length BETWEEN 60 AND 70 AND rating = 'G';

CREATE INDEX idx_film_length ON film (length,rating);

EXPLAIN ANALYSE SELECT title, length, rating, replacement_cost, rental_rate
FROM film
WHERE length BETWEEN 60 AND 70 AND rating = 'G';

CREATE INDEX idx_film_rating_length ON film (rating,length);

EXPLAIN ANALYSE SELECT title, length, rating, replacement_cost, rental_rate
FROM film
WHERE length BETWEEN 60 AND 70 AND rating = 'G';

CREATE INDEX idx_film_rating_length_cover ON film (rating,length,title,replacement_cost,rental_rate);

EXPLAIN ANALYSE SELECT title, length, rating, replacement_cost, rental_rate
FROM film
WHERE length BETWEEN 60 AND 70 AND rating = 'G';


-- Example of REINDEX
REINDEX INDEX idx_film_rating_length_cover;
REINDEX TABLE film;

DROP INDEX idx_film_length; 
DROP INDEX idx_film_length_rating;
DROP INDEX idx_film_rating_length; 
DROP INDEX idx_film_rating_length_cover;