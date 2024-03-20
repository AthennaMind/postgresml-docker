FROM nvidia/cuda:12.3.2-devel-ubuntu22.04

ENV PG_VERSION 15
ENV PG_VECTOR_VERSION v0.5.0
ENV PG_ML_VERSION 2.8.2

ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV PATH="/usr/local/bin:${PATH}"
ENV PATH="/usr/lib/postgresql/${PG_VERSION}/bin:${PATH}"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG en_US.utf8

ENV PGDATA /var/lib/postgresql/data


USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY docker-entrypoint.sh docker-ensure-initdb.sh /usr/local/bin/

RUN set -eux; \
	groupadd -r postgres --gid=999; \
    # https://salsa.debian.org/postgresql/postgresql-common/blob/997d842ee744687d99a2b2d95c1083a2615c79e8/debian/postgresql-common.postinst#L32-35
	useradd -r -g postgres --uid=999 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
    # also create the postgres user's home directory with appropriate permissions
    # see https://github.com/docker-library/postgres/issues/274
	mkdir -p /var/lib/postgresql; \
	chown -R postgres:postgres /var/lib/postgresql \
	&& if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
        # if this file exists, we're likely in "debian:xxx-slim", and locales are thus being excluded so we need to remove that exclusion (since we need locales)
		grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
		sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
		! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
	fi; \
	apt-get update; apt-get install -y --no-install-recommends locales; rm -rf /var/lib/apt/lists/*; \
	echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
	locale-gen; \
	locale -a | grep 'en_US.utf8'

VOLUME /var/lib/postgresql/data

RUN set -eux; \
    apt update -y; \
    apt install -y \
        lsb-release curl ca-certificates gnupg sudo coreutils openssl; \
    echo "deb [trusted=yes] https://apt.postgresml.org $(lsb_release -cs) main" > /etc/apt/sources.list.d/postgresml.list; \
	echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
	curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null; \
    apt update -y; \
    apt install -y \
        git gosu \
        postgresml-${PG_VERSION}=${PG_ML_VERSION}; \
    git clone --branch ${PG_VECTOR_VERSION} \
        https://github.com/pgvector/pgvector; \
    cd pgvector; \
    echo "trusted = true" >> vector.control; \
	make; \
	make install; \
    mkdir /docker-entrypoint-initdb.d; \
    mkdir -p /var/run/postgresql; \
    chown -R postgres:postgres /var/run/postgresql; \
    chmod 3777 /var/run/postgresql; \
    mkdir -p "$PGDATA"; \
    chown -R postgres:postgres "$PGDATA"; \
    chmod 1777 "$PGDATA"; \
    chmod +x /usr/local/bin/docker-entrypoint.sh; \
    chmod +x /usr/local/bin/docker-ensure-initdb.sh; \
    ln -sT docker-ensure-initdb.sh /usr/local/bin/docker-enforce-initdb.sh; \
    # clean up
    apt-get clean; \
    rm -rf /tmp/* /var/tmp/*; \
    rm -rf pgvector 

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# We set the default STOPSIGNAL to SIGINT, which corresponds to what PostgreSQL
# calls "Fast Shutdown mode" wherein new connections are disallowed and any
# in-progress transactions are aborted, allowing PostgreSQL to stop cleanly and
# flush tables to disk, which is the best compromise available to avoid data
# corruption.
STOPSIGNAL SIGINT
#
# An additional setting that is recommended for all users regardless of this
# value is the runtime "--stop-timeout" (or your orchestrator/runtime's
# equivalent) for controlling how long to wait between sending the defined
# STOPSIGNAL and sending SIGKILL (which is likely to cause data corruption).
#
# The default in most runtimes (such as Docker) is 10 seconds, and the
# documentation at https://www.postgresql.org/docs/15/server-start.html notes
# that even 90 seconds may not be long enough in many instances.

EXPOSE 5432
CMD ["postgres"]