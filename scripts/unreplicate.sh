#!/bin/bash

source $(dirname "$0")/../vars
set -e

echo "[INFO] Removing subscription on new instance."
psql "$NEW_CONNECTION" -c "DROP SUBSCRIPTION migration_sub;" &> /dev/null

echo "[INFO] Removing publication for all tables on current instance."
psql "$OLD_CONNECTION" -c "DROP PUBLICATION migration_pub;" &> /dev/null

