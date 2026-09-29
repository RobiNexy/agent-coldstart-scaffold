# agent-coldstart-scaffold

单人全栈项目的 AI Native 工作流脚手架。

一次安装，让新开的 LLM 会话快速接手项目：读取固定入口、简报项目状态，再从任务看板继续工作。

## 它解决什么问题

单人 + Coding Agent 开发时，主要成本往往不是写代码，而是每次会话重新解释项目、需求/规格/代码逐渐漂移，以及人类无法逐项阅读 Agent 的全部产出。

本脚手架用入口文件、启动盘、任务看板、ADR、统一 `[[文件名]]` 引用和会话结束协议，帮助项目保持自解释。

## 快速开始

**新项目**

```bash
git clone https://github.com/<you>/agent-coldstart-scaffold /tmp/acs
mkdir -p /path/to/your-new-project
bash /tmp/acs/install.sh /path/to/your-new-project
```

**让 Agent 安装**

下载 release.tar.gz 并放入项目根目录，然后将仓库中的 `agent-bootstrap-instruction.md` 发给 Agent。

**已有项目补装**

```bash
bash install.sh .
```

安装器幂等运行：已存在的文件不会覆盖，新资产会补齐。已有 `.gitignore` 时请人工合并所需条目。

## 安装后你会得到

```text
AI-AGENT-START-HERE.md              # Agent 的唯一入口
agent-knowledge/
├── onboarding/                     # 状态、看板、规则、术语与悬决问题
├── feature-specifications/         # 功能规格与模板
├── api-contracts/                  # API 契约与模板
├── data-model-specifications/      # 数据模型与模板
├── architectural-decision-records/ # ADR 与模板
└── operations-runbook/             # 运维手册与模板
```

## 命令参考

```bash
bash install.sh .                         # 安装（幂等，不覆盖已有文件）
bash install.sh --verify .                # 只读校验安装完整性
bash scripts/make-release.sh 2.0.0        # 维护者：打包 release
```

## 核心机制

1. **冷启动**：Agent 读 START-HERE 和 onboarding 必读文件，简报项目状态。
2. **统一引用**：文档与代码意图块使用 `[[文件名]]`；搜索统一使用 ripgrep（`rg`），影响面可用 `rg -F '[[0003-' .` 查询。
3. **会话结束协议**：离场前更新状态、任务看板和决策记录，减少下个会话的上下文损失。
4. **人机接口**：人类主要 review 变更简报并裁决悬决问题。

## 设计文档

见 [`docs/AI-native-single-developer-workflow-v2.md`](docs/AI-native-single-developer-workflow-v2.md)。

## License

MIT。
