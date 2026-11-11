# Review instructions — plow-computer

Repo-specific reviewer policy. The universal review policy is prepended by the
reviewer and is not restated here.

## What this repo is

The base image for each Plow user's cloud computer on exe.dev. It bakes the
newest promoted Latch release, Camoufox and gog; `cloud/boot.sh` drops to the
`latch` user, updates Latch, logs in through the exe.dev proxy and serves.

**Stage:** user-facing. Every Plow user's cloud computer boots this image.

## Review bar

Report **Critical** and **Important** findings only. Nits and style go
unmentioned.

- **No security against coworkers.** Everyone with push access, and our own
  agents, are trusted. Don't propose guards or validation against them.
- **Simplest code wins.** Prefer deleting or inlining over a new abstraction,
  flag, or fallback for a case no current user hits.

## Where the real risks are

- **Credentials in the image.** It must carry no login, peer key, vault
  contents or real Plow token; the real credential stays in the proxy.
- **Boot that fails to serve.** A failed or slow `latch update` must still
  start serving with the installed Latch; flag a change that can wedge boot.
- **Running as root.** Serving must stay under the `latch` user (UID 10000).
