FROM openeuler/openeuler:22.03-lts
RUN dnf install -y bind bind-utils coreutils && dnf clean all
RUN mkdir -p /workspace /etc/bind/zones /var/named
RUN touch /etc/named.conf 2>/dev/null; touch /etc/bind/named.conf.local 2>/dev/null || true
WORKDIR /workspace
CMD ["/bin/bash"]
LABEL org.opencontainers.image.source=https://github.com/Programming-Sai/clice-challenges
