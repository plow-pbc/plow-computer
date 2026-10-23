FROM ubuntu:24.04
ARG PLOW_REVISION
ARG LATCH_VERSION=v0.1.0-139
LABEL org.opencontainers.image.revision=$PLOW_REVISION
LABEL co.plow.probe="/usr/local/bin/plow-host-probe"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates curl bubblewrap unzip xvfb python3 \
    libgtk-3-0t64 libasound2t64 libx11-xcb1 libdbus-1-3 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 10000 latch

# The VM manages AppArmor; this build-only marker prevents changing the build host.
RUN --mount=type=tmpfs,target=/etc/apparmor.d set -eu; \
    touch /etc/apparmor.d/bwrap-userns-restrict; \
    test "$(uname -m)" = x86_64; \
    release="https://releases.plow.co/latch-cli/releases/$LATCH_VERSION"; \
    archive="latch-$LATCH_VERSION-x86_64-unknown-linux-musl.tar.gz"; \
    mkdir /tmp/latch-install; cd /tmp/latch-install; \
    curl -fsSLO "$release/$archive"; \
    curl -fsSLO "$release/SHA256SUMS"; \
    awk -v name="$archive" '$2 == name { print; found=1 } END { if (!found) exit 1 }' SHA256SUMS | sha256sum -c -; \
    tar -xzf "$archive"; \
    sh "latch-$LATCH_VERSION-x86_64-unknown-linux-musl/install-binary.sh" \
        --bin-dir /usr/local/bin --state-dir /home/latch/.latch --browser chrome --non-interactive; \
    chown -R latch:latch /home/latch; \
    rm -rf /tmp/latch-install

COPY --chmod=755 cloud/boot.sh /usr/local/bin/plow-host
COPY --chmod=755 cloud/probe.sh /usr/local/bin/plow-host-probe
ENV HOME=/home/latch
USER 10000:10000
WORKDIR /home/latch
CMD ["/usr/local/bin/plow-host"]
