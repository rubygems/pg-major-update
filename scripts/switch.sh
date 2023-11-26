#!/bin/bash

source $(dirname "$0")/../vars
set -e

# update pgbouncer with new connection
cp configs/pgbouncer.ini pgbouncer.ini
echo "db = $NEW_CONNECTION" >> pgbouncer.ini

echo "[INFO] Replacement made successfully."

psql "$PGB_CONNECTION" -c "RELOAD;" &> /dev/null
echo "[INFO] pgbouncer reloaded."

