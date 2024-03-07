DROP TABLE SampleTable;

CREATE TABLE SampleTable
(
  id integer PRIMARY KEY, 
  firstcol character varying(40),
  secondcol integer
);

SELECT 
  idx.indrelid :: REGCLASS AS table_name,
  i.relname                AS index_name,
  idx.indisunique          AS is_unique,
  idx.indisprimary         AS is_primary
FROM pg_index AS idx
  JOIN pg_class AS i
    ON i.oid = idx.indexrelid
WHERE idx.indrelid = 'sampletable'::regclass;

CREATE INDEX idx_SampleTable_id ON SampleTable (id);

SELECT 
  idx.indrelid :: REGCLASS AS table_name,
  i.relname                AS index_name,
  idx.indisunique          AS is_unique,
  idx.indisprimary         AS is_primary
FROM pg_index AS idx
  JOIN pg_class AS i
    ON i.oid = idx.indexrelid
WHERE idx.indrelid = 'sampletable'::regclass;

ALTER TABLE sampletable
  ADD CONSTRAINT sampletable_firstcol UNIQUE (firstcol);

SELECT 
  idx.indrelid :: REGCLASS AS table_name,
  i.relname                AS index_name,
  idx.indisunique          AS is_unique,
  idx.indisprimary         AS is_primary
FROM pg_index AS idx
  JOIN pg_class AS i
    ON i.oid = idx.indexrelid
WHERE idx.indrelid = 'sampletable'::regclass;

CREATE UNIQUE INDEX unq_sampletable_firstcol
  ON sampletable (firstcol);

SELECT 
  idx.indrelid :: REGCLASS AS table_name,
  i.relname                AS index_name,
  idx.indisunique          AS is_unique,
  idx.indisprimary         AS is_primary
FROM pg_index AS idx
  JOIN pg_class AS i
    ON i.oid = idx.indexrelid
WHERE idx.indrelid = 'sampletable'::regclass;


