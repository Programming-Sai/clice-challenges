FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends coreutils grep sed gawk && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /workspace/data
COPY access.log /workspace/data/access.log

WORKDIR /workspace
