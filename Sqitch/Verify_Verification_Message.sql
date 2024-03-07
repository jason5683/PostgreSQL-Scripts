--Verify Script with passed verification

DO $$ 
DECLARE 
    row_count INTEGER;
BEGIN
    -- Verify the row count in the table for this change set
    SELECT COUNT(*) INTO row_count FROM pmap.pmapuserrole;
    IF row_count != 192924 THEN
        RAISE EXCEPTION 'Verification failed: Expected different outcome and found %', row_count;
    END IF;

    -- If we reached here, verification passed
    RAISE INFO 'Verification succeeded: Table contains the expected number of rows.';
END $$;


