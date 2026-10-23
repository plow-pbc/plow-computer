#!/bin/sh
set -eu
: "${PLOW_API_BASE:?PLOW_API_BASE must name the host Plow proxy}"
export PLOW_API_BASE
token=$(mktemp)
printf 'proxied\n' > "$token"
latch login --name cloud --token-file "$token"
rm "$token"
latch plugins enable google || true
exec latch serve --foreground --headless-browsers
