#!/usr/bin/env bash
set -euo pipefail

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

gh=https://github.com

fetch() { curl -fsSLO --retry 3 "$1"; }

verify() {
  local expected
  expected=$(awk -v f="$2" '$2 == f || $2 == "*" f { print $1 }' "$1")
  [ -n "$expected" ] || { echo "no checksum for $2 in $1" >&2; exit 1; }
  echo "${expected}  $2" | sha256sum -c -
}

fetch "$gh/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-amd64"
fetch "$gh/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign_checksums.txt"
verify cosign_checksums.txt cosign-linux-amd64
install -m 0755 cosign-linux-amd64 /usr/local/bin/cosign

install_tar() {
  fetch "$gh/$2/releases/download/v${VERSION}/$3"
  fetch "$gh/$2/releases/download/v${VERSION}/$4"
  verify "$4" "$3"
  tar xzf "$3" -C /usr/local/bin "$1"
}

VERSION=$TRIVY_VERSION install_tar trivy aquasecurity/trivy \
  "trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" "trivy_${TRIVY_VERSION}_checksums.txt"
VERSION=$SYFT_VERSION install_tar syft anchore/syft \
  "syft_${SYFT_VERSION}_linux_amd64.tar.gz" "syft_${SYFT_VERSION}_checksums.txt"
VERSION=$GITLEAKS_VERSION install_tar gitleaks gitleaks/gitleaks \
  "gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" "gitleaks_${GITLEAKS_VERSION}_checksums.txt"

fetch "$gh/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64"
fetch "$gh/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64.sha256"
echo "$(awk '{ print $1; exit }' hadolint-Linux-x86_64.sha256)  hadolint-Linux-x86_64" | sha256sum -c -
install -m 0755 hadolint-Linux-x86_64 /usr/local/bin/hadolint
