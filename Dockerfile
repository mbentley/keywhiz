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
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/postgresql/9.4-main.pg_stat_tmp \
    && chown postgres:postgres /var/run/postgresql/9.4-main.pg_stat_tmp

# mkdir for app
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# add the source
ADD . /usr/src/app

# install
COPY script.sh /script.sh
RUN /script.sh
