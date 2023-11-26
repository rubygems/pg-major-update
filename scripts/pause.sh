#!/bin/bash

set -e

# Send PAUSE command
echo "[INFO] Sending PAUSE."
psql service=pgbouncer -c "PAUSE;" &> /dev/null
