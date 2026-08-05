FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        coreutils procps iproute2 curl python3 netcat-openbsd socat sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
