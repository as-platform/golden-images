# golden-images

Базовые образы для CI и рантайма. Собираются на домашнем self-hosted раннере, пушатся в Zot, подписываются cosign, к ним прикладывается SBOM.

| Образ | Назначение | Теги |
|---|---|---|
| `golden/go-builder` | Сборка Go, golangci-lint, govulncheck | `stable`, `YYYYMMDD-sha` |
| `golden/node-builder` | Сборка на Node 22 (corepack) | `stable`, `YYYYMMDD-sha` |
| `golden/python-base` | Python 3.11 и uv | `stable`, `YYYYMMDD-sha` |
| `golden/runtime` | Distroless-рантайм | `go`, `node`, `python` (и `<вариант>-YYYYMMDD-sha`) |
| `golden/github-runner` | Эфемерный раннер Actions с buildah, skopeo, cosign, trivy, syft, gitleaks, hadolint | `stable`, `YYYYMMDD-sha` |

`python-base` намеренно на 3.11: `distroless/python3-debian12` содержит 3.11, а виртуальное окружение, собранное в builder-образе, должно совпадать с рантаймом.

## Пайплайн

`.github/workflows/build.yml` запускается на раннере `[self-hosted, homelab]`: сначала hadolint и gitleaks, затем для каждого образа вызывается reusable workflow `image-build.yml` из [ci-templates](https://github.com/as-platform/ci-templates) (`@main`): сборка, smoke-тест, Trivy (HIGH/CRITICAL, только исправимые), SBOM, push в Zot, подпись и attestation через cosign. Pull request'ы собирают и сканируют образы, но не пушат. Раз в неделю по расписанию всё пересобирается, чтобы подтянуть исправления базовых образов.

Необходимые настройки:

| Тип | Имя |
|---|---|
| переменная | `ZOT_REGISTRY` (хост без схемы) |
| секрет | `ZOT_USER`, `ZOT_PASSWORD` |
| секрет | `COSIGN_PRIVATE_KEY`, `COSIGN_PASSWORD` (`cosign generate-key-pair`) |

Под раннера должен доверять TLS-сертификату Zot.

## Bootstrap (только первый запуск)

Для workflow нужен образ раннера, а образ раннера собирается самим workflow. Первый образ пушится вручную:

```sh
docker build -t $ZOT_REGISTRY/golden/github-runner:stable images/github-runner
docker push $ZOT_REGISTRY/golden/github-runner:stable
```

После этого пайплайн собирает и пушит его сам.

## Примечания

- Только amd64.
- В раннере есть buildah, но нет docker: workflow собирают образы через `buildah build` в rootless-режиме, с изоляцией `chroot` и хранилищем `vfs`.
- Версия самого раннера не проверяется по контрольной сумме (GitHub публикует хэш только в заметках к релизу); остальные инструменты проверяются.
- Renovate обновляет дайджесты базовых образов, версии инструментов в `ARG` (помечены `# renovate:`) и дайджесты действий GitHub.
