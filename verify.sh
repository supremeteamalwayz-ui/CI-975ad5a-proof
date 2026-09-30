#!/usr/bin/env bash
set -euo pipefail

GNUPGHOME="$(mktemp -d)"
trap 'rm -rf "$GNUPGHOME"' EXIT
export GNUPGHOME

echo "=== 1. VERIFYING ARTIFACT SHA-256 ==="
sha256sum -c artifact.txt.sha256

echo
echo "=== 2. VERIFYING MANIFEST GPG SIGNATURE ==="
gpg --import KEYS
gpg --verify manifest.json.asc manifest.json

echo
echo "=== 3. VERIFYING RFC 3161 TIMESTAMP ==="
openssl ts -verify \
  -in manifest.tsr \
  -queryfile manifest.tsq \
  -CAfile cacert.pem \
  -untrusted tsa.crt

echo
echo "=== 4. VERIFYING SIGNED GIT TAG ==="
git -c core.pager=cat tag -v v1.0.0

echo
echo "=== ALL LOCAL PROVENANCE CHECKS PASSED SUCCESSFULLY ==="
