#!/bin/bash

source $(dirname "$0")/../vars
set -e

# Send PAUSE command
echo "[INFO] Sending PAUSE."
psql "$PGB_CONNECTION" -c "PAUSE;" &> /dev/null
