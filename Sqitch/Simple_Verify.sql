-- sqitch verify
DO $$ 
DECLARE 
    row_count INTEGER;
BEGIN
    -- Verify the row count in the table for this change set
    SELECT COUNT(*) INTO row_count FROM client.labeltype;
    ASSERT row_count = 1, 'Verification failed: Expected different outcome and found ' || row_count;
END $$;