FROM ubuntu:22.04

ENV PG_ML_VERSION 2.8.2

RUN set -eux; \
    apt-get update -y; \
    apt-get install -y \
        lsb-release curl ca-certificates gnupg coreutils sudo openssl; \
    echo "deb [trusted=yes] https://apt.postgresml.org $(lsb_release -cs) main" > /etc/apt/sources.list.d/postgresml.list; \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null; \
    apt-get update -y; \
    apt-get install -y \
        git postgresml-dashboard=${PG_ML_VERSION};

CMD ["/usr/bin/pgml-dashboard"]