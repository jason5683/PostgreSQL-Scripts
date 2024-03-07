SELECT *
FROM film;

EXPLAIN SELECT *
FROM film;

-- "Seq Scan on film  (cost=0.00..64.00 rows=1000 width=384)"
-- COST (disk pages read * seq_page_cost) + (rows scanned * cpu_tuple_cost)

SELECT relpages AS "Disk Page Read", reltuples AS "Rows Scanned"
FROM pg_class 
WHERE relname = 'film';

-- Planner Cost Constants
-- seq_page_cost = estimate of the cost of a disk page fetch. Default = 1
-- cpu_tuple_cost = estimate of the cost of processing each row. Default = 0.01

-- COST (disk pages read * seq_page_cost) + (rows scanned * cpu_tuple_cost)
-- COST (54              * 1.0)           + (1000         * 0.01)
-- COST (54) + (10) = 64

EXPLAIN SELECT *
FROM film
WHERE film_id > 40;

EXPLAIN SELECT *
FROM film
WHERE film_id < 40;

EXPLAIN SELECT *
FROM film
WHERE film_id > 40 AND rating = 'PG-13';

EXPLAIN SELECT *
FROM film
WHERE film_id < 40 AND rating = 'PG-13';
