#!/usr/bin/env bash
# =============================================================
# agent-coldstart-scaffold / install.sh
#
# 用途: 将 AI Native 工作流知识库脚手架安装到目标项目
# 特性: 幂等安装（永不覆盖）、只读校验、重跑补齐新增文件
# 版本戳: 记录首次安装版本；遵循永不覆盖，不随重跑更新
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

has_symlink_parent() {
  local rel_path="$1"
  local parent_rel current component
  case "$rel_path" in
    */*) parent_rel="${rel_path%/*}" ;;
    *) return 1 ;;
  esac

  current="$TARGET"
  while [ -n "$parent_rel" ]; do
    component="${parent_rel%%/*}"
    if [ "$parent_rel" = "$component" ]; then
      parent_rel=""
    else
      parent_rel="${parent_rel#*/}"
    fi
    current="${current}/${component}"
    [ -L "$current" ] && return 0
  done
  return 1
}

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
  bash install.sh /path/to/project               # 安装到目标项目
  bash install.sh --verify /path/to/project      # 校验目标项目
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
conflicts=0
total=0

# find 在进程替换中执行；NUL 分隔可安全处理包含空格的路径。
while IFS= read -r -d '' rel; do
  rel="${rel#./}"
  dst="${TARGET}/${rel}"
  total=$((total + 1))

  if [ "$MODE" = "install" ]; then
    if has_symlink_parent "$rel"; then
      echo "  CONFLICT ${rel}（父路径是符号链接，拒绝写出目标目录）" >&2
      conflicts=$((conflicts + 1))
    elif [ -f "$dst" ]; then
      echo "  SKIP    ${rel}"
      skipped=$((skipped + 1))
      if [ "$rel" = ".gitignore" ]; then
        echo "          └ 目标已有 .gitignore，请人工确认包含依赖/构建产物条目"
      fi
    elif [ -e "$dst" ] || [ -L "$dst" ]; then
      echo "  CONFLICT ${rel}（目标路径存在但不是普通文件，未覆盖）" >&2
      conflicts=$((conflicts + 1))
    else
      mkdir -p "$(dirname "$dst")" || die "无法创建目标目录: $(dirname "$dst")"
      cp "${SCAFFOLD_DIR}/${rel}" "$dst" || die "无法复制资产: ${rel}"
      echo "  OK      ${rel}"
      created=$((created + 1))
      if [ "$rel" = "$VERSION_FILE" ]; then
        printf 'installed-at: %s\n' "$(date +%F)" >> "$dst" \
          || die "无法写入安装日期: ${rel}"
      fi
    fi
  elif has_symlink_parent "$rel"; then
    echo "  MISSING ${rel}（父路径是符号链接）"
    missing=$((missing + 1))
  elif [ -f "$dst" ]; then
    present=$((present + 1))
  else
    echo "  MISSING ${rel}"
    missing=$((missing + 1))
  fi
done < <(cd "$SCAFFOLD_DIR" && find . -type f -print0)

if [ "$MODE" = "install" ]; then
  if [ "$conflicts" -gt 0 ]; then
    die "发现 ${conflicts} 个目标路径冲突；请先处理冲突后重跑安装器"
  fi

  if command -v git >/dev/null 2>&1 \
    && ! git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$TARGET" init -q || die "无法在目标目录初始化 git 仓库"
    echo "  OK      git 仓库已初始化"
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
  echo " 校验通过: ${present}/${total} 文件就位 ✓"
  if [ -f "${SCAFFOLD_DIR}/${VERSION_FILE}" ] && [ -f "${TARGET}/${VERSION_FILE}" ]; then
    local_ver="$(head -n 1 "${SCAFFOLD_DIR}/${VERSION_FILE}")"
    inst_ver="$(head -n 1 "${TARGET}/${VERSION_FILE}")"
    if [ "$local_ver" != "$inst_ver" ]; then
      echo " 版本提示: 当前资产 ${local_ver}, 项目记录的首次安装版本为 ${inst_ver}"
      echo "           安装器只补齐缺失文件，不覆盖已有文件；版本戳保留首次安装版本。"
    fi
  fi
  echo "============================================================"
  exit 0
fi

echo " 校验失败: ${present} 就位, ${missing} 缺失 ✗"
echo " 修复方法: 在脚手架目录重跑 bash install.sh '${TARGET}'"
echo "============================================================"
exit 1
