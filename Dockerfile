FROM debian
LABEL authors="Madhawa"

ENTRYPOINT ["top", "-b"]

ENV DEBIAN_FRONTEND noninteractive

ENV DOCKER_NET docker0

# Install packages
RUN apt-get update && apt-get install -y redsocks

# Copy configuration files...
COPY redsocks.tmpl /etc/redsocks.tmpl
COPY redsocks.sh /usr/local/bin/redsocks.sh

RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/redsocks.sh"]