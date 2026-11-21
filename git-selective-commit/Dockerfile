FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends git coreutils grep \
    && rm -rf /var/lib/apt/lists/*

RUN git config --system user.name "Clice Student" \
    && git config --system user.email "student@clice.local" \
    && git config --system init.defaultBranch main \
    && git config --system core.editor true \
    && git config --system --add safe.directory '*'

RUN set -e; \
    mkdir -p /workspace/project /opt/clice; \
    cd /workspace/project; \
    git init -q -b main; \
    printf 'Project notes\n- set up the repo\n' > notes.txt; \
    git add notes.txt; \
    git commit -q -m "Initial commit: add notes"; \
    git rev-parse HEAD > /opt/clice/base.sha; \
    printf 'print("Hello from my first project")\n' > app.py; \
    printf '[debug] starting up\n[debug] loaded config\n[debug] done\n' > debug.log

WORKDIR /workspace/project
CMD ["/bin/bash"]

LABEL org.opencontainers.image.source=https://github.com/Programming-Sai/clice-challenges
