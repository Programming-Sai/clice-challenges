FROM ubuntu:22.04
RUN apt-get update && apt-get install -y --no-install-recommends coreutils grep && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /workspace/data
COPY data/options.txt /workspace/data/options.txt
WORKDIR /workspace
CMD ["/bin/bash"]
LABEL org.opencontainers.image.source=https://github.com/Programming-Sai/clice-challenges
