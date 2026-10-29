# Plow Computer

The base image for each Plow user's cloud computer on exe.dev. Latch is its
first service, providing a browser and Google tools to the user's agents.

The Linux amd64 image bakes the newest promoted Latch release, Camoufox and gog
at build time. Chrome is not installed. Each boot attempts to install the newest
promoted Latch binary; `LATCH_VERSION=v0.1.0-148` on the VM holds a specific
release instead. Downloads and checksum verification must succeed before the
installed binary is replaced. Boot limits this attempt to 90 seconds and serves
with the installed binary on failure.

Latch lives in `/opt/latch/bin`, owned by `latch` and first on PATH. Restoring
`/home/latch` does not overwrite it, and `latch update` can replace it without
root. Boot replaces only Latch: it never invokes the release installer or
downloads browser/gog dependencies. Those remain baked (or restored), and a
release requiring different plugin pins may require rebuilding the image.

Use `latch browser open --host cloud --engine camoufox URL` to explicitly select
the baked engine. Active browser sessions do not survive a host restart.

## Boot

The VM receives `PLOW_API_BASE`, pointing at its own exe.dev HTTP-proxy
integration. The real credential stays in the proxy, which supplies it upstream.
The image contains no login, peer key, vault contents, or real Plow token.

Boot drops root to the `latch` user (UID 10000), including on exe.dev where
the VM starts the image command as root, and sets `HOME=/home/latch`.
After the update attempt on each boot, Latch logs in as `cloud` using a mode-600
temporary file containing only `proxied`. Latch saves that placeholder and the temporary file is removed.
Boot exports `PLOW_API_BASE` to login and foreground serving, enables Google
through Latch's offline setup path, then execs `latch serve --foreground
--headless-browsers` as PID 1. Google setup failure is tolerated; after connecting
Google, reboot the host to enable it.

## Build and test

```sh
just test
docker build --platform linux/amd64 -f cloud/Dockerfile -t plow-computer .
docker run --rm --platform linux/amd64 --entrypoint /usr/local/bin/plow-host-probe plow-computer
```

The boot test uses only Python's standard library. The image probe checks the
installed Latch, Camoufox and gog, verifies Chrome is absent, and prints
`PLOW_PROBE_OK` on success.

## Publish

Use Plow's existing **Build agent image** workflow with
`repo=plow-pbc/plow-computer`, `revision` set to the full source commit SHA, and
`multiarch=false`. It clones this public repository anonymously, builds
`cloud/Dockerfile` with the repository root as context, runs the declared probe,
and publishes alongside the agent images. Use the registry-verified digest
from the workflow summary as Plow's `LATCH_HOST_IMAGE`; publishing alone does
not change the API's pin. Empty `LATCH_HOST_IMAGE` keeps hosting disabled.
