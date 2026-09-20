FROM openeuler/openeuler:22.03-lts
RUN dnf install -y nginx curl procps-ng coreutils && dnf clean all
RUN mkdir -p /workspace /data/www /etc/nginx/conf.d
WORKDIR /workspace
CMD ["/bin/bash"]
LABEL org.opencontainers.image.source=https://github.com/Programming-Sai/clice-challenges
