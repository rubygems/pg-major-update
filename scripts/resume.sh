#!/bin/bash

set -e

# Send RESUME command
echo "[INFO] Resuming."
psql service=pgbouncer -c "RESUME;" &> /dev/null

