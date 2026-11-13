# agent-coldstart-scaffold

面向单人开发者的 Agent 协作工作流脚手架。

一次安装，为 Agent 提供入口、工作规则、协作方式和轻量持久记忆。按不确定性决定调查和计划，按后果决定授权，按变更范围决定验证。设计模板单独存放，需要时再取用。

## 核心主张

- **规则管判断题，机制管是非题。** 是否需要设计记录、是否值得授权，是判断题，写在规则里；链接是否悬空、ADR 状态是否合法、看板是否引用了已解决的问题，是是非题，交给 `lint`。
- **人类是队友，不只是审批者。** 人类时间有价格，但 `sudo`、GUI 点击、登录授权、凭据和品味判断对人是几秒、对 Agent 可能是长时间绕路。Agent 应在两次尝试后直接求助。
- **日志先写，整理后蒸馏。** 每个任务结束机械地写一条会话日志，不做“值不值得记”的判断；判断推迟到 compaction，那时证据齐全。日志同时是观察这套工作流是否有效的仪器。
- **列表即索引。** 任何会被工具列出的东西——文件名、提交信息、测试名、日志条目——都应在列表中自解释。文件名是稳定的 ID，文件前几行是可 grep 的元数据，正文才是权威。
- **程序目录是必检项，而且先写计划。** 每次会话先 `ls -R 30__PROCEDURES/`，在 journal 的 `## Procedure plan` 里对每个候选写 `read` / `defer` / `skip` 和理由，再写一行 `Task type → procedure` triage；不能只挑最像的那一个。所有 `read` 必须在第一次编辑前读完。行为或正确性任务必须读 `turn-the-problem-into-math`；bug/回归必须读 `fix-the-cause-not-the-symptom`；已有代码库的行为修改还必须读 `map-the-existing-system-first`、`pin-the-behavior-before-you-change-it`、`make-the-smallest-diff-that-works`、`write-tests-that-can-fail`；改共享契约必须读 `know-what-else-uses-it`。
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
  TOOLS__tool-registry.md                   外部工具登记、版本、校验和与 gate 决策
30__PROCEDURES/                             做某类事时读取，按语境分目录
  00__GENERAL/                              任何项目都可能用到
    AGENT__procedure__write-down-the-adr.md
    AGENT__procedure__fix-the-cause-not-the-symptom.md         调试、根因定位与系统性影响分析
    AGENT__procedure__write-tests-that-can-fail.md             测试风险排序、回归测试与 test-strength audit
    AGENT__procedure__turn-the-problem-into-math.md
    AGENT__procedure__you-have-tools-and-rules.md              外部工具的提出、安装、验证、gate 与退役
    AGENT__procedure__cicd-pipeline.md
    AGENT__procedure__docker-configuration.md
    AGENT__procedure__git-discipline.md
    AGENT__procedure__writing-user-manual.md
    AGENT__procedure__go-engineering.md
    AGENT__procedure__rust-engineering.md
    AGENT__procedure__c-cpp-engineering.md
    AGENT__procedure__latex-authoring.md
    AGENT__procedure__find-the-ui-design-language.md
    AGENT__procedure__go-find-evidence-and-do-some-research.md
    AGENT__procedure__long-form-writing.md
    AGENT__procedure__coworkers-are-working-in-parallel-dont-mess-it-up.md
    AGENT__procedure__read-the-paper.md
    AGENT__procedure__when-ending-the-task.md
    AGENT__procedure__tidy-the-journal.md
    AGENT__procedure__check-before-you-ship.md
  10__STARTING_A_NEW_PROJECT/               从零开始一个项目
    AGENT__procedure__first-day-on-the-project.md
  20__TAKING_OVER_A_LEGACY_PROJECT/         接手已有代码
    AGENT__procedure__map-the-existing-system-first.md         旧系统运行地图：入口、数据流、契约、构建/测试/部署、历史与 fork 基线
    AGENT__procedure__pin-the-behavior-before-you-change-it.md 先用 golden/record-replay/契约测试固定旧行为，再改代码
    AGENT__procedure__know-what-else-uses-it.md                跨 surface 的调用方、兼容承诺与覆盖率矩阵
    AGENT__procedure__make-the-smallest-diff-that-works.md     最小可行 diff，保留无关 API、风格与错误文本
    AGENT__procedure__fork-an-open-source-project.md           开源 fork 的 upstream 选择、许可、补丁账本与发布约束
    AGENT__procedure__keep-the-fork-in-sync.md                 上游基线、补丁清单、选择性 port 与本地契约验证
    AGENT__procedure__change-it-without-breaking-callers.md    兼容契约、迁移/弃用/回滚，不破坏旧调用方
40__MEMORY/                                 写入层
  journal/                                  每任务一条会话日志
  tasks/                                    并行任务领取（TASK__）
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

## 程序计划

任务开始时，Agent 先在 journal 写 `## Procedure plan`，再调查或编辑。计划从两个轴出发：

- 任务形态：bug/回归、行为变更、重构、新功能、公开契约/迁移、事故、文档、评审。
- 仓库语境：新项目、已有/陌生代码库、共享组件、测试薄弱、fork/upstream、生产路径。

每条候选程序写 `read` / `defer` / `skip` 和一句理由。`skip` 只有在触发条件明确不存在时才允许；不确定写 `defer`，并写清楚什么观察能决定。所有 `read` 必须在第一次编辑前读完。计划里先回答一组是非题：已有代码库？行为变更？共享组件？测试薄弱？fork/upstream？公开契约？生产路径？bug/回归？commit/branch？每个 `yes` 都触发 `AGENT__rules` 的强制默认，并标成 `read`。已有代码库里的行为修改，默认强制读 `map-the-existing-system-first`、`pin-the-behavior-before-you-change-it`、`make-the-smallest-diff-that-works`、`write-tests-that-can-fail`；bug/回归还强制 `fix-the-cause-not-the-symptom`、`turn-the-problem-into-math`；共享组件、fork、公开契约、生产路径各有默认。计划随新证据更新，不能只列最像的那一个。failure-surface matrix 必须从 `know-what-else-uses-it` 的接口/注册表清单开始，而不是从怀疑的表面开始。

## 测试

`write-tests-that-can-fail` 是验证环节的入口。它不追求测试数量，先按后果排序：数据丢失、静默错误、关键流程失败优先；再看边界、状态变化、恢复和高频路径。

硬规则：

- 证明修复的新测试必须在修改前失败；修改前就通过的测试不是回归测试。固定现状的 characterization test 另行记录，不用它冒充回归测试。
- 断言完整可观察契约，不用 `assertIn` 或存在性代理；顺序、字段、错误、状态都要精确。
- 用仓库里最复杂的真实 payload / fixture，不自己编最小例子。
- 结束前写 test-strength audit：断言了什么、没断言什么、什么失败仍可能漏过。

## 旧项目维护

新项目和旧项目的起手不同。新项目先确定目的、边界和命令；旧项目先重建“它今天怎么运行”的证据，再动代码。若项目本身是开源 fork，先用 `fork-an-open-source-project` 建立 `FORK__` 记录、确认 upstream 与许可，再进入下面的维护闭环。`30__PROCEDURES/20__TAKING_OVER_A_LEGACY_PROJECT/` 按维护闭环组织：

1. `map-the-existing-system-first`：入口、数据流、契约、构建/测试/部署、历史与 fork 基线。
2. `pin-the-behavior-before-you-change-it`：先用 golden master、record/replay 或契约测试固定现状。
3. `know-what-else-uses-it`：列出调用方、兼容承诺、每个 surface 的覆盖状态。
4. `make-the-smallest-diff-that-works`：最小改动，保留无关 API、风格、错误文本和日志格式。
5. `keep-the-fork-in-sync`：有 upstream 时，记录基线、选择性 port、验证本地契约。
6. `change-it-without-breaking-callers`：改公开契约时，设计迁移、弃用和回滚。

`fix-the-cause-not-the-symptom` 负责修 bug 的因果追踪；它的 failure-surface matrix 是第 3 步在调试场景下的强制版本。

## 开源 fork 维护

在他人开源项目上做长期修改，不是“clone 后改代码”，而是一个有独立生命周期的衍生项目。工作流用设计文档目录（默认 `design/`）中的 `FORK__<upstream>.md` 记录唯一真相源，并在改动前先回答四个问题：

- 是否真的需要 fork：配置、插件、构建期 patch 或上游 PR 是否足够？
- fork 谁：原始仓库、活跃继任者，还是某个 vendor 分支？必须 pin 到 tag 或完整 commit。
- 许可义务是什么：SPDX 许可证、版权与 notice、GPL/AGPL 源码提供、商标与命名限制。
- 采用哪种模型：`patch-stack`、`periodic-merge`、`hard-fork` 或 `successor-tracking`。

`FORK__` 至少记录 upstream URL、pinned ref、upstream 状态、许可证、fork 模型、本地发布版本、最近同步日期和同步节奏；补丁清单一行一个可回滚 patch，记录本地 commit、上游来源、理由、影响面、测试和状态（`active` / `upstreamed` / `obsolete` / `blocked`）。没有进入清单的本地修改，在下次同步时等于不存在。

同步时按 `keep-the-fork-in-sync` 执行：先分类上游变更和本地补丁，再按 fork 模型选择 rebase 或 merge，使用 `git range-diff` / `cherry-pick -x` 保留来源，最后同时跑上游测试、本地契约测试和构建/发布冒烟。干净 merge 不等于行为兼容；上游测试也不能替代本地契约测试。

发布 fork 产物前走 `check-before-you-ship`：版本号要能看出上游基线，产物要带许可证与 notice，GPL/AGPL 要满足源码提供义务，二进制要有校验和，更新说明要区分上游变更与本地补丁，并明确安全公告的跟踪者。

以 Clash 为例：`Dreamacro/clash` 的公开仓库已在 2023 年删除/归档，许可证是 GPL-3.0。fork 它之前必须先决定是跟踪活跃继任者，还是接受 hard fork 并自己承担安全修复；同时把 YAML 配置、规则语法、代理协议、external controller API 和 dashboard 兼容性当作本地契约固定下来。代理工具还会接触凭据和流量，日志与遥测不能当作普通数据。

## 协作模式

Agent 与人的互动密度由模式控制，默认值写在目标项目的 `20__PROJECT_CONTEXT/project_conventions.md`，未填写时回退到 Autopilot。模式只改变提问频率和汇报节奏，不改变授权红线。

| 模式 | 人类状态 | 行为 |
|---|---|---|
| Copilot | 在场 | 每个可验证步骤后汇报；授权灰区倾向于问 |
| Autopilot | 离开 | 尽量走完；阻塞写入待裁决文件而不是等待；结束时一次性汇报 |
| Advisor | 正在决策 | 只分析建议，不改文件 |

同一阻塞点（权限、环境、网络、工具缺失）尝试两次仍未解决时，Agent 应停止绕路，用一条消息说明卡在哪、请人做什么、做完后告诉它什么。求助是正确行为，不是失败。

## 会话日志与整理

每个任务在 `40__MEMORY/journal/` 写一个文件，文件名是 `YYYY-MM-DD-HHMM__主题.md`，例如 `2026-11-10-1430__fix-login-redirect-loop.md`。`ls` 该目录就是项目时间线。

任务开始时先写头部（`Mode`、`Task`、`Procedures: pending`），并先 `ls -R 30__PROCEDURES/`、写 `## Procedure plan`（每条候选 `read` / `defer` / `skip` + 理由），再读所有 `read` 程序；任务结束时把 `Procedures` 补成 `[[程序]] — read — 理由` / `[[程序]] — skipped — 理由`，或 `none`（仅纯文档或单文件琐碎修改），再补全 `Did`、`Verified`、`Blocked`、`Touched`、`Next`。有 `Task` 而没有 `Did` 的条目意味着上个会话中断，下一个会话应优先读它。日志与代码、ADR、现状文件冲突时，以代码和 ADR 为准。

`journal/` 超过 20 条或用户要求整理时，按 `AGENT__procedure__tidy-the-journal.md` 执行 compaction：把持久事实蒸馏进现状、任务板、ADR 和待裁决文件，写一个 `SUMMARY__<起>_to_<止>.md`，删除原始条目（Git 保留历史），并向人类报告统计——中断次数、未验证次数、求助次数与类型、平均尝试次数。这些统计是判断这套工作流是否真的有效的依据。

## 研究与长文

`50__RESEARCH/` 是研究证据与长文层，独立于会话记忆：

- `50__RESEARCH/sources/SOURCE__<id>.md`：一个来源一个文件，全项目共享、只追加；记录出处、访问日期、版本、方法与局限。
- `50__RESEARCH/<topic>/RESEARCH__<question>.md`：问题契约、检索记录、证据表、结论与置信度。开头先写“支持哪个决策、什么证据算够、何时停止”。
- `50__RESEARCH/<topic>/REPORT__<title>.md`：面向读者的长文，引用 `RESEARCH__` 与 `SOURCE__`。

研究不是每个任务的必经阶段，只在决策依赖外部证据时触发。学术调研与技术调研共用同一结构，区别在证据标准：前者看同行评审、方法与复现，后者优先官方文档、源码、可复现的 benchmark 或 spike。程序见 `30__PROCEDURES/00__GENERAL/AGENT__procedure__go-find-evidence-and-do-some-research.md` 与 `AGENT__procedure__long-form-writing.md`。

## 并行会话

并行只按写入集合拆分：两个 session 会写同一个文件时，串行。约定如下：

- 一个 session 一个 worktree、一个分支；worktree 放在项目根目录之外，否则 `lint` 会把副本当成同名知识库。
- 开始编辑前写 `40__MEMORY/tasks/TASK__<id>.md`，记录 `Owner`、`Status`、`Branch`、`Scope`、`Started`。
- 共享文件——入口、规则、项目约定、`project_state_now.md`、`task_board.md`、`open_questions_for_human.md`、已接受的 ADR——只由集成 session 写。
- 并行模式下日志文件名追加 `--<owner>`，避免同分钟碰撞。
- 集成 session 一次合并一个分支，每合一个重跑 `lint` 与相关测试；不要最后一次性合并。

完整规则见 `30__PROCEDURES/00__GENERAL/AGENT__procedure__coworkers-are-working-in-parallel-dont-mess-it-up.md`。

## 工具层

工具层分两层：框架定义基线能力、能力类别、登记表 schema、生命周期和治理规则；项目在 `20__PROJECT_CONTEXT/TOOLS__tool-registry.md` 登记实际使用的第三方工具。框架不硬编码具体第三方工具，`clangd`、`gopls`、`rust-analyzer`、TLC 都只是项目条目。

基线能力——`lint.sh`/`lint.ps1`、`bash`/`pwsh`、`git`、`ls`/`find`/`grep`，以及可选的 `rg`（没有时回退 `grep`）——不进入登记表。只有项目引入或替换的第三方工具才登记；LSP、语言分析器、模型检查器和证明助手没有基线，必须先登记。

每个工具条目记录：

| 字段 | 作用 |
|---|---|
| `Category` | 能力槽位，例如 `nav.lsp`、`analyze.static`、`verify.model` |
| `State` | `candidate`、`declared`、`installed`、`verified`、`retired` |
| `Version` / `Provenance` / `License` | 精确版本、来源、许可证；禁止 `latest` |
| `Install` / `Invoke` / `Smoke` | 安装、调用、冒烟验证命令 |
| `Mode` / `Scope` | `advisory` 或 `gate`；`local`、`ci` 或 `both` |
| `Data` | `local`、`downloads` 或 `uploads` |
| `Checksum` | 下载件用 `sha256:`，包管理器用 `package-manager:<lockfile>` |
| `Decision` | `gate` 条目，以及 `declared` 及以上的 `uploads` 条目，必须链接至少一条 Accepted ADR |
| `Last verified` | 最后一次冒烟通过的日期 |

只有 `verified` 条目才能用于任务；只有 `verified` 且链接了 Accepted ADR 的工具才能升为 `gate`。`Data: uploads` 的条目在进入 `declared` 前必须链接 Accepted ADR，并且每次外发仍受 `AGENT__rules` 的授权约束。工具二进制不提交进仓库，放在 `.tools/`（已加入 `.gitignore`）。

`TOOLS` 是新增的知识类型，登记表文件名为 `TOOLS__tool-registry.md`。完整设计、反例与边界见 [`docs/TOOLING_DESIGN.md`](docs/TOOLING_DESIGN.md)，操作程序见 `30__PROCEDURES/00__GENERAL/AGENT__procedure__you-have-tools-and-rules.md`。

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
| `L10-research-metadata` | ERROR | `RESEARCH__*.md` 缺少唯一的 `- Question:`、合法 `- Status:` 或 `- As of:` |
| `L11-source-metadata` | ERROR | `SOURCE__*.md` 缺少合法 `- Type:`、`- Citation:`/`- URL:` 或 `- Accessed:` |
| `L12-task-claim` | ERROR | `TASK__*.md` 缺少唯一的 `- Status:`、`- Owner:`、`- Branch:`、`- Scope:` 或 `- Started:` |
| `L13-task-board-reference` | ERROR | 任务板引用的 `TASK__*` 在 `40__MEMORY/tasks/` 中没有对应文件 |
| `L14-tools-registry` | ERROR | `TOOLS__*.md` 缺少头部字段，或条目缺少/重复必填字段；`installed`/`verified` 缺 `Checksum`，`verified` 缺 `Smoke`/`Last verified`；版本不得为 `latest`、范围或通配 |
| `L15-tools-gate` | ERROR | `gate` 未处于 `verified`，`gate` 或 `declared` 及以上的 `uploads` 未链接 Accepted ADR，或 `retired` 仍为 `gate` |
| `L16-fork-record` | ERROR | `FORK__*.md` 缺少唯一必填字段；upstream ref 是移动引用或不是版本 tag/完整 commit；upstream/successor 仍是示例地址；status/model 非法或互相矛盾；补丁行缺列、commit/状态/理由/来源/影响面/测试不合法 |

代码块与行内代码中的示例链接不参与 L1/L2，因此可以安全地在文档中展示 `[[name]]` 的写法。退出码：`0` 无错误，`1` 有错误，`2` 参数或环境错误。

## 按需使用模板

模板位于仓库的 `templates/`，不属于默认安装资产：`decisions/`、`feature/`、`contracts/`、`data-models/`、`operations/`、`research/`、`tasks/`、`tooling/`、`fork/` 与四类 `diagrams/`。只在确有需要时复制到合适位置，删除不适用的小节，并改成与内容匹配的文件名和标题。例如，`source_dir` 使用前文创建的源码目录：

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

版本识别的依据是目标 `00__AGENT__START_HERE.md` 第一行的标记（例如 `<!-- agent-coldstart-scaffold entry v7.6.0 -->`）与源码根目录的 `VERSION`。两者不一致时，Agent 按 `UPGRADING.md` 的版本说明逐段升级。

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

Agent 读取的文件（`scaffold/`、`templates/`、启动指引、安装器输出）使用英文，以便与多数宿主的系统提示和指令遵循语言一致。README、CHANGELOG 和 `docs/` 使用中文。项目自身内容（项目目的、约定、术语、日志）跟随项目实际语言。用户自有、按中文调优的提示词程序（如 `AGENT__procedure__read-the-paper.md`）保留中文原文。

## 设计文档

`docs/` 中保存 v2、v3 的设计存档，以及 v6 的执行规划 [`docs/V6_PLAN.md`](docs/V6_PLAN.md)，仅供参考。工具层设计见 [`docs/TOOLING_DESIGN.md`](docs/TOOLING_DESIGN.md)。当前工作流以 `scaffold/10__ALWAYS_LOAD/` 与本 README 为准。

## License

MIT，见 [`LICENSE`](LICENSE)。
