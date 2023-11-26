#!/bin/bash

source $(dirname "$0")/../vars
set -e

# Remove and stop Docker containers
echo "[INFO] Removing and stopping Docker containers..."
docker compose rm --force --stop -v &> /dev/null

# Stop local pgbouncer
echo "[INFO] Stopping pgbouncer and resetting config..."
if test -f "/tmp/pgbouncer.pid"; then
    kill $(cat /tmp/pgbouncer.pid)
fi

# Start Docker containers
echo "[INFO] Starting Docker containers..."
docker compose up -d &> /dev/null

# Start local pgbouncer
echo "[INFO] Starting pgbouncer..."
cp configs/pgbouncer.ini pgbouncer.ini
echo "db = $OLD_CONNECTION" >> pgbouncer.ini
pgbouncer -d pgbouncer.ini

# Wait for the old-db service to be up
echo "[INFO] Waiting for old-db service to be up..."
until psql "$OLD_CONNECTION" -c "\l" &> /dev/null; do
    echo "       - Checking old-db service..."
    sleep 1
done

# Wait for the new-db service to be up
echo "[INFO] Waiting for new-db service to be up..."
until psql "$NEW_CONNECTION" -c "\l" &> /dev/null; do
    echo "       - Checking new-db service..."
    sleep 1
done

# Wait for the pgbouncer service to be up
echo "[INFO] Waiting for pgbouncer service to be up..."
until psql "$PGB_CONNECTION" -c "SHOW VERSION" &> /dev/null; do
    echo "       - Checking pgbouncer service..."
    sleep 1
done

# Create a PostgreSQL extension
echo "[INFO] Creating PostgreSQL extension..."
psql "$OLD_CONNECTION" -c "CREATE EXTENSION IF NOT EXISTS hstore;" &> /dev/null

# Import SQL dump into the old-db
echo "[INFO] Importing RubyGems.org dump, it can take a while..."
tar xOf public_postgresql.tar public_postgresql/databases/PostgreSQL.sql.gz | gunzip -c | psql "$OLD_CONNECTION" &> /dev/null

echo "[INFO] Script completed successfully!"
