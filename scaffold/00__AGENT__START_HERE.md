# AI 助手入口 · 从这里开始

你是协助维护本项目的 Agent。执行规则见 [[AGENT__workflow_rules_for_ai]]；原则见 [[AGENT__core_mindset]]。

## 开始工作

1. 查看 `ls -F .`；若项目使用 Git，再查看 `git status --short`。不要覆盖或丢弃用户已有改动。
2. 查阅与当前任务直接相关的记忆、约定、实现和设计。任务清楚时直接做；只有不同理解会实质改变结果时才提问。

## 常用位置

| 需要 | 位置或命令 |
|---|---|
| 项目目的与边界 | `10__ALWAYS_LOAD_FIRST/project_purpose_and_boundary.md` |
| 项目特定编码约定 | 可选文件 `10__ALWAYS_LOAD_FIRST/coding_conventions_project_specific.md`；模板见源码仓库的 `templates/project/` |
| 术语 | `10__ALWAYS_LOAD_FIRST/domain_terminology_glossary.md`，仅在需要时 |
| 当前状态、未完成任务、待裁决问题 | `20__EDIT_BEFORE_SESSION_END/` 中对应文件 |
| 设计文档 | 项目选择的设计文档目录；没有约定时可使用 `design/` |
| 搜索文件名引用 | `rg -nF '[[ADR__example' .` |
| 人类原始资料 | 可选位置 `human-source/`；默认不读取、不编辑、不移动，只有用户明确要求时才读取 |

目录名前缀用于分组，不规定任务步骤或读取顺序。`10__ALWAYS_LOAD_FIRST/` 表示优先从这里查项目规则，不表示全量读取；`20__EDIT_BEFORE_SESSION_END/` 只在跨会话信息变化时更新。自解释文件名保留类型前缀及简洁主题或结论；标题与文件名对应，文档间使用 `[[文件名]]` 引用。

## 不可越过的边界

- 不覆盖或丢弃用户已有改动。
- 高影响动作按 [[AGENT__workflow_rules_for_ai]] 的授权规则执行。
- 不把推测写成已确认事实；未运行的检查不得报告为通过。

`human-source/` 是可选约定，不由安装器创建。其他位置的人类资料遵循用户指定的路径和读取要求；不自行扫描或修改。
