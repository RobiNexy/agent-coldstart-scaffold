# agent-coldstart-scaffold

单人全栈项目的 AI Native 工作流脚手架（v4.1）。

一次安装，让新开的 LLM 会话快速接手项目：从 `00__AGENT_START_HERE.md` 进入，加载底座，读取当前状态，再从任务看板继续工作。

## 解决什么问题

单人 + Coding Agent 开发时，主要成本往往不是写代码，而是每次会话重新解释项目、需求与代码逐渐漂移，以及人类无法逐项阅读 Agent 的全部产出。

脚手架用目录结构承载工作流（相信 `ls`，不要记忆），用"设计昂贵，代码便宜"的分层让设计先于代码，用 `[[文件名]]` 双链与意图块保持可追溯。

## 快速开始

**新项目或已有项目**（目标目录须已存在）：

```bash
git clone https://github.com/RobiNexy/agent-coldstart-scaffold /tmp/acs
bash /tmp/acs/install.sh /path/to/your-project
```

**Windows（仅 PowerShell 7.x）**：

```powershell
git clone https://github.com/RobiNexy/agent-coldstart-scaffold "$env:TEMP\acs"
pwsh -File "$env:TEMP\acs\install.ps1" -TargetDir 'C:\path\to\your-project'
```

安装完成后，把 `agent-bootstrap-instruction.md` 的内容发给你的 Agent。

**让 Agent 安装**：从 [GitHub Releases](https://github.com/RobiNexy/agent-coldstart-scaffold/releases) 下载 `agent-coldstart-scaffold-<版本>.tar.gz` 放入项目根目录并解压，然后将解压后的 `agent-bootstrap-instruction.md` 发给 Agent。安装成功后，压缩包不应提交到项目，可删除或加入 `.gitignore`。

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

安装器只做两件事：补齐缺失文件，以及在目标目录不是 Git 仓库时执行 `git init`。已存在的文件一律跳过，包括 `.gitignore`；请人工合并所需条目。`--verify` 只检查文件存在性，不校验内容，用户对资产的修改会保留。

## 安装后的结构

```text
00__AGENT_START_HERE.md                 Agent 的唯一入口
10__ALWAYS_LOAD_FIRST/                  会话必读底座（心法、规则、约定、术语、项目边界）
20__EDIT_BEFORE_SESSION_END/            会话结束必更新（状态、任务板、待裁决问题）
30__DECISION_AND_DESIGN_ARE_EXPENSIVE/  设计资产与模板
│   ├── 10__FEATURES/                   功能规格
│   ├── 20__DECISIONS/                  ADR
│   ├── 30__CONTRACTS/                  API 契约
│   ├── 40__DATA_MODELS/                数据模型
│   ├── 50__STRUCTURAL_DESIGNS/         时序 / 状态机 / 数据流 / 模块图（Mermaid）
│   └── 60__OPERATIONS/                 运维手册
40__CODING_IS_CHEAP/                    代码、测试、端到端场景
50__HUMAN_SOURCE_DO_NOT_EDIT/           人类资料（LLM 只读，且仅在人类点名时读取）
    └── capability-primers/             人类手工维护的视角材料
```

模板文件以 `_TEMPLATE__` 开头，复制后改名为正式前缀（如 `FEATURE__`、`ADR__0001-`）。

## 设计原则

- 心法四条：相信 `ls`；设计昂贵，代码便宜；文件名即结论；人类是裁决者，不是打字员。
- 任务完成的硬标准是三绿门禁：类型检查、测试、Lint 全部通过。
- ADR 的一切动作都需要人类拍板；已 Accepted 的 ADR 内容字段冻结。
- 结构性设计使用 Mermaid，规范见 `10__ALWAYS_LOAD_FIRST/workflow_rules_for_ai.md` 第七节。

## 环境要求

- Unix 安装器：Bash 3.2+ 与常见 Unix 工具。
- Windows 安装器：PowerShell 7.x（`pwsh`）；不支持 Windows PowerShell 5.1。
- 知识库搜索：ripgrep（`rg`）。macOS 可用 `brew install ripgrep` 安装。

## 发版

1. 更新 `CHANGELOG.md`，提交并推送。
2. 打 tag 并推送：`git tag v4.1.0 && git push origin v4.1.0`。

`.github/workflows/release.yml` 会校验 tag 格式，从该提交构建带 `agent-coldstart-scaffold/` 顶层目录的 tar.gz，并创建或更新 GitHub Release。

## 设计文档

`docs/` 中保存 v2、v3 的设计存档，仅供参考。v4 设计以 `10__ALWAYS_LOAD_FIRST/core_mindset.md` 与本 README 为准。

## License

MIT，见 [`LICENSE`](LICENSE)。
