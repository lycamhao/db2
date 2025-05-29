CREATE PROCEDURE STATISTICS_TRANSPORT_TRAFFIC()
LANGUAGE SQL
BEGIN
    -- Declare variables to hold statistics
    DECLARE v_total_sent BIGINT DEFAULT 0;
    DECLARE v_total_received BIGINT DEFAULT 0;
    DECLARE v_start_time TIMESTAMP DEFAULT CURRENT TIMESTAMP;
    DECLARE v_end_time TIMESTAMP DEFAULT CURRENT TIMESTAMP;

    -- Get the start and end time for the monitoring
    SET v_start_time = CURRENT TIMESTAMP - 1 HOUR;
    SET v_end_time = CURRENT TIMESTAMP;

    -- Retrieve total bytes sent and received
    SELECT SUM(SENT_BYTES) INTO v_total_sent
    FROM MON_GET_ACTIVITY(NULL, NULL, v_start_time, v_end_time);

    SELECT SUM(RECEIVED_BYTES) INTO v_total_received
    FROM MON_GET_ACTIVITY(NULL, NULL, v_start_time, v_end_time);

    -- Output the results
    PRINT 'Total Sent Bytes: ' || v_total_sent;
    PRINT 'Total Received Bytes: ' || v_total_received;

END;
