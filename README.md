# Online PostgreSQL migration

## setup

- `pgbouncer` and `psql` executables must be installed (`apt-get install postgresql-client pgbouncer`)
- for local test also `tar` and `gunzip` is needed

Fill in `vars` file (per https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PARAMKEYWORDS).

- `OLD_CONNECTION` = connection to current DB
- `NEW_CONNECTION` = connection to new DB
- `SUB_CONNECTION` = connection to current DB as used from new DB (usually same as `OLD_CONNECTION`, but differs in docker based test example due to specific docker networking)
- `PGB_CONNECTION` = connection to pgbouncer

```bash
$ cp vars.example vars
# update vars
$ source vars
```

## migration

`pgbouncer` is temporarily needed for migration to hand over opened connections. Initially, it needs to be pointing to old DB. For simple setup, it is enough to reuse example config from this repository.

```bash
useradd pgbouncer
mkdir /tmp/pgb
chown -R pgbouncer:pgbouncer /tmp/pgb

cp configs/pgbouncer.ini pgbouncer.ini
echo "db = $OLD_CONNECTION" >> pgbouncer.ini
pgbouncer -d pgbouncer.ini
```


## testing migration locally

```bash
# download latest public_postgresql.tar from https://rubygems.org/pages/data into root folder
./scripts/init.sh # start local pg instances and pgbouncer
./scripts/replicate.sh # start replication
# wait unless initial replication is in sync, for example with following command
psql "$NEW_CONNECTION" -c "SELECT * FROM pg_stat_subscription" # only one line should be present

# once ready

./scripts/pause.sh # pause old cluster and wait unless connections are gone
./scripts/lag.sh # wait unless replication is in sync
./scripts/sequences.sh # sync sequences manually
./scripts/unreplicate.sh # stop replication
./scripts/switch.sh # switch pgbouncer to new cluster
./scripts/resume.sh # resume
```
