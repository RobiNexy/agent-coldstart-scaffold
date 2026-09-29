# Changelog

重要变更记录。每次发布前更新对应版本条目。

## 2.0.0 — 2026-09-29

### Added

- 建立多文件仓库结构，以 `scaffold/` 作为安装到目标项目的资产树。
- 提供幂等安装器、只读文件存在性校验，以及按 Git tag 自动构建并发布 release tarball 的 GitHub Actions 工作流。
- 加入 AI 会话启动指引、7 个 onboarding 文件与 5 个知识模板。
- 统一使用 `[[文件名]]` 知识引用，并规定通过 ripgrep（`rg`）分析影响面。
