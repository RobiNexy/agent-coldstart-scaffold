# agent-coldstart-scaffold

面向单人开发者的 Agent 协作工作流脚手架。

一次安装，为 Agent 提供入口、工作规则、协作方式和轻量持久记忆。按不确定性决定调查和计划，按后果决定授权，按变更范围决定验证。设计模板单独存放，需要时再取用。

## v6 的核心主张

- **规则管判断题，机制管是非题。** 是否需要设计记录、是否值得授权，是判断题，写在规则里；链接是否悬空、ADR 状态是否合法、看板是否引用了已解决的问题，是是非题，交给 `lint`。
- **人类是队友，不只是审批者。** 人类时间有价格，但 `sudo`、GUI 点击、登录授权、凭据和品味判断对人是几秒、对 Agent 可能是长时间绕路。Agent 应在两次尝试后直接求助。
- **日志先写，整理后蒸馏。** 每个任务结束机械地写一条会话日志，不做“值不值得记”的判断；判断推迟到 compaction，那时证据齐全。日志同时是观察这套工作流是否有效的仪器。
- **列表即索引。** 任何会被工具列出的东西——文件名、提交信息、测试名、日志条目——都应在列表中自解释。文件名是稳定的 ID，文件前几行是可 grep 的元数据，正文才是权威。
- **常驻规则真的常驻。** `10__ALWAYS_LOAD/` 每次会话全部加载，因此必须小：CI 强制它与入口合计不超过 3000 个英文词。

## 解决什么问题

单人 + Coding Agent 开发时，主要成本往往不是写代码，而是每次会话重新解释项目、需求与代码逐渐漂移，以及人类无法逐项阅读 Agent 的全部产出。

脚手架用目录与自解释文件名承载外置记忆；不把每项修改都变成文档任务。重要行为、质量属性、运行约束、契约和决策保留可追溯设计，Agent 对高影响动作征求授权，并报告实际验证证据。

## 最简单用法：把链接发给 Agent

在目标项目的 Agent 会话中发送本仓库链接即可。除非你说明其他目的，Agent 应默认把工作流安装到当前项目并校验：

> Agent：若用户只发送此仓库链接，默认按 [`AGENT__bootstrap-instruction.md`](AGENT__bootstrap-instruction.md) 安装到当前工作区；若用户明确提出其他问题，则先处理该问题，不擅自安装。

```text
https://github.com/RobiNexy/agent-coldstart-scaffold
```

Agent 应将宿主明确选定的工作区根目录作为目标项目；若宿主未提供或存在多个候选，先询问。Git 项目应解析到仓库根目录，不能把当前子目录当根目录。安装只补文件，不会运行 `git init`、改业务代码或创建提交。安装通过后，Agent 会读取目标项目的 `00__AGENT__START_HERE.md`；若项目检查命令仍为 `unknown`，会按首个会话程序**只起草、不擅自填写**。

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

**发行包备用方式**：无法用 Git 获取仓库时，从本仓库的 Releases 页面下载并解压指定版本的 `agent-coldstart-scaffold-<版本>.tar.gz`，将其解压目录作为 `ACS_SOURCE_DIR` 提供给 Agent。链接启动默认使用用户发来仓库链接对应的默认分支最新提交；发行包启动使用压缩包对应的固定 Release 版本，两者可能不同。解压目录也包含可选模板、`lint.sh` 与 `lint.ps1`；不需要时可在初始化后删除。

## 命令

```bash
bash install.sh [目标目录]                 # 安装（幂等，不覆盖已有文件）
bash install.sh --verify [目标目录]        # 只读校验资产文件是否就位
bash install.sh --scaffold-dir DIR [目标目录]  # 指定资产目录
bash lint.sh [--quiet] [目标目录]          # 知识库检查
```

```powershell
pwsh -File .\install.ps1 -TargetDir 'C:\path\to\project'
pwsh -File .\install.ps1 -Verify -TargetDir 'C:\path\to\project'
pwsh -File .\lint.ps1 -TargetDir 'C:\path\to\project'
```

安装器只补齐缺失文件，不运行 `git init`。已存在的文件一律跳过，包括 `.gitignore` 与 `AGENTS.md`；对 `AGENTS.md` 会打印需要人工追加的一行。`--verify` 只检查文件存在性，不校验内容，用户对资产的修改会保留。若检测到路径冲突（例如目标目录中存在同名目录或父路径是符号链接），安装器返回非零；无冲突的文件可能已经写入，处理冲突后重跑即可继续补齐。

安装器与校验还会检查旧版残留路径和旧入口文件，输出 `LEGACY` 警告，并以 `Legacy paths found: N` 汇总。警告不改变退出码。

## 默认安装的文件

```text
AGENTS.md                                   宿主钩子，只有一句指向入口
00__AGENT__START_HERE.md                    Agent 的唯一入口
10__ALWAYS_LOAD/                            每次会话全部加载，保持精简
  AGENT__principles.md                      为什么
  AGENT__rules.md                           怎么做
  AGENT__collaboration.md                   人类能力地图、挣扎预算、协作模式
  AGENT__communication.md                   输出方式
20__PROJECT_CONTEXT/                        项目事实，任务相关时读取
  project_purpose_and_boundary.md
  project_conventions.md                    命令、环境、Git、默认协作模式
  domain_terminology_glossary.md
30__PROCEDURES/                             做某类事时读取
  AGENT__procedure__adr.md
  AGENT__procedure__formal-problem-solving.md
  AGENT__procedure__cicd-pipeline.md
  AGENT__procedure__docker-configuration.md
  AGENT__procedure__git-discipline.md
  AGENT__procedure__writing-user-manual.md
  AGENT__procedure__go-engineering.md
  AGENT__procedure__rust-engineering.md
  AGENT__procedure__c-cpp-engineering.md
  AGENT__procedure__latex-authoring.md
  AGENT__procedure__design-language.md
  AGENT__procedure__paper-reading.md
  AGENT__procedure__task_end.md
  AGENT__procedure__compaction.md
  AGENT__procedure__first_session.md
  AGENT__procedure__production_readiness.md
40__MEMORY/                                 写入层
  journal/                                  每任务一条会话日志
  project_state_now.md
  task_board.md
  open_questions_for_human.md
50__RESEARCH/                               研究证据与长文
  sources/                                  一个来源一个文件（SOURCE__）
  <topic>/                                  RESEARCH__ 与 REPORT__
.gitignore                                  通用忽略项示例
```

数字前缀只用于分组，不表示任务步骤。控制 Agent 行为的文档统一使用 `AGENT__` 类型前缀；项目资料、领域资料和会话记忆不使用该前缀。`10__ALWAYS_LOAD/` 是真的每次全读，所以不要往里加内容；项目事实放 `20__PROJECT_CONTEXT/`，程序性步骤放 `30__PROCEDURES/`。

脚手架不创建业务代码、测试、文档或人类资料目录；沿用项目已有布局。人类撰写的原始资料可选放在项目根目录 `human-source/`，该目录不会自动创建；若存在，Agent 默认只读、引用来源、不编辑不移动，只有用户明确要求时才读取内容。

## 协作模式

Agent 与人的互动密度由模式控制，默认值写在目标项目的 `20__PROJECT_CONTEXT/project_conventions.md`，未填写时回退到 Copilot。模式只改变提问频率和汇报节奏，不改变授权红线。

| 模式 | 人类状态 | 行为 |
|---|---|---|
| Copilot | 在场 | 每个可验证步骤后汇报；授权灰区倾向于问 |
| Autopilot | 离开 | 尽量走完；阻塞写入待裁决文件而不是等待；结束时一次性汇报 |
| Advisor | 正在决策 | 只分析建议，不改文件 |

同一阻塞点（权限、环境、网络、工具缺失）尝试两次仍未解决时，Agent 应停止绕路，用一条消息说明卡在哪、请人做什么、做完后告诉它什么。求助是正确行为，不是失败。

## 会话日志与整理

每个任务在 `40__MEMORY/journal/` 写一个文件，文件名是 `YYYY-MM-DD-HHMM__主题.md`，例如 `2026-11-10-1430__fix-login-redirect-loop.md`。`ls` 该目录就是项目时间线。

任务开始时先写头部（`Mode`、`Task`），任务结束时补全 `Did`、`Verified`、`Blocked`、`Touched`、`Next`。有 `Task` 而没有 `Did` 的条目意味着上个会话中断，下一个会话应优先读它。日志与代码、ADR、现状文件冲突时，以代码和 ADR 为准。

`journal/` 超过 20 条或用户要求整理时，按 `AGENT__procedure__compaction.md` 执行 compaction：把持久事实蒸馏进现状、任务板、ADR 和待裁决文件，写一个 `SUMMARY__<起>_to_<止>.md`，删除原始条目（Git 保留历史），并向人类报告统计——中断次数、未验证次数、求助次数与类型、平均尝试次数。这些统计是判断这套工作流是否真的有效的依据。

## 宿主集成

安装器会写入一个极薄的 `AGENTS.md`，内容是“先读 `00__AGENT__START_HERE.md` 并照做”。多数支持 `AGENTS.md` 的宿主会自动加载它。

若宿主读取其他文件，在对应文件里追加同一行即可，不需要复制规则正文：

- Claude Code：`CLAUDE.md`
- Cursor：`.cursorrules`
- GitHub Copilot：`.github/copilot-instructions.md`

若目标项目已有 `AGENTS.md`，安装器不会覆盖，只提示需要追加的那一行。

## 知识库检查

`lint.sh` / `lint.ps1` 只依赖 POSIX 工具或 PowerShell 7，不需要安装其他依赖。它检查：

| 代码 | 级别 | 检查 |
|---|---|---|
| `L1-dangling-link` | ERROR | `[[链接]]` 没有对应的 `.md` 文件 |
| `L2-ambiguous-link` | ERROR | 同名 `.md` 文件多于一个 |
| `L3-title-mismatch` | ERROR | 类型文件或日志条目的标题不等于文件名 |
| `L4-adr-status` | ERROR | ADR 缺少或有多个非法的 `- Status:` 行 |
| `L5-rejected-name` | ERROR | 已拒绝的 ADR 未按 `ADR__rejected__*` 命名，或反之 |
| `L6-orphan-question` | ERROR | 任务板引用了待裁决文件中不存在的 `Q-*` |
| `L7-incomplete-journal` | WARN | 日志有 `Task` 无 `Did`（中断或未收尾） |
| `L8-unknown-type` | WARN | 未知的类型前缀 |
| `L9-journal-count` | WARN | 原始日志超过 20 条，建议 compaction |

代码块与行内代码中的示例链接不参与 L1/L2，因此可以安全地在文档中展示 `[[name]]` 的写法。退出码：`0` 无错误，`1` 有错误，`2` 参数或环境错误。

## 按需使用模板

模板位于仓库的 `templates/`，不属于默认安装资产：`decisions/`、`feature/`、`contracts/`、`data-models/`、`operations/`、`research/` 与四类 `diagrams/`。只在确有需要时复制到合适位置，删除不适用的小节，并改成与内容匹配的文件名和标题。例如，`source_dir` 使用前文创建的源码目录：

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

## 升级

安装器不会覆盖或删除已有文件，所以升级不只是“重跑安装器”。完整流程写在 [`UPGRADING.md`](UPGRADING.md)，由 Agent 在目标项目中逐项执行：识别已安装版本 → 列出新增与已改动文件 → 安装器补齐新文件 → 合并本地修改 → 清理旧路径 → 运行 `--verify`、`lint` 与词数检查。

版本识别的依据是目标 `00__AGENT__START_HERE.md` 第一行的标记（例如 `<!-- agent-coldstart-scaffold entry v6.1.0 -->`）与源码根目录的 `VERSION`。两者不一致时，Agent 按 `UPGRADING.md` 的版本说明逐段升级。

从 v5 或 v4.1 升级时，人工要点：

1. 让 Agent 按 `UPGRADING.md` 执行，注意 `LEGACY` 行与 `Legacy paths found: N`。
2. 把旧 `20__EDIT_BEFORE_SESSION_END/` 中 `project_state_now.md`、`task_board.md`、`open_questions_for_human.md` 的内容搬到 `40__MEMORY/` 对应文件。
3. 把旧 `10__ALWAYS_LOAD_FIRST/` 中的项目目的、术语和编码约定搬到 `20__PROJECT_CONTEXT/`。
4. 用脚手架源码中的 `00__AGENT__START_HERE.md` 覆盖旧入口；确认新入口能读到 `10__ALWAYS_LOAD/`。
5. 确认迁移完成后再删除旧目录 `10__ALWAYS_LOAD_FIRST/`、`20__EDIT_BEFORE_SESSION_END/`，以及 v4.1 的 `00__AGENT_START_HERE.md`、`core_mindset.md`、`workflow_rules_for_ai.md`。
6. 重跑 `--verify` 与 `lint.sh`，确认无缺失、无悬空链接。

旧文件会保留到确认新入口和规则可用之后，避免两份规则并存。旧版生成的设计模板与代码占位目录若仍存在，请先确认其中没有项目自有内容，再自行清理；新版模板位于发行包的 `templates/` 目录。

## 环境要求

- Unix 安装器与 lint：Bash 3.2+ 与常见 POSIX 工具；`lint` 不需要 `rg`。
- Windows 安装器与 lint：PowerShell 7.x（`pwsh`）；不支持 Windows PowerShell 5.1。
- 链接启动：需要 Git 和网络访问；无 Git 时使用已确认来源的官方发行包。
- 知识库搜索：ripgrep（`rg`）是可选的便利工具，风格与 `[[文件名]]` 引用配合良好。macOS 可用 `brew install ripgrep` 安装。

## 发版

1. 更新 `CHANGELOG.md`，提交并推送。
2. 按语义化版本打 tag 并推送，例如：`git tag vX.Y.Z && git push origin vX.Y.Z`。

`.github/workflows/release.yml` 会校验 tag 格式，从该提交构建带 `agent-coldstart-scaffold/` 顶层目录的 tar.gz，并创建或更新 GitHub Release。

## 语言策略

Agent 读取的文件（`scaffold/`、`templates/`、启动指引、安装器输出）使用英文，以便与多数宿主的系统提示和指令遵循语言一致。README、CHANGELOG 和 `docs/` 使用中文。项目自身内容（项目目的、约定、术语、日志）跟随项目实际语言。用户自有、按中文调优的提示词程序（如 `AGENT__procedure__paper-reading.md`）保留中文原文。

## 设计文档

`docs/` 中保存 v2、v3 的设计存档，以及 v6 的执行规划 [`docs/V6_PLAN.md`](docs/V6_PLAN.md)，仅供参考。当前工作流以 `scaffold/10__ALWAYS_LOAD/` 与本 README 为准。

## License

MIT，见 [`LICENSE`](LICENSE)。
