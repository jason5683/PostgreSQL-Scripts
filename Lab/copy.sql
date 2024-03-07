COPY film1 TO STDOUT (DELIMITER ',');

COPY film1 TO 'E:/Pluralsight/postgresql-index-tuning-performance-optimization/film.csv' (DELIMITER ',');

COPY film1 TO 'E:/Pluralsight/postgresql-index-tuning-performance-optimization/film.csv' CSV;

COPY film1 TO 'E:/Pluralsight/postgresql-index-tuning-performance-optimization/film.csv' CSV HEADER;

COPY (SELECT * FROM film1 WHERE length < 60) TO 'E:/Pluralsight/postgresql-index-tuning-performance-optimization/film.csv' CSV HEADER;

CREATE TABLE filmNew (
    film1_id integer  NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    release_year year,
    language_id smallint NOT NULL,
    rental_duration smallint DEFAULT 3 NOT NULL,
    rental_rate numeric(4,2) DEFAULT 4.99 NOT NULL,
    length smallint,
    replacement_cost numeric(5,2) DEFAULT 19.99 NOT NULL,
    rating mpaa_rating DEFAULT 'G'::mpaa_rating
);

COPY filmNew FROM 'E:/Pluralsight/postgresql-index-tuning-performance-optimization/film.csv' DELIMITERS ','

SELECT *
FROM filmnew;