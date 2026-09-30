# agent-coldstart-scaffold

单人全栈项目的 AI Native 工作流脚手架（v3）。

一次安装，让新开的 LLM 会话快速接手项目：读取固定入口、简报项目状态，再从任务看板继续工作。

## 它解决什么问题

单人 + Coding Agent 开发时，主要成本往往不是写代码，而是每次会话重新解释项目、需求/规格/代码逐渐漂移，以及人类无法逐项阅读 Agent 的全部产出。

本脚手架用入口文件、启动盘、任务看板、ADR、统一 `[[文件名]]` 引用和会话结束协议，帮助项目保持自解释。

## 快速开始

**新项目**

```bash
git clone https://github.com/RobiNexy/agent-coldstart-scaffold /tmp/acs
mkdir -p /path/to/your-new-project
bash /tmp/acs/install.sh /path/to/your-new-project
```

**Windows（仅 PowerShell 7 / `pwsh`）**

```powershell
git clone https://github.com/RobiNexy/agent-coldstart-scaffold "$env:TEMP\acs"
New-Item -ItemType Directory -Force -Path 'C:\path\to\your-new-project' | Out-Null
pwsh -File "$env:TEMP\acs\install.ps1" -TargetDir 'C:\path\to\your-new-project'
```

**让 Agent 安装**

发布版本后，从 [GitHub Releases](https://github.com/RobiNexy/agent-coldstart-scaffold/releases) 下载 release.tar.gz 并放入项目根目录，解压后将其中的 `agent-bootstrap-instruction.md` 发给 Agent。成功安装后不要把压缩包提交到项目，可删除或加入 `.gitignore`。

**已有项目补装**

```bash
git clone https://github.com/RobiNexy/agent-coldstart-scaffold /tmp/acs
bash /tmp/acs/install.sh /path/to/existing-project
```

Windows 下将目标目录传给 PowerShell 安装器：

```powershell
git clone https://github.com/RobiNexy/agent-coldstart-scaffold "$env:TEMP\acs"
pwsh -File "$env:TEMP\acs\install.ps1" -TargetDir 'C:\path\to\existing-project'
pwsh -File "$env:TEMP\acs\install.ps1" -Verify -TargetDir 'C:\path\to\existing-project'
```

安装器幂等运行：已存在的文件不会覆盖，新资产会补齐。已有 `.gitignore` 时请人工合并所需条目。`--verify` 检查必需路径是否为文件，并仅对版本戳首行做提示性比较；不会校验其他文件内容，用户对资产的修改会保留。版本戳记录首次安装版本；重跑不会改写版本戳，因此新旧版本不同时 `--verify` 会持续提示基线版本差异。

## 安装后你会得到

```text
AI-AGENT-START-HERE.md              # Agent 的唯一入口
agent-knowledge/
├── onboarding/                     # 状态、看板、规则、术语与悬决问题
├── capability-prompts/             # 人类维护的能力路由与激活日志
├── feature-specifications/         # 功能规格与模板
├── api-contracts/                  # API 契约与模板
├── data-model-specifications/      # 数据模型与模板
├── architectural-decision-records/ # ADR 与模板
└── operations-runbook/             # 运维手册与模板
```

能力包正文由人类通过元提示词工作流制作和维护；脚手架只提供路由说明与激活日志，不附带、生成或格式化能力包。LLM 对能力包及路由表只读；激活日志常态追加，熵增整理时按规则压缩归档。

## 环境要求

- Unix 安装器：Bash 3.2+ 与常见 Unix 工具。
- Windows 安装器：PowerShell 7.x（`pwsh`，建议最新 7.x）；不支持 Windows PowerShell 5.1、其他主版本或 `.bat`。
- 若目标目录尚未处于 Git 工作区且系统有 Git，安装器会初始化 Git 仓库。
- 发版：推送符合版本戳的 `v*` tag，由 GitHub Actions 自动构建 tar.gz 并创建 GitHub Release。
- 知识库搜索：使用 ripgrep（`rg`）。macOS 可用 `brew install ripgrep` 安装。

## 命令参考

```bash
bash /tmp/acs/install.sh /path/to/project          # 安装（幂等，不覆盖已有文件）
bash /tmp/acs/install.sh --verify /path/to/project # 只读校验安装完整性
git tag v3.0.0 && git push origin v3.0.0           # 版本戳与 CHANGELOG 已提交后触发自动发版
```

Windows PowerShell 7.x（建议使用最新 7.x）：

```powershell
pwsh -File .\install.ps1 -TargetDir 'C:\path\to\project'
pwsh -File .\install.ps1 -Verify -TargetDir 'C:\path\to\project'
pwsh -File .\install.ps1 -ShowVersion
```

## 核心机制

1. **冷启动**：Agent 读 START-HERE 和 onboarding 必读文件，简报项目状态。
2. **能力激活**：任务明确后按人类维护的路由表加载能力包；激活须确认，日志可观测。
3. **验证门禁**：类型检查、测试和 lint 三绿；测试通过 `@spec` 回链到规格。
4. **统一引用**：文档、代码和测试意图块使用 `[[文件名]]`；搜索统一使用 ripgrep（`rg`）。
5. **会话结束协议**：更新状态、看板、激活日志和决策记录，减少上下文丢失。
6. **人机接口**：人类提供高层意图、关键裁决、变更 review，以及能力包与路由表。

## 设计文档

见 [`docs/AI-native-single-developer-workflow-v3.md`](docs/AI-native-single-developer-workflow-v3.md)（v3 设计存档）。

发布历史见 [`CHANGELOG.md`](CHANGELOG.md)。

## 发版

先更新 `CHANGELOG.md` 和 `scaffold/agent-knowledge/scaffold-version.txt`，将两者提交并推送；版本戳首行必须与 tag 去掉 `v` 后一致。随后推送 tag，例如 `git tag v3.0.0 && git push origin v3.0.0`。`.github/workflows/release.yml` 会校验版本、从 tag 对应提交创建带 `agent-coldstart-scaffold/` 顶层目录的 tar.gz，并自动创建或更新 GitHub Release。

## License

MIT，见 [`LICENSE`](LICENSE)。
