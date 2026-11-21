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
    mkdir -p /workspace/cafe /opt/clice; \
    cd /workspace/cafe; \
    git init -q -b main; \
    printf 'CAMPUS CAFE MENU\nCoffee - GHS 10\nBread - GHS 5\nJuice - GHS 7\nWater - GHS 2\n' > menu.txt; \
    git add menu.txt; \
    git commit -q -m "Add cafe menu"; \
    git checkout -q -b student-prices; \
    sed -i 's/^Coffee - GHS 10$/Coffee - GHS 12 (student price)/; s/^Juice - GHS 7$/Juice - GHS 6 (student price)/' menu.txt; \
    git commit -q -am "Add student prices"; \
    git rev-parse HEAD > /opt/clice/feature.sha; \
    git checkout -q main; \
    sed -i 's/^Coffee - GHS 10$/Coffee - GHS 15/' menu.txt; \
    echo "Tea - GHS 8" >> menu.txt; \
    git commit -q -am "Raise coffee price and add tea"; \
    git rev-parse HEAD > /opt/clice/main.sha

WORKDIR /workspace/cafe
CMD ["/bin/bash"]

LABEL org.opencontainers.image.source=https://github.com/Programming-Sai/clice-challenges
