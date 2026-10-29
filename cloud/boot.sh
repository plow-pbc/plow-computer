#!/bin/sh
set -eu
if [ "$(id -u)" = 0 ]; then
    exec setpriv --reuid=latch --regid=latch --init-groups env HOME=/home/latch "$0" "$@"
fi
: "${PLOW_API_BASE:?PLOW_API_BASE must name the host Plow proxy}"
export PLOW_API_BASE
export PATH=/opt/latch/bin:$PATH
if ! timeout 90 /usr/local/bin/plow-install-latch; then
    printf 'Latch download failed; starting installed Latch\n' >&2
fi
token=$(mktemp)
printf 'proxied\n' > "$token"
latch login --name cloud --token-file "$token"
rm "$token"
latch plugins enable google || true
exec latch serve --foreground --headless-browsers
