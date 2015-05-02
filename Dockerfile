FROM ryanckoch/docker-ubuntu-14.04

ENV DEBIAN_FRONTEND noninteractive

VOLUME ["/opt/mangos/etc", "/opt/mangos/data", "/opt/mangos/logs"]

RUN apt-get update && \
    apt-get install -y mysql-client && \
    rm -rf /var/lib/apt/lists/*

ADD mangoszero-initdb.sh /mangoszero-initdb.sh
ADD update-realm.sh /update-realm.sh

ENTRYPOINT ["/bin/sh /mangoszero-initdb.sh"]
