FROM openeuler/openeuler:22.03-lts
RUN dnf install -y mariadb-server mariadb coreutils && dnf clean all
RUN mkdir -p /workspace /var/run/mysqld
RUN chown -R mysql:mysql /var/run/mysqld /var/lib/mysql 2>/dev/null || true
WORKDIR /workspace
CMD ["/bin/bash"]
LABEL org.opencontainers.image.source=https://github.com/Programming-Sai/clice-challenges
