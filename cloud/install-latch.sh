#!/bin/sh
set -eu
releases=https://releases.plow.co/latch-cli
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
version=$(curl -fsSL --connect-timeout 5 --max-time 20 "$releases/latest.json" | sed -n 's/.*"tag": *"\([^"]*\)".*/\1/p')
printf '%s\n' "$version" | LC_ALL=C grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$'
archive="latch-$version-x86_64-unknown-linux-musl.tar.gz"
for file in "$archive" SHA256SUMS; do
    curl -fsSL --connect-timeout 5 --max-time 30 -o "$tmp/$file" "$releases/releases/$version/$file"
done
cd "$tmp"
awk -v name="$archive" '$2 == name { print; found=1 } END { if (!found) exit 1 }' SHA256SUMS | sha256sum -c -
tar -xzf "$archive"
setup="$tmp/latch-$version-x86_64-unknown-linux-musl"
sh "$setup/install-binary.sh" --bin-dir /opt/latch/bin --state-dir /home/latch/.latch --browser camoufox --non-interactive
