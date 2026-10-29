# Plow Computer

The base image for each Plow user's cloud computer on exe.dev. Latch is its
first service, providing a browser and Google tools to the user's agents.

The Linux amd64 image pins Latch `v0.1.0-149`, by version and sha256, and
installs Chrome, Latch's default browser, and gog at build time. Chrome is baked in; boot does not download it.
The image is about 1.5 GB uncompressed and runs on 1 CPU / 2 GB / 10 GB.

## Boot

The VM receives `PLOW_API_BASE`, pointing at its own exe.dev HTTP-proxy
integration. The real credential stays in the proxy, which supplies it upstream.
The image contains no login, peer key, vault contents, or real Plow token.

Boot drops root to the `latch` user (UID 10000), including on exe.dev where
the VM starts the image command as root, and sets `HOME=/home/latch`.
On each boot, Latch logs in as `cloud` using a mode-600 temporary file containing
only `proxied`. Latch saves that placeholder and the temporary file is removed.
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
installed Latch, Chrome and gog and prints `PLOW_PROBE_OK` on success.

## Publish

Use Plow's existing **Build agent image** workflow with
`repo=plow-pbc/plow-computer`, `revision` set to the full source commit SHA, and
`multiarch=false`. It clones this public repository anonymously, builds
`cloud/Dockerfile` with the repository root as context, runs the declared probe,
and publishes alongside the agent images. Use the registry-verified digest
from the workflow summary as Plow's `LATCH_HOST_IMAGE`; publishing alone does
not change the API's pin. Empty `LATCH_HOST_IMAGE` keeps hosting disabled.
