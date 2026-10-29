FROM ubuntu:24.04
ARG PLOW_REVISION
LABEL org.opencontainers.image.revision=$PLOW_REVISION
LABEL co.plow.probe="/usr/local/bin/plow-host-probe"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates curl bubblewrap unzip xvfb python3 util-linux \
    libgtk-3-0t64 libasound2t64 libx11-xcb1 libdbus-1-3 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 10000 latch

COPY --chmod=755 cloud/install-latch.sh /usr/local/bin/plow-install-latch
# The VM manages AppArmor; this build-only marker prevents changing the build host.
RUN --mount=type=tmpfs,target=/etc/apparmor.d set -eu; \
    touch /etc/apparmor.d/bwrap-userns-restrict; \
    mkdir -p /opt/latch/bin; \
    plow-install-latch --bake; \
    chown -R latch:latch /opt/latch /home/latch

COPY --chmod=755 cloud/boot.sh /usr/local/bin/plow-host
COPY --chmod=755 cloud/probe.sh /usr/local/bin/plow-host-probe
ENV HOME=/home/latch
ENV PATH=/opt/latch/bin:$PATH
USER 10000:10000
WORKDIR /home/latch
CMD ["/usr/local/bin/plow-host"]
