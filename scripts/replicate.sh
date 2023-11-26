#!/bin/bash

source $(dirname "$0")/../vars
set -e

echo "[INFO] Creating schema backup of current instance."
pg_dump "$OLD_CONNECTION" -s -n public -Fp > schema.sql

echo "[INFO] Restoring schema into new instance."
psql "$NEW_CONNECTION" -c "CREATE EXTENSION IF NOT EXISTS hstore;" &> /dev/null
psql "$NEW_CONNECTION" -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;" &> /dev/null
psql "$NEW_CONNECTION" < schema.sql &> /dev/null
rm schema.sql

echo "[INFO] Creating publication for all tables on current instance."
psql "$OLD_CONNECTION" -c "CREATE PUBLICATION migration_pub FOR ALL TABLES;" &> /dev/null

echo "[INFO] Creating subscription on new instance."
psql "$NEW_CONNECTION" -c "CREATE SUBSCRIPTION migration_sub CONNECTION '$SUB_CONNECTION' PUBLICATION migration_pub;" &> /dev/null

echo "[INFO] Script completed successfully!"
