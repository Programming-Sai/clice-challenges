FROM --platform=linux/amd64 ubuntu:22.04

RUN apt-get update && apt-get install -y \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /workspace

WORKDIR /workspace

# No ENTRYPOINT - let user specify commands
CMD ["/bin/bash"]

LABEL org.opencontainers.image.source=https://github.com/Programming-Sai/clice-challenges