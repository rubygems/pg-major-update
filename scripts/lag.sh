#!/bin/bash

set -e

# Variables for the timeout mechanism
START_TIME=$(date +%s%N) # Current time in nanoseconds
TIMEOUT=2000000000       # 2 seconds in nanoseconds (2 billion nanoseconds)

while true; do
    # Check the replication lag
    REPL_STATUS=$(psql service=new-db -Atc "SELECT CASE WHEN received_lsn = latest_end_lsn THEN 'No lag' ELSE 'Lag detected' END FROM pg_stat_subscription WHERE subname = 'migration_sub';")

    if [ "$REPL_STATUS" = "No lag" ]; then
        echo "[INFO] Replication is in sync."
        exit 0
    fi

    # Check if timeout is exceeded
    CURRENT_TIME=$(date +%s%N)
    ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
    
    if [ "$ELAPSED_TIME" -ge "$TIMEOUT" ]; then
        echo "[ERROR] Timeout exceeded. Replication is not in sync."
        . ./resume.sh
        exit 1
    fi

    # Sleep for 100ms before the next check
    sleep 0.1
done
