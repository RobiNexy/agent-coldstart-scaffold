# Changelog

重要变更记录。每次发布前更新对应版本条目。

## 6.2.0 — 2026-11-11

### Added

- `50__RESEARCH/`：研究证据与长文层。`sources/SOURCE__<id>.md` 一个来源一个文件，`<topic>/RESEARCH__<question>.md` 记录问题契约与综合，`<topic>/REPORT__<title>.md` 承载长文成品。
- 新增默认程序 `AGENT__procedure__research.md`：先定义决策、证据标准与停止条件，再检索、抽取证据、综合；覆盖学术与技术两种证据剖面。
- 新增默认程序 `AGENT__procedure__long-form-writing.md`：先搭论证图，再分遍起草，最后做引用完整性检查。
- 新增知识类型 `SOURCE`、`RESEARCH`、`REPORT`，入口类型表与 `lint` 允许列表同步。
- 新增模板 `templates/research/_TEMPLATE__RESEARCH.md`、`_TEMPLATE__SOURCE.md`、`_TEMPLATE__REPORT.md`。
- `lint` 新增 `L10-research-metadata` 与 `L11-source-metadata`，两种实现与夹具同步。

### Changed

- 入口新增 `50__RESEARCH/` 位置行，以及 research / long-form-writing 两个触发项。
- README 新增“研究与长文”章节，并补充研究层目录说明与 lint 检查项。

## 6.1.0 — 2026-11-11

### Added

- `UPGRADING.md`：Agent 执行的升级清单，覆盖版本识别、新增/改动文件分类、本地修改合并、旧路径清理、验证与收尾；不依赖新代码。
- 新增默认程序 `AGENT__procedure__formal-problem-solving.md`：把计算问题先放进合适的数学结构，再按框架选择、形式化陈述、交叉论证、反例优先、落地与独立校验展开。
- 新增默认程序 `AGENT__procedure__cicd-pipeline.md`：沿“提交 → 构建 → 验证 → 制品 → 部署 → 观测 → 回滚”定位 CI/CD 问题，优先检查可复现性、可观测性与可逆性。
- 新增默认程序 `AGENT__procedure__docker-configuration.md`：把 Dockerfile 与 compose 视为“干净检出 → 可验证运行”的残留物，按构建期、运行期与环境三层划分边界。
- 新增默认程序 `AGENT__procedure__git-discipline.md`：按历史的风险层级（本地未共享、共享分支、已发布引用）组织建议，先确认可逆性再操作。
- 新增默认程序 `AGENT__procedure__writing-user-manual.md`：按读者目标组织手册，步骤可字面执行并附带可观察结果。
- 新增默认程序 `AGENT__procedure__go-engineering.md`：围绕 goroutine/channel 所有权、context 传播与错误语义组织 Go 工程判断。
- 新增默认程序 `AGENT__procedure__rust-engineering.md`：先把问题读成所有权图，再处理语法与 API，避免用克隆或 `unsafe` 绕过借用检查。
- 新增默认程序 `AGENT__procedure__c-cpp-engineering.md`：区分代码意图、标准授权与平台实际行为，优先排查未定义行为与生命周期问题。
- 新增默认程序 `AGENT__procedure__latex-authoring.md`：按源码意图 / 引擎行为 / 宏包交互三层定位问题，只处理日志中的第一条真实错误。
- 新增默认程序 `AGENT__procedure__design-language.md`：先把对象还原为可证伪的设计语法，再把每条规则映射到可替换参数与实现代码。
- 新增默认程序 `AGENT__procedure__paper-reading.md`：按“核心骨架 → 机制展开 → 批判分析”三层讲解论文，术语首现即定义，被跳过的推导必须恢复或标注原文缺失。该文件按用户要求保留中文。
- 根目录 `VERSION` 文件，作为当前脚手架版本的唯一来源；入口标记同步为 `<!-- agent-coldstart-scaffold entry v6.1.0 -->`。
- CI 校验 `VERSION` 与入口标记一致；Release 校验 tag 与 `VERSION` 一致。

### Changed

- README “升级”章节改为指向 `UPGRADING.md`，只保留人工要点，减少两处说明漂移。
- `AGENT__bootstrap-instruction.md` 增加判断：目标项目已有旧版本时，先按 `UPGRADING.md` 升级，而不是只重跑安装器。

## 6.0.0 — 2026-11-10

与 5.x 的资产结构不兼容。安装器只补齐新文件并对旧版路径输出 LEGACY 警告；升级步骤见 README“升级”。

### Changed

- 哲学修正：规则只约束判断题，可机械检查的性质交给 `lint`；人类被建模为能力不同的队友而非仅审批者。
- 目录重构为 `10__ALWAYS_LOAD/`（每次全读，保持小）、`20__PROJECT_CONTEXT/`、`30__PROCEDURES/`（按需程序）、`40__MEMORY/`。
- 控制 Agent 行为的全部文件（`scaffold/`、`templates/`、启动指引、安装器输出）改为英文；README、CHANGELOG、docs 保持中文。
- 规则文件拆分：原则（为什么）、规则（怎么做）、协作、沟通；ADR 程序独立成文并定义“接受”的最低形式、Rejected 改名规则。
- 项目编码约定从可选模板升格为默认资产 `project_conventions.md`，新增环境识别、Git 工作方式、默认协作模式。
- 自解释文件名升格为核心原则（Listing-first），明确允许的类型前缀集合与“名字不得误导只看列表的人”。

### Added

- `AGENT__collaboration.md`：能力地图、挣扎预算（同一阻塞两次后求助）、Copilot/Autopilot/Advisor 模式。
- `AGENT__communication.md`：回复语言、带默认值的提问、结束报告格式。
- 会话日志 `40__MEMORY/journal/`：每任务一文件，任务开始写头、结束补全；compaction 程序蒸馏为永久记忆并产出统计。
- 程序文件：首个会话、生产就绪检查。
- `AGENTS.md` 宿主钩子，随安装器写入；已存在时提示追加一行。
- `lint.sh` / `lint.ps1` 知识库检查：悬空链接、标题与文件名、ADR 状态、看板引用、未完成日志等。
- 安装器识别旧版残留路径与旧入口文件并输出 LEGACY 警告。
- CI 新增 lint 夹具测试、安装器新行为测试与常驻规则词数预算。

### Removed

- `templates/project/`（已升格为默认资产）。
- `10__ALWAYS_LOAD_FIRST/`、`20__EDIT_BEFORE_SESSION_END/` 目录名及 `AGENT__core_mindset.md`、`AGENT__workflow_rules_for_ai.md` 文件名。

## 5.0.0 — 2026-11-09

与 4.x 的资产结构不兼容。安装器只补齐新文件，不会删除旧文件；升级后请按下方说明手动清理。

### Changed

- 控制 Agent 行为的文档统一使用 `AGENT__` 类型前缀：入口改为 `00__AGENT__START_HERE.md`，启动指引改为 `AGENT__bootstrap-instruction.md`，心法与规则改为 `AGENT__core_mindset.md`、`AGENT__workflow_rules_for_ai.md`；项目资料、领域资料和会话记忆不使用该前缀。安装器不会删除旧文件，升级后需手动清理 v4.1.0 的旧入口与规则文件。
- 工作流改为按影响、可逆性和外部副作用调整设计、授权与验证强度；不再要求每项任务全量加载上下文或执行固定三绿门禁。
- 保留类型前缀和自解释文件名，明确标题与文件名对应；设计模板与 Mermaid 图按需使用。
- 会话状态、任务板和待裁决事项仅在对应信息变化时更新。
- ADR 可由 Agent 起草；人类明确接受具体结论后才接受决策及其取代关系。
- 默认资产不再创建业务代码、人类资料或设计目录；可选模板移至 `templates/`，按需复制。
- ADR 使用自解释主题文件名，不再要求分配流水号；明确状态流转和取代记录方式。
- README 将“把仓库链接交给当前项目 Agent”作为主安装路径，并提供可执行的跨平台启动流程。
- 初始化指引改为最少必要步骤，不再要求完整访谈、填满模板或自动提交 Git。
- 链接启动改为显式确定工作区根目录、验证源码来源并报告源码版本；临时克隆自动清理，安装器不再隐式初始化 Git。
- 明确 ADR 替代结论需单独获批、元数据与决策正文的冻结边界，并补充问题 ID 唯一性、人类原始资料和质量属性约定。
- 文档说明安装器遇到路径冲突时可能已写入部分无冲突文件；处理冲突后重跑即可继续补齐。

### Fixed

- 修复 Bash 安装器在目标目录不存在时错误信息丢失目标路径的问题。

### Added

- 新增安装器 CI，在 Linux、macOS 和 Windows 上验证安装、校验、幂等性及错误与冲突处理。

## 4.1.0 — 2026-10-17

全新重写，与 3.x 的资产结构不兼容；不提供迁移路径。

### Changed

- 目录结构改为数字序号分层：`00__AGENT_START_HERE.md`、`10__ALWAYS_LOAD_FIRST/`、`20__EDIT_BEFORE_SESSION_END/`、`30__DECISION_AND_DESIGN_ARE_EXPENSIVE/`、`40__CODING_IS_CHEAP/`、`50__HUMAN_SOURCE_DO_NOT_EDIT/`。
- 新增心法总纲 `core_mindset.md`，心法直接体现在目录名上。
- 新增 `50__STRUCTURAL_DESIGNS/`，包含 SEQUENCE、STATE、DATAFLOW、MODULE 四类 Mermaid 结构性设计模板。
- Mermaid 图表统一规范，见工作流规则第七节。
- ADR 的一切动作（新建、状态变更、取代关系）均需人类拍板；已 Accepted 的 ADR 内容字段冻结。
- 三绿门禁（类型、测试、Lint）作为任务完成的硬标准。

### Removed

- 能力包与路由表机制，以及激活日志。能力包改由人类在 `50__HUMAN_SOURCE_DO_NOT_EDIT/capability-primers/` 中手动引用。
- 版本戳与版本校验。安装器不再读取或比较版本，`--version` 选项与 `installed-at` 行均已移除。
- `human_files/` 入口，由 `50__HUMAN_SOURCE_DO_NOT_EDIT/` 取代。

## 3.1.0 — 2026-10-14

### Added

- 新增 `human_files/` 人类原始材料入口，并为按需读取、来源引用及低 token 大段文本搬移增加约定。

## 3.0.0 — 2026-09-30

### Added

- 新增人类维护的能力包路由说明和激活日志（LLM 会话时追加、熵增整理时归档）；不附带或生成能力包正文。
- 新增仅支持 PowerShell 7.x（`pwsh`）的 Windows 安装器，与 Bash 安装器保持幂等安装和只读校验语义。
- 将入口与会话规则改为能力激活，明确路由确认、无匹配回路和包所有权。
- 将类型检查、测试、lint 设为三绿门禁，并要求测试意图块通过 `@spec` 回链规格。
- 加入跨语言类型法则、能力日志观测与能力总结落盘规则。

## 2.0.0 — 2026-09-29

### Added

- 建立多文件仓库结构，以 `scaffold/` 作为安装到目标项目的资产树。
- 提供幂等安装器、只读文件存在性校验，以及按 Git tag 自动构建并发布 release tarball 的 GitHub Actions 工作流。
- 加入 AI 会话启动指引、7 个 onboarding 文件与 5 个知识模板。
- 统一使用 `[[文件名]]` 知识引用，并规定通过 ripgrep（`rg`）分析影响面。
