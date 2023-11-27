# Online PostgreSQL migration

## variables needed

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

`pgbouncer` is temporarily needed for migration to hand over opened connections. Initially, it needs to be pointing to old DB. For simple setup on Debain system, it is enough to reuse example config from this repository. If using custom `pgbouncer` setup, please tweak `switch.sh` according to your needs. Example setup could use included `pgbouncer.yaml` to deploy "utility pod" and service into K8s cluster.

`psql` and `pgbouncer` programs needs to be installed for migration scripts to work.

### env setup

```bash
apt-get update
apt-get install -y postgresql-client pgbouncer vim git procps pspg # vim, git, procps and pspg are optional
export PAGER=pspg

git clone https://github.com/simi/pg-major-update.git
cd pg-major-update
vim vars # update vars
source vars
```

### setup pgbouncer

```bash
useradd pgbouncer
mkdir /tmp/pgb
chown -R pgbouncer:pgbouncer /tmp/pgb

cp configs/pgbouncer.ini pgbouncer.ini
echo "db = $OLD_CONNECTION" >> pgbouncer.ini
pgbouncer -d pgbouncer.ini --user pgbouncer
```


### connections check

```bash
./scripts/checks.sh
```

### point application to pgbouncer

This depends on application configuration. For example it could be enough to change `DATABASE_URL` secret in K8s and restart deployment to pickup new value.

*Notice pgbouncer doesn't support all features like prepared statements and LISTEN. See https://www.pgbouncer.org/features.html#sql-feature-map-for-pooling-modes for more info. For Rails application it could be enough to configure ActiveRecord to not use prepared statements temporarily for time of the upgrade. Other processes relying on those features like GoodJob could be temporarily stopped during the migration.*

### migrate

```bash
./scripts/pause.sh && ./scripts/lag.sh && ./scripts/sequences.sh && ./scripts/unreplicate.sh && ./scripts/switch.sh && ./scripts/resume.sh
```

### point application to new cluster

Again, this depends on application configuration. For example it could be enough to change `DATABSAE_URL` secret in K8s and restart deployment to pickup new value.

## testing migration locally

`pgbouncer`, `tar` and `gunzip` needs to be installed locally. Two PostgreSQL instances for testing will be created using Docker (docker-compose).

```bash
cp vars.example vars # preconfigured values for docker-compose.yml and configs/pgbouncer.ini
# download latest public_postgresql.tar from https://rubygems.org/pages/data into root folder
./scripts/init.sh # start local pg instances and pgbouncer
./scripts/replicate.sh # start replication
# wait unless initial replication is in sync, for example with following command
psql "$NEW_CONNECTION" -c "SELECT * FROM pg_stat_subscription" # only one line should be present

# once ready

./scripts/pause.sh # pause old cluster and wait unless connections are gone
# wait unless replication is in sync
# this step can fail after timeout when replication is not in sync and automatically resumes pgbouncer connections
# it is ok to try later
./scripts/lag.sh 
./scripts/sequences.sh # sync sequences manually
./scripts/unreplicate.sh # stop replication
./scripts/switch.sh # switch pgbouncer to new cluster
./scripts/resume.sh # resume
```

This leaves `pgbouncer` running and pointing to new DB cluster. `pgbouncer` can be stopped using `kill $(cat /tmp/pgbouncer.pid)` or similar command. To stop PostgreSQL testing instances you can use `docker compose stop`.
