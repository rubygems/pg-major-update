# Online PostgreSQL migration

## testing

- get latest dump for testing, unpack and copy to rubygems.sql


## setup

Fill in `vars` file (per https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PARAMKEYWORDS).

- `OLD_CONNECTION` = connection to current DB
- `NEW_CONNECTION` = connection to new DB
- `SUB_CONNECTION` = connection to current DB as used from new DB (usually same as `OLD_CONNECTION`, but differs in docker based test example due to specific docker networking)
- `PGB_CONNECTION` = connection to pgbouncer

```
$ cp vars.example vars
# update vars
```

## setup clusters (for dev testing)

```bash
./scripts/init.sh
```

## start replication

```bash
./scripts/replicate.sh
```

## wait unless initial replication is in sync

```bash
psql "$NEW_CONNECTION" -c "SELECT * FROM pg_stat_subscription" # only one line should be present
```

## migrate

```bash
./scripts/pause.sh # pause old cluster and wait unless connections are gone
./scripts/lag.sh # wait unless replication is in sync
./scripts/sequences.sh # sync sequences manually
./scripts/unreplicate.sh # stop replication
./scripts/switch.sh # switch pgbouncer to new cluster
./scripts/resume.sh # resume
```
