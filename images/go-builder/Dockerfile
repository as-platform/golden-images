FROM golang:1.23-bookworm

# renovate: datasource=github-releases depName=golangci/golangci-lint
ARG GOLANGCI_LINT_VERSION=v1.61.0
# renovate: datasource=go depName=golang.org/x/vuln
ARG GOVULNCHECK_VERSION=v1.1.3

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates git make \
 && rm -rf /var/lib/apt/lists/*

RUN export GOBIN=/usr/local/bin GOMODCACHE=/tmp/gomod GOCACHE=/tmp/gocache \
 && go install "github.com/golangci/golangci-lint/cmd/golangci-lint@${GOLANGCI_LINT_VERSION}" \
 && go install "golang.org/x/vuln/cmd/govulncheck@${GOVULNCHECK_VERSION}" \
 && go clean -modcache \
 && rm -rf /tmp/gomod /tmp/gocache

RUN useradd -m -u 10001 builder \
 && mkdir -p /home/builder/go /home/builder/.cache \
 && chown -R builder:builder /home/builder

ENV CGO_ENABLED=0 \
    GOFLAGS=-trimpath \
    GOPATH=/home/builder/go \
    GOMODCACHE=/home/builder/go/pkg/mod \
    GOCACHE=/home/builder/.cache/go-build

USER builder
WORKDIR /src

LABEL org.opencontainers.image.source="https://github.com/as-platform/golden-images"
