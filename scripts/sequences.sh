#!/bin/bash

source $(dirname "$0")/../vars
set -e

# Fetch all sequences from the source database
SEQUENCES=$(psql "$OLD_CONNECTION" -Atc "SELECT sequence_schema || '.' || sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public';")

for seq in $SEQUENCES; do
    # Get the current value of the sequence from the source
    OLD_VAL=$(psql "$OLD_CONNECTION" -Atc "SELECT last_value FROM $seq;")
    # Get the current value of the sequence from the destination
    NEW_VAL=$(psql "$NEW_CONNECTION" -Atc "SELECT last_value FROM $seq;" 2>/dev/null || echo "Not Exists")

    # Check if the sequence exists in the destination and if the values are out of sync
    if [[ "$NEW_VAL" == "Not Exists" ]]; then
        echo "[WARNING] Sequence $seq does not exist in destination database."
    elif [[ "$OLD_VAL" == "$NEW_VAL" ]]; then
        true
        # echo "[INFO] Sequence $seq is in sync with value $NEW_VAL."
    else
        # Increment the OLD_VAL by 1
        let "INCREMENTED_VAL=OLD_VAL+1"
        # Set the sequence value in the destination database and increment it
        psql "$NEW_CONNECTION" -c "SELECT setval('$seq', $INCREMENTED_VAL, false);" &> /dev/null
        # echo "[INFO] Synced and incremented sequence $seq. Old value: $NEW_VAL, New value: $INCREMENTED_VAL."
    fi
done

echo "[INFO] Sequence sync check completed!"
