#!/bin/sh
set -eu
latch --version
test ! -e "$HOME/.latch/plugins/cft"
latch browser setup --engine camoufox
gog=$(find "$HOME/.latch/plugins/gog" -type f -name gog)
"$gog" --version
printf 'PLOW_PROBE_OK\n'
