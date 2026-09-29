#!/usr/bin/env bash
# 打包 release.tar.gz（维护者用）
# 用法: bash scripts/make-release.sh <version>   如 2.0.1
# 产出: dist/agent-coldstart-scaffold-<version>.tar.gz
set -euo pipefail

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
  echo "用法: $0 <version，如 2.0.1>" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_NAME="$(basename "$REPO_ROOT")"

mkdir -p "${REPO_ROOT}/dist"

# 从父目录打包，天然带顶层目录；GNU tar 与 BSD tar 均支持 --exclude。
cd "${REPO_ROOT}/.."
tar czf "${REPO_ROOT}/dist/${REPO_NAME}-${VERSION}.tar.gz" \
  --exclude="${REPO_NAME}/.git" \
  --exclude="${REPO_NAME}/dist" \
  "${REPO_NAME}"

echo "产出: dist/${REPO_NAME}-${VERSION}.tar.gz"
echo ""
echo "提醒: 版本号已写入 scaffold/agent-knowledge/scaffold-version.txt，记得提交。"
echo "上传: gh release create v${VERSION} dist/${REPO_NAME}-${VERSION}.tar.gz"
