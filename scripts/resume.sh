#!/bin/bash

source $(dirname "$0")/../vars
set -e

# Send RESUME command
echo "[INFO] Resuming."
psql "$PGB_CONNECTION" -c "RESUME;" &> /dev/null
