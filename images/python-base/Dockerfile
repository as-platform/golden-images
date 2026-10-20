FROM python:3.11-slim-bookworm

# renovate: datasource=pypi depName=uv
ARG UV_VERSION=0.5.11

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && pip install "uv==${UV_VERSION}"

RUN useradd -m -u 10001 app
USER app
WORKDIR /app

LABEL org.opencontainers.image.source="https://github.com/as-platform/golden-images"
