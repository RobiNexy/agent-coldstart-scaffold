#!/usr/bin/env bash
# =============================================================
# agent-coldstart-scaffold / install.sh
#
# 用途: 将 AI Native 工作流知识库脚手架安装到目标项目
# 特性: 幂等安装（永不覆盖）、只读校验、重跑补齐新增文件
# 环境要求: bash 3.2+ 与常见 Unix 工具
# 退出码: 0 成功 / 1 校验有缺失 / 2 参数或环境错误
# =============================================================
set -euo pipefail

VERSION_FILE="agent-knowledge/scaffold-version.txt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="2.0.0"
if [ -f "${SCRIPT_DIR}/scaffold/${VERSION_FILE}" ]; then
  VERSION="$(head -n 1 "${SCRIPT_DIR}/scaffold/${VERSION_FILE}")"
fi

die() { echo "错误: $*" >&2; exit 2; }

usage() {
  cat <<'USAGE'
用法: bash install.sh [选项] [目标目录]

目标目录须已存在，默认为当前目录。

选项:
  --verify            仅校验安装完整性，不写任何文件
  --scaffold-dir DIR  指定资产目录（默认: 脚本所在目录下的 scaffold/）
  --version           显示安装器版本
  -h, --help          显示本帮助

示例:
  bash install.sh .                              # 安装到当前项目
  bash install.sh --verify .                     # 校验当前项目
  bash ~/tools/agent-coldstart-scaffold/install.sh /path/to/project
USAGE
}

MODE="install"
SCAFFOLD_DIR="${SCRIPT_DIR}/scaffold"
POSITIONAL=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --verify) MODE="verify"; shift ;;
    --scaffold-dir)
      [ "$#" -ge 2 ] || die "--scaffold-dir 需要一个路径参数"
      SCAFFOLD_DIR="$2"
      shift 2
      ;;
    --version) echo "agent-coldstart-scaffold installer ${VERSION}"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    --*) die "未知选项: $1（见 --help）" ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

[ "${#POSITIONAL[@]}" -le 1 ] || die "最多接受一个目标目录参数"
TARGET="."
if [ "${#POSITIONAL[@]}" -eq 1 ]; then
  TARGET="${POSITIONAL[0]}"
fi

[ -d "$SCAFFOLD_DIR" ] || die "未找到资产目录: ${SCAFFOLD_DIR}
  请在解压后的 agent-coldstart-scaffold/ 内运行本脚本，
  或用 --scaffold-dir 显式指定。"

SCAFFOLD_DIR="$(cd "$SCAFFOLD_DIR" && pwd)"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" \
  || die "目标目录不存在: ${TARGET}（请先创建，本脚本不代建项目根目录）"

created=0
skipped=0
present=0
missing=0
version_just_created=0

# find 在进程替换中执行；NUL 分隔可安全处理包含空格的路径。
while IFS= read -r -d '' rel; do
  rel="${rel#./}"
  dst="${TARGET}/${rel}"

  if [ "$MODE" = "install" ]; then
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      echo "  SKIP    ${rel}"
      skipped=$((skipped + 1))
      if [ "$rel" = ".gitignore" ]; then
        echo "          └ 目标已有 .gitignore，请人工确认包含依赖/构建产物条目"
      fi
    else
      mkdir -p "$(dirname "$dst")"
      cp "${SCAFFOLD_DIR}/${rel}" "$dst"
      echo "  OK      ${rel}"
      created=$((created + 1))
      if [ "$rel" = "$VERSION_FILE" ]; then
        version_just_created=1
      fi
    fi
  elif [ -e "$dst" ] || [ -L "$dst" ]; then
    present=$((present + 1))
  else
    echo "  MISSING ${rel}"
    missing=$((missing + 1))
  fi
done < <(cd "$SCAFFOLD_DIR" && find . -type f -print0)

if [ "$MODE" = "install" ]; then
  if [ "$version_just_created" -eq 1 ]; then
    printf 'installed-at: %s\n' "$(date +%F)" >> "${TARGET}/${VERSION_FILE}"
  fi

  if [ ! -d "${TARGET}/.git" ] && command -v git >/dev/null 2>&1; then
    git -C "$TARGET" init -q && echo "  OK      git 仓库已初始化"
  fi

  echo ""
  echo "============================================================"
  echo " 安装完成: 新建 ${created} 个文件, 跳过 ${skipped} 个已存在文件"
  echo ""
  echo " 下一步: 将 agent-bootstrap-instruction.md 的内容发给你的 Agent"
  echo " 脚手架目录可删除；校验或补齐时重新下载并重跑安装器即可。"
  echo "============================================================"
  exit 0
fi

echo ""
echo "============================================================"
if [ "$missing" -eq 0 ]; then
  echo " 校验通过: ${present}/${present} 文件就位 ✓"
  if [ -f "${SCAFFOLD_DIR}/${VERSION_FILE}" ] && [ -f "${TARGET}/${VERSION_FILE}" ]; then
    local_ver="$(head -n 1 "${SCAFFOLD_DIR}/${VERSION_FILE}")"
    inst_ver="$(head -n 1 "${TARGET}/${VERSION_FILE}")"
    if [ "$local_ver" != "$inst_ver" ]; then
      echo " 版本提示: 当前脚手架 ${local_ver}, 项目内为 ${inst_ver}"
      echo "           重跑安装器只会补齐缺失文件，不会覆盖已有文件。"
    fi
  fi
  echo "============================================================"
  exit 0
fi

echo " 校验失败: ${present} 就位, ${missing} 缺失 ✗"
echo " 修复方法: 在脚手架目录重跑 bash install.sh '${TARGET}'"
echo "============================================================"
exit 1
