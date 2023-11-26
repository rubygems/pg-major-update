#!/bin/bash

# Define the file path
FILE_PATH="pgbouncer.ini"

# Check if the file exists
if [[ ! -f "$FILE_PATH" ]]; then
    echo "[ERROR] $FILE_PATH not found!"
    exit 1
fi

# Use sed to make the replacement
sed -i 's/db = dbname=rubygems_development host=127.0.0.1 user=rubygems_master port=5555/db = dbname=rubygems_development host=127.0.0.1 user=rubygems_master port=5556/' "$FILE_PATH"

echo "[INFO] Replacement made successfully."

psql service=pgbouncer -c "RELOAD;" &> /dev/null
echo "[INFO] pgbouncer reloaded."

