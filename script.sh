#!/bin/bash

set -e

echo 'local   all             all                                     trust' > /etc/postgresql/9.4/main/pg_hba.conf
echo 'host    all             all             127.0.0.1/32            trust' >> /etc/postgresql/9.4/main/pg_hba.conf

echo 'CREATE DATABASE "keywhizdb_test" ;' > /test.sql
echo 'CREATE USER root WITH SUPERUSER ;' >> /test.sql
su postgres -c '/usr/lib/postgresql/9.4/bin/postgres --single --config-file=/etc/postgresql/9.4/main/postgresql.conf postgres < /test.sql'
rm /test.sql

su postgres -c '/usr/lib/postgresql/9.4/bin/postgres --config-file=/etc/postgresql/9.4/main/postgresql.conf &'

while ! psql keywhizdb_test -c '\list' > /dev/null 2>&1
  do echo -n .
  sleep 1
done

# build the server
mvn package -am -pl server
#java -jar server/target/keywhiz-server-*-SNAPSHOT-shaded.jar server server/src/main/resources/keywhiz-development.yaml

# build the cli
mvn package -am -pl cli
#./cli/target/keywhiz-cli-*-SNAPSHOT-shaded.jar

killall postgres
