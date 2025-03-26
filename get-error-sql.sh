#!/bin/bash

# Define SQL file and log file
sqlFile="ReservedDetailData1.sql"
logFile="db2_error.log"

# Run the SQL file with -tvf and capture both output and error

output=$(db2 connect to insvndb && db2 -tvf "$sqlFile" 2>&1)

# Check the return code of the DB2 command
if [ $? -ne 0 ]; then
    # Parse the SQL error code and message
    sql_error=$(echo "$output" | grep -oP "SQL\d{4}N.*")
    
    # Store the error message in a variable
    error_message="$sql_error"
    
    # Log the error message to a file
    echo "SQL Error: $error_message" >> "$logFile"
    
    # Display the error message
    echo "SQL execution failed with error: $error_message"
else
    echo "SQL execution succeeded."
fi