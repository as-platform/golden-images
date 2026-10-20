FROM ubuntu:24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# renovate: datasource=github-releases depName=actions/runner extractVersion=^v(?<version>.*)$
ARG RUNNER_VERSION=2.321.0
# renovate: datasource=github-releases depName=sigstore/cosign
ARG COSIGN_VERSION=v2.4.1
# renovate: datasource=github-releases depName=aquasecurity/trivy extractVersion=^v(?<version>.*)$
ARG TRIVY_VERSION=0.57.0
# renovate: datasource=github-releases depName=anchore/syft extractVersion=^v(?<version>.*)$
ARG SYFT_VERSION=1.14.0
# renovate: datasource=github-releases depName=gitleaks/gitleaks extractVersion=^v(?<version>.*)$
ARG GITLEAKS_VERSION=8.21.2
# renovate: datasource=github-releases depName=hadolint/hadolint
ARG HADOLINT_VERSION=v2.12.0

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git jq tar unzip \
      buildah skopeo fuse-overlayfs uidmap \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1001 runner

WORKDIR /home/runner
RUN curl -fsSLO "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
 && tar xzf "actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
 && rm "actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
 && ./bin/installdependencies.sh \
 && rm -rf /var/lib/apt/lists/* \
 && chown -R runner:runner /home/runner

COPY --chmod=755 install-tools.sh /tmp/install-tools.sh
RUN /tmp/install-tools.sh && rm /tmp/install-tools.sh

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENV BUILDAH_ISOLATION=chroot \
    STORAGE_DRIVER=vfs

USER runner
ENTRYPOINT ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/as-platform/golden-images"
