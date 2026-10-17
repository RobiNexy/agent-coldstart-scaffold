# Changelog

重要变更记录。每次发布前更新对应版本条目。

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
