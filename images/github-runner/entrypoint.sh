#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_TOKEN:?GITHUB_TOKEN is required}"
: "${GITHUB_ORG:?GITHUB_ORG is required}"

REG_TOKEN=$(curl -fsS -X POST \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/orgs/${GITHUB_ORG}/actions/runners/registration-token" | jq -r .token)

./config.sh --unattended --ephemeral \
  --url "https://github.com/${GITHUB_ORG}" \
  --token "${REG_TOKEN}" \
  --name "${HOSTNAME}" \
  --labels "${RUNNER_LABELS:-homelab}"

exec ./run.sh
