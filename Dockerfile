FROM ubuntu:24.04

# Setup environment variables
ENV HOME=/root \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      software-properties-common

RUN curl -o "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc && \
    curl -o "/etc/apt/sources.list.d/xpra.sources" https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/noble/xpra.sources

RUN add-apt-repository universe && \
    apt-get update && \
    apt-get install -y xpra && \
    rm -rf /var/lib/apt/lists/*

# --- Requirement done --- #

ARG CACHEBUST=1

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
