FROM openeuler/openeuler:22.03-lts
RUN dnf install -y firewalld dbus coreutils && dnf clean all
RUN mkdir -p /workspace /etc/firewalld/zones
RUN if [ ! -f /etc/firewalld/zones/public.xml ]; then firewall-offline-cmd --zone=public --add-service=ssh 2>/dev/null || echo '<?xml version="1.0" encoding="utf-8"?><zone><short>Public</short></zone>' > /etc/firewalld/zones/public.xml; fi
WORKDIR /workspace
CMD ["/bin/bash"]
LABEL org.opencontainers.image.source=https://github.com/Programming-Sai/clice-challenges
