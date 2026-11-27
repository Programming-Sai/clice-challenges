FROM ubuntu:22.04

COPY setup/ /tmp/setup/
RUN bash /tmp/setup/build.sh && rm -rf /tmp/setup

USER engineer
WORKDIR /home/engineer
ENTRYPOINT ["/usr/local/lib/kente/entrypoint.sh"]
CMD ["/bin/bash"]
LABEL org.opencontainers.image.source=https://github.com/Programming-Sai/clice-challenges
