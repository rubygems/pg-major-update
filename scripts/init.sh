#!/bin/bash

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
cp configs/userlist.txt userlist.txt
pgbouncer -d pgbouncer.ini

# Wait for the old-db service to be up
echo "[INFO] Waiting for old-db service to be up..."
until psql service=old-db -c "\l" &> /dev/null; do
    echo "       - Checking old-db service..."
    sleep 1
done

# Wait for the new-db service to be up
echo "[INFO] Waiting for new-db service to be up..."
until psql service=new-db -c "\l" &> /dev/null; do
    echo "       - Checking new-db service..."
    sleep 1
done

# Wait for the pgbouncer service to be up
echo "[INFO] Waiting for pgbouncer service to be up..."
until psql service=old-db -c "\l" &> /dev/null; do
    echo "       - Checking old-db service..."
    sleep 1
done

# Create a PostgreSQL extension
echo "[INFO] Creating PostgreSQL extension..."
psql service=old-db -c "CREATE EXTENSION IF NOT EXISTS hstore;" &> /dev/null

# Import SQL dump into the old-db
echo "[INFO] Importing RubyGems.org dump, it can take a while..."
tar xOf public_postgresql.tar public_postgresql/databases/PostgreSQL.sql.gz | gunzip -c | psql service=old-db &> /dev/null

echo "[INFO] Script completed successfully!"
