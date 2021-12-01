# Based on Dockerfile at https://github.com/elastic/rally/blob/master/docker/Dockerfiles/Dockerfile-release
# Modified by Z Knight for openFDA Elasticsearch benchmark testing
# November 9, 2021
#
FROM python:3.8.12-slim-bullseye
ARG RALLY_VERSION=2.3.0
ARG RALLY_LICENSE=http://www.apache.org/licenses/LICENSE-2.0

ENV RALLY_RUNNING_IN_DOCKER True


RUN apt-get -y update && \
    apt-get install -y curl git gcc pbzip2 pigz && \
    apt-get -y upgrade && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 rally && \
    useradd -d /rally -m -k /dev/null -g 1000 -N -u 1000 -l -s /bin/bash rally

RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install esrally==$RALLY_VERSION

WORKDIR /rally
COPY --chown=1000:0 entrypoint.sh /entrypoint.sh
# The included rally.ini file is currently causing rally to crash.  Todo: fix this.
# COPY --chown=1000:0 rally.ini /rally/.rally/rally.ini

# Openshift overrides USER and uses random ones with uid>1024 and gid=0
# Allow ENTRYPOINT (and Rally) to run even with a different user
RUN chgrp 0 /entrypoint.sh && \
    chmod g=u /etc/passwd && \
    chmod 0775 /entrypoint.sh

RUN mkdir -p /rally/.rally && \
    chown -R 1000:0 /rally/.rally

# copy the openFDA and testing scripts and tracks to temp location
COPY --chown=1000:0 tracks/ /tracks/

USER 1000

ENV PATH=/rally/venv/bin:$PATH

LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.vendor="Elastic" \
  org.label-schema.name="rally" \
  org.label-schema.version="${RALLY_VERSION}" \
  org.label-schema.url="https://esrally.readthedocs.io/en/stable/" \
  org.label-schema.vcs-url="https://github.com/elastic/rally" \
  license="${RALLY_LICENSE}"

VOLUME ["/rally/.rally"]

ENTRYPOINT ["/entrypoint.sh"]
