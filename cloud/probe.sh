#!/bin/sh
set -eu
latch --version
latch browser setup --engine chrome
gog=$(find "$HOME/.latch/plugins/gog" -type f -name gog)
"$gog" --version
printf 'PLOW_PROBE_OK\n'
