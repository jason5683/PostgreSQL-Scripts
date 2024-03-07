SELECT title, length, rating, replacement_cost, rental_rate
FROM film
WHERE length BETWEEN 60 AND 70 AND rating = 'G';

EXPLAIN ANALYSE SELECT title, length, rating, replacement_cost, rental_rate
FROM film
WHERE length BETWEEN 60 AND 70 AND rating = 'G';

CREATE INDEX idx_film_rating_length_cover ON film (rating,length,title,replacement_cost, rental_rate);

EXPLAIN ANALYSE SELECT title, length, rating, replacement_cost, rental_rate
FROM film
WHERE length BETWEEN 60 AND 70 AND rating = 'G';

DROP INDEX idx_film_rating_length_cover;