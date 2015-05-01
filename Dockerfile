# Dockerfile for square/keywhiz
#
# Note: keep this in the root of the project next to
# the pom.xml to work correctly
#
# Building:
#   docker build --rm --force-rm -t square/keywhiz .
#
# Example usage: 
#   docker run square/keywhiz java -jar server/target/keywhiz-server-*-SNAPSHOT-shaded.jar server server/src/main/resources/keywhiz-development.yaml
#
FROM maven:3.3-jdk-8

# install postgres: really this should be run in
# a different container but the "model" test creates
# a db
RUN apt-get update && apt-get install -y \
    postgresql \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# mkdir for app
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# add the source
ADD . /usr/src/app

# install
RUN mkdir -p /var/run/postgresql/9.4-main.pg_stat_tmp \
    && chown postgres:postgres /var/run/postgresql/9.4-main.pg_stat_tmp \
    && echo 'local   all             all                                     trust' > /etc/postgresql/9.4/main/pg_hba.conf \
    && echo 'host    all             all             127.0.0.1/32            trust' >> /etc/postgresql/9.4/main/pg_hba.conf \
    && echo 'CREATE DATABASE "keywhizdb_test" ;' > /test.sql \
    && echo 'CREATE USER root WITH SUPERUSER ;' >> /test.sql \
    && su postgres -c '/usr/lib/postgresql/9.4/bin/postgres --single -E --config-file=/etc/postgresql/9.4/main/postgresql.conf postgres < /test.sql' \
    && rm /test.sql \
    && su postgres -c '/usr/lib/postgresql/9.4/bin/postgres --config-file=/etc/postgresql/9.4/main/postgresql.conf &' \
    && while ! psql keywhizdb_test -c '\list' > /dev/null 2>&1; do echo -n .; sleep 1; done \
    && mvn package -am -pl server \
    && mvn package -am -pl cli \
    && killall postgres \
    && echo 'alias keywhiz.cli="./cli/target/keywhiz-cli-*-SNAPSHOT-shaded.jar"' >> /root/.bashrc \
    && echo 'alias keywhiz.server="java -jar server/target/keywhiz-server-*-SNAPSHOT-shaded.jar server"' >> /root/.bashrc
