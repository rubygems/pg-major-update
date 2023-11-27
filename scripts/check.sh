#!/bin/bash

source $(dirname "$0")/../vars
set -e

# Wait for the old-db service to be up
echo "[INFO] Waiting for old-db service to be up..."
until psql "$OLD_CONNECTION" -c "\l" &> /dev/null; do
    echo "       - Checking old-db service..."
    sleep 1
done
echo "       - OK!"

# Wait for the new-db service to be up
echo "[INFO] Waiting for new-db service to be up..."
until psql "$NEW_CONNECTION" -c "\l" &> /dev/null; do
    echo "       - Checking new-db service..."
    sleep 1
done
echo "       - OK!"

# Wait for the pgbouncer service to be up
echo "[INFO] Waiting for pgbouncer service to be up..."
until psql "$PGB_CONNECTION" -c "SHOW VERSION" &> /dev/null; do
    echo "       - Checking pgbouncer service..."
    sleep 1
done
echo "       - OK!"
