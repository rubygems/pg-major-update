#!/bin/bash

# Initialize variables
old_host=""
old_port=""
old_user=""
old_dbname=""
old_password=""
new_host=""
new_port=""
new_user=""
new_dbname=""
new_password=""
pgbouncer_host=""
pgbouncer_port=""
pgbouncer_user=""

# Function to display usage
usage() {
    echo "Usage: $0 --old-host <host> --old-port <port> --old-user <user> --old-dbname <dbname> --old-password <password>"
    echo "          --new-host <host> --new-port <port> --new-user <user> --new-dbname <dbname> --new-password <password>"
    echo "          --pgbouncer-host <host> --pgbouncer-port <port> --pgbouncer-user <user>"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --old-host) old_host="$2"; shift ;;
        --old-port) old_port="$2"; shift ;;
        --old-user) old_user="$2"; shift ;;
        --old-dbname) old_dbname="$2"; shift ;;
        --old-password) old_password="$2"; shift ;;
        --new-host) new_host="$2"; shift ;;
        --new-port) new_port="$2"; shift ;;
        --new-user) new_user="$2"; shift ;;
        --new-dbname) new_dbname="$2"; shift ;;
        --new-password) new_password="$2"; shift ;;
        --pgbouncer-host) pgbouncer_host="$2"; shift ;;
        --pgbouncer-port) pgbouncer_port="$2"; shift ;;
        --pgbouncer-user) pgbouncer_user="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

# Check if all parameters are set
if [[ -z "$old_host" || -z "$old_port" || -z "$old_user" || -z "$old_dbname" || -z "$old_password" ||
      -z "$new_host" || -z "$new_port" || -z "$new_user" || -z "$new_dbname" || -z "$new_password" ||
      -z "$pgbouncer_host" || -z "$pgbouncer_port" || -z "$pgbouncer_user" ]]; then
    usage
fi

# Generate pg_service.conf file
cat > pg_service.conf << EOF
[old-db]
host=$old_host
port=$old_port
user=$old_user
dbname=$old_dbname
password=$old_password

[new-db]
host=$new_host
port=$new_port
user=$new_user
dbname=$new_dbname
password=$new_password

[pgbouncer]
host=$pgbouncer_host
port=$pgbouncer_port
user=$pgbouncer_user
EOF

cat > vars << EOF
OLD_CONNECTION="dbname=$old_dbname host=$old_host user=$old_user password=$old_password port=$old_port"
NEW_CONNECTION="dbname=$new_dbname host=$new_host user=$new_user password=$new_password port=$new_port"
EOF

echo "[INFO] pg_service.conf file created."
echo "[INFO] vars file created"
