#!/bin/bash
#
set -e

echo "[INFO] Removing subscription on new instance."
psql service=new-db -c "DROP SUBSCRIPTION migration_sub;" &> /dev/null

echo "[INFO] Removing publication for all tables on current instance."
psql service=old-db -c "DROP PUBLICATION migration_pub;" &> /dev/null

