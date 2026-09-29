# 给 AI 助手的项目导航（新会话必读）

## 你的角色

你协助单人开发者维护本项目。人类提供高层意图与关键决策；你负责生成、修改规格、代码、测试，并维护 `agent-knowledge/` 下的知识文档。

## 开始工作前，按顺序读

1. `agent-knowledge/onboarding/project-purpose-and-scope.md`
2. `agent-knowledge/onboarding/current-project-state.md`
3. `agent-knowledge/onboarding/task-board.md`
4. `agent-knowledge/onboarding/workflow-rules-for-ai-agent.md`
5. `agent-knowledge/onboarding/domain-terminology-glossary.md`

读完后向人类简报当前状态（1–2 句）和 In Progress 任务，然后问：“今天继续做哪个任务，还是有新需求？”

## 遇到具体问题时，去哪找

| 要做什么 | 去处 |
|---|---|
| 加/改功能 | `agent-knowledge/feature-specifications/` |
| 加/改 API | `agent-knowledge/api-contracts/` |
| 改数据结构 | `agent-knowledge/data-model-specifications/` 与相关 ADR |
| 查询设计理由 | `agent-knowledge/architectural-decision-records/` |
| 部署/排障 | `agent-knowledge/operations-runbook/` |
| 查编码约束 | `agent-knowledge/onboarding/coding-conventions-project-specific.md` |
| 术语不清 | `agent-knowledge/onboarding/domain-terminology-glossary.md` |
| 需要人拍板 | 追加到 `agent-knowledge/onboarding/open-questions-awaiting-human.md` |
| 影响面分析 | 使用 ripgrep（`rg`）：`rg -n -F '[[文件名' .`，包括代码意图块 |

## 硬规则

- 改代码时同步相关功能规格与测试。
- 不违反已有 ADR，除非人类明确要求并记录取代决策的新 ADR。
- 项目知识引用统一使用 `[[文件名]]`；代码路径用行内代码。
- 每次会话结束前执行 `workflow-rules-for-ai-agent.md` 中的会话结束协议。

## 不确定时

优先向人类澄清；人类暂不可用时，把问题写入 open questions 并暂停受影响的决策。
