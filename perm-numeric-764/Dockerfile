FROM openeuler/openeuler:22.03-lts
RUN dnf install -y coreutils && dnf clean all
RUN mkdir -p /workspace
WORKDIR /workspace
CMD ["/bin/bash"]
LABEL org.opencontainers.image.source=https://github.com/Programming-Sai/clice-challenges
