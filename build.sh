#!/usr/bin/env bash
# Deterministic build script for Cloudflare Pages.
#
# This repository's static site was uploaded nested inside a subdirectory
# (an artifact of how the source zip was extracted) rather than living at
# the repository root, which is why Cloudflare Pages' default root-directory
# static serving returned 404s: there was no index.html at the repo root.
#
# This script locates the real site source (the directory that contains
# both index.html and styles.css) and copies it, unmodified, into dist/ at
# the repository root, so Cloudflare (or any static host) can serve dist/
# directly. No files are edited, renamed, or regenerated — this is a copy
# only.
set -euo pipefail
cd "$(dirname "$0")"

SITE_SRC=""
while IFS= read -r -d '' candidate; do
  dir=$(dirname "$candidate")
  if [ -f "$dir/styles.css" ]; then
    SITE_SRC="$dir"
    break
  fi
done < <(find . -maxdepth 4 -name "index.html" -not -path "./dist/*" -print0 | sort -z)

if [ -z "$SITE_SRC" ]; then
  echo "ERROR: could not locate the site source directory (a directory containing both index.html and styles.css)." >&2
  exit 1
fi

echo "Site source directory: $SITE_SRC"

rm -rf dist
mkdir -p dist
cp -R "$SITE_SRC"/. dist/

echo "Build complete: dist/ (from $SITE_SRC)"
