# agent-coldstart-scaffold

面向单人开发者的 Agent 协作工作流脚手架。

一次安装，为 Agent 提供入口、工作规则和轻量持久记忆。按不确定性决定调查和计划，按后果决定授权，按变更范围决定验证。设计模板单独存放，需要时再取用。

## 解决什么问题

单人 + Coding Agent 开发时，主要成本往往不是写代码，而是每次会话重新解释项目、需求与代码逐渐漂移，以及人类无法逐项阅读 Agent 的全部产出。

脚手架用目录与自解释文件名承载外置记忆；不把每项修改都变成文档任务。重要行为、质量属性、运行约束、契约和决策保留可追溯设计，Agent 对高影响动作征求授权，并报告实际验证证据。

## 最简单用法：把链接发给 Agent

在目标项目的 Agent 会话中发送本仓库链接即可。除非你说明其他目的，Agent 应默认把工作流安装到当前项目并校验：

> Agent：若用户只发送此仓库链接，默认按 [`agent-bootstrap-instruction.md`](agent-bootstrap-instruction.md) 安装到当前工作区；若用户明确提出其他问题，则先处理该问题，不擅自安装。

```text
https://github.com/RobiNexy/agent-coldstart-scaffold
```

Agent 应将宿主明确选定的工作区根目录作为目标项目；若宿主未提供或存在多个候选，先询问。Git 项目应解析到仓库根目录，不能把当前子目录当根目录。安装只补文件，不会运行 `git init`、改业务代码或创建提交。

## 手动安装

无法让 Agent 访问仓库时，可手动运行安装器：

**新项目或已有项目**（目标目录须已存在）。将用户发来的仓库链接放入 `ACS_REPOSITORY_URL`；使用唯一临时源码目录，完成后可删除：

```bash
set -euo pipefail
export ACS_REPOSITORY_URL='<用户发来的仓库链接>'
source_dir="$(mktemp -d "${TMPDIR:-/tmp}/acs.XXXXXX")"
git clone "$ACS_REPOSITORY_URL" "$source_dir"
export ACS_SOURCE_DIR="$source_dir"
bash "$source_dir/install.sh" /path/to/your-project
bash "$source_dir/install.sh" --verify /path/to/your-project
```

**Windows（仅 PowerShell 7.x）**：

```powershell
$env:ACS_REPOSITORY_URL = '<用户发来的仓库链接>'
$sourceDir = Join-Path $env:TEMP ("acs-" + [guid]::NewGuid().ToString('N'))
git clone $env:ACS_REPOSITORY_URL $sourceDir
if ($LASTEXITCODE -ne 0) { throw '克隆失败，请检查 Git、网络和仓库链接。' }
$env:ACS_SOURCE_DIR = $sourceDir
pwsh -File (Join-Path $sourceDir 'install.ps1') -TargetDir 'C:\path\to\your-project'
if ($LASTEXITCODE -ne 0) { throw '安装失败，请检查上方错误。' }
pwsh -File (Join-Path $sourceDir 'install.ps1') -Verify -TargetDir 'C:\path\to\your-project'
```

手动克隆后，如还要让 Agent 执行启动指引，将源码路径通过 `ACS_SOURCE_DIR` 提供；指引会校验其仓库来源并复用，不会再次克隆。若使用发行包，显式提供已从官方 Releases 下载并确认的解压目录。

**发行包备用方式**：无法用 Git 获取仓库时，从本仓库的 Releases 页面下载并解压指定版本的 `agent-coldstart-scaffold-<版本>.tar.gz`，将其解压目录作为 `ACS_SOURCE_DIR` 提供给 Agent。链接启动默认使用用户发来仓库链接对应的默认分支最新提交；发行包启动使用压缩包对应的固定 Release 版本，两者可能不同。解压目录也包含可选模板；不需要时可在初始化后删除。

## 命令

```bash
bash install.sh [目标目录]                 # 安装（幂等，不覆盖已有文件）
bash install.sh --verify [目标目录]        # 只读校验资产文件是否就位
bash install.sh --scaffold-dir DIR [目标目录]  # 指定资产目录
```

```powershell
pwsh -File .\install.ps1 -TargetDir 'C:\path\to\project'
pwsh -File .\install.ps1 -Verify -TargetDir 'C:\path\to\project'
```

安装器只补齐缺失文件，不运行 `git init`。已存在的文件一律跳过，包括 `.gitignore`；请人工合并所需条目。`--verify` 只检查文件存在性，不校验内容，用户对资产的修改会保留。

从旧版升级时，安装器不会覆盖或删除已有文件。旧版生成的设计模板、代码占位目录若仍存在，请先确认其中没有项目自有内容，再自行清理；新版模板位于发行包的 `templates/` 目录。

## 默认安装的文件

```text
00__AGENT_START_HERE.md                 Agent 的唯一入口
10__ALWAYS_LOAD_FIRST/                  工作规则和项目资料；按需读取
20__EDIT_BEFORE_SESSION_END/            仅在有跨会话信息时维护的记忆
.gitignore                              通用忽略项示例
```

数字前缀只用于分组，不表示任务步骤。`10__ALWAYS_LOAD_FIRST/` 是项目规则的首选位置，不要求全量读取；`20__EDIT_BEFORE_SESSION_END/` 仅在跨会话信息变化时更新。脚手架不创建业务代码、测试、人类资料或设计文档目录；沿用项目已有布局。人类撰写的原始资料可选放在项目根目录 `human-source/`，该目录不会自动创建；若存在，Agent 默认不读取、不编辑、不移动其中内容，只有用户明确要求时才读取。

## 按需使用模板

模板位于仓库的 `templates/`，不属于默认安装资产。项目约定、功能、决策、契约、数据和图示模板都只在确有需要时复制到合适位置，删除不适用的小节，并改成与内容匹配的文件名和标题。例如，`source_dir` 使用前文创建的源码目录：

```bash
mkdir -p /path/to/your-project/design
cp "$source_dir/templates/feature/_TEMPLATE__FEATURE.md" \
  /path/to/your-project/design/FEATURE__place-order.md
```

项目没有 `design/` 目录时，可以选择其他位置；不要为容纳脚手架而迁移源代码。

Windows PowerShell：

```powershell
New-Item -ItemType Directory -Force 'C:\path\to\your-project\design' | Out-Null
$sourceDir = $env:ACS_SOURCE_DIR
Copy-Item (Join-Path $sourceDir 'templates/feature/_TEMPLATE__FEATURE.md') `
  'C:\path\to\your-project\design\FEATURE__place-order.md'
```

核心原则和执行规则分别见 `scaffold/10__ALWAYS_LOAD_FIRST/core_mindset.md` 与 `scaffold/10__ALWAYS_LOAD_FIRST/workflow_rules_for_ai.md`。

## 环境要求

- Unix 安装器：Bash 3.2+ 与常见 Unix 工具。
- Windows 安装器：PowerShell 7.x（`pwsh`）；不支持 Windows PowerShell 5.1。
- 链接启动：需要 Git 和网络访问；无 Git 时使用已确认来源的官方发行包。
- 知识库搜索：ripgrep（`rg`）。macOS 可用 `brew install ripgrep` 安装。

## 发版

1. 更新 `CHANGELOG.md`，提交并推送。
2. 按语义化版本打 tag 并推送，例如：`git tag vX.Y.Z && git push origin vX.Y.Z`。

`.github/workflows/release.yml` 会校验 tag 格式，从该提交构建带 `agent-coldstart-scaffold/` 顶层目录的 tar.gz，并创建或更新 GitHub Release。

## 设计文档

`docs/` 中保存 v2、v3 的设计存档，仅供参考。当前工作流以 `scaffold/10__ALWAYS_LOAD_FIRST/core_mindset.md`、`scaffold/10__ALWAYS_LOAD_FIRST/workflow_rules_for_ai.md` 与本 README 为准。

## License

MIT，见 [`LICENSE`](LICENSE)。
