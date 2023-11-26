# Online PostgreSQL migration

## prepare

- get latest dump for testing, unpack and copy to rubygems.sql

```bash
# in rubygems.org repo
# use ./script/load-pg-dump to load DB
# export DB into rubygems.sql
psql 
```

- generate pg_service and setup env

```
./setup.sh \
    --old-host 127.0.0.1 --old-port 5555 --old-user rubygems_master --old-dbname rubygems_development --old-password randompass-old \
    --new-host 127.0.0.1 --new-port 5556 --new-user rubygems_master --new-dbname rubygems_development --new-password randompass-new \
    --pgbouncer-host 127.0.0.1 --pgbouncer-port 5557 --pgbouncer-user pgbouncer

```

- export pgservice file (this is needed in all terminals related to psql commands

```bash
export PGSERVICEFILE=./pg_service.conf
```

## setup clusters

```bash
./scripts/init.sh
```

## start replication

```bash
./scripts/replicate.sh
```

## pause old cluster and wait unless connections are gone

```bash
./scripts/pause.sh
```

## wait unless replication is in sync

```bash
./scripts/lag.sh
```

## sync sequences manually

```bash
./scripts/sequences.sh
```

## stop replication

```bash
./scripts/unreplicate.sh
```

## switch pgbouncer to new cluster

```bash
./scripts/switch.sh
```

## resume

```bash
./scripts/resume.sh
```
