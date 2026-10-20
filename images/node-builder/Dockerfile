FROM node:22-bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates git \
 && rm -rf /var/lib/apt/lists/* \
 && corepack enable

ENV NPM_CONFIG_UPDATE_NOTIFIER=false

USER node
WORKDIR /src

LABEL org.opencontainers.image.source="https://github.com/as-platform/golden-images"
