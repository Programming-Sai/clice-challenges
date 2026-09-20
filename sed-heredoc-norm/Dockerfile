FROM ubuntu:22.04
RUN apt-get update && apt-get install -y --no-install-recommends coreutils sed && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /workspace/data
COPY data/app.conf /workspace/data/app.conf
WORKDIR /workspace
CMD ["/bin/bash"]
LABEL org.opencontainers.image.source=https://github.com/Programming-Sai/clice-challenges
