#!/bin/bash
#
set -e

echo "[INFO] Creating schema backup of current instance."
pg_dump service=old-db -s -n public -Fp > schema.sql

echo "[INFO] Restoring schema into new instance."
psql service=new-db -c "CREATE EXTENSION IF NOT EXISTS hstore;" &> /dev/null
psql service=new-db -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;" &> /dev/null
psql service=new-db < schema.sql &> /dev/null

echo "[INFO] Creating publication for all tables on current instance."
psql service=old-db -c "CREATE PUBLICATION migration_pub FOR ALL TABLES;" &> /dev/null

echo "[INFO] Creating subscription on new instance."
psql service=new-db -c "CREATE SUBSCRIPTION migration_sub CONNECTION 'host=db-old port=5432 dbname=rubygems_development user=rubygems_master' PUBLICATION migration_pub;" &> /dev/null

echo "[INFO] Script completed successfully!"
