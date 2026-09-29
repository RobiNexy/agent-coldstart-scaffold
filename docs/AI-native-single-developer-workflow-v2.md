# AI Native 单人全栈项目工作流设计（v2）

> 版本：v2 设计概要（不是逐字存档）
> 适用：单人开发者 + Coding Agent（LLM）长期维护全栈项目

## v1 → v2 变更摘要

1. 所有 AI 文档收进 `agent-knowledge/`，根目录只留一个入口文件。
2. `[[文件名]]` 成为文档与代码意图块的统一知识引用格式。
3. 将项目状态、任务计划拆分为 `current-project-state.md` 与 `task-board.md`。
4. 规范代码意图块字段：`@purpose`、`@invariants`、`@spec`、`@adr`、`@touches`。
5. 将注释载体优先级、有效注释类型和注释密度策略纳入编码约定。

## 一、核心理念

单人 + LLM 的成本结构不同于多人团队：代码重写成本低，规格与决策更值得保留；文档的第一读者是 LLM；模块边界应以安全修改所需的上下文文件来判断；迭代粒度是对话级。

| 矛盾 | 应对 |
|---|---|
| 需求会变 | 规格锚定意图；按可逆性排优先级 |
| 人类带宽远小于机器带宽 | 分层视图、主动上报、决策点拦截 |
| 新会话没有记忆 | 项目自解释化，以固定入口冷启动 |

## 二、命名原则

1. 目录名说明用途，文件名表达结论；可以长，不能含糊。
2. 根入口与 `agent-knowledge/` 中的知识文件名组成全局唯一 ID，使用 kebab-case。
3. 禁止 snake_case、CamelCase、隐藏目录中的知识资产。
4. 唯一大写例外是根目录入口 `AI-AGENT-START-HERE.md`。

## 三、目录职责

```text
项目根/
├── AI-AGENT-START-HERE.md
├── agent-knowledge/
│   ├── onboarding/                    # 会话常读、常写的启动盘
│   ├── feature-specifications/        # 按需加载的功能规格
│   ├── api-contracts/                 # API 契约、错误码
│   ├── data-model-specifications/     # ER 图、表结构、数据生命周期
│   ├── architectural-decision-records/ # ADR
│   └── operations-runbook/            # 部署与排障
├── src/
├── tests/
└── e2e-scenarios/
```

知识只维护在 `agent-knowledge/`；代码通过意图块链接知识，不另设第二套文档来源。

## 四、统一引用 `[[...]]`

语法为 `[[filename]]` 或 `[[filename|显示文字]]`，不带路径和扩展名。目标必须唯一：知识文件在 `agent-knowledge/` 下，唯一的根目录例外是 `AI-AGENT-START-HERE.md`。文档到文档、代码到文档都用该格式；文档引用代码使用带路径的行内代码；代码到代码使用语言原生 import。

不使用 aliases、block references、embed 或标签。反向查找统一使用 ripgrep（`rg`）：

```bash
rg -n -F '[[0003-use-redis-optimistic-lock' AI-AGENT-START-HERE.md agent-knowledge/ src/
rg -n -F '[[' src/
```

文件重命名时全局更新引用；会话结束时检查本次涉及文件的悬空链接，整理时进行全量检查。模板中的 `[[相关文件名]]` 是占位符，实例化模板时必须替换为真实目标或删除。

## 五、代码意图块

源文件顶部维护简明意图块：

```typescript
/**
 * @purpose 处理订单创建：库存扣减 → 订单落库 → 发起支付
 * @invariants
 *   - 订单创建是原子操作：要么完整成功，要么完全回滚
 *   - 库存扣减必须先于订单落库
 * @spec [[feature-place-order-with-inventory-lock]]
 * @adr [[0003-use-redis-optimistic-lock-for-inventory]]
 * @touches [[feature-payment-callback-idempotency]]
 */
```

`@purpose` 与 `@spec` 必填；核心业务文件的 `@invariants` 必填；涉及决策时填写 `@adr`；存在非局部影响时填写 `@touches`。

## 六、状态、看板与悬决问题

| 文件 | 职责 | 时间视角 |
|---|---|---|
| `project-purpose-and-scope.md` | 项目为何存在、边界 | 长期 |
| `current-project-state.md` | 系统当前状况、稳定能力、技术债 | 现在 |
| `task-board.md` | 当前目标及后续工作 | 将来 |
| `open-questions-awaiting-human.md` | 需要人类裁决的问题 | 待定 |

任务粒度以一次会话可完成的垂直切片为宜；In Progress 上限为 2；Ready 任务必须自包含；不为短生命周期任务编号；Done 在整理时清空，git 历史负责归档。

## 七、工作流规则

每次会话按顺序：加载入口与必读上下文、澄清意图、起草或更新规格、先测试后实现、运行相关验证、执行会话结束协议。默认一次垂直切片尽量不超过 5 个文件。

会话结束前更新项目状态与任务看板；记录新 ADR 和未决问题；检查本次修改的引用；向人类输出 200–500 字变更简报。涉及破坏性 API 变更、数据库 schema、违反 ADR、新外部依赖、花费或生产环境三方调用、删除超过 3 个文件时，先征求人类意见。

## 八、编码约定与注释

表达同一意图时优先使用类型、测试、命名，再考虑 docstring 和内联注释。有效注释仅包括解释反直觉选择的 why 注释、非局部影响（优先放意图块 `@touches`）、TODO/FIXME 锚点。

禁止复述代码、记录版本历史、装饰性分隔线，以及没有测试支撑的行为承诺。核心业务逻辑注释可较密，CRUD 与胶水代码应少注释；若每几行就需要注释，应考虑重构。

## 九、人机接口与熵增管理

人类提供高层意图、关键裁决和简报 review；LLM 负责规格、实现与知识库维护。每 10 次会话、每周或人类提出整理时，检查过期问题、压缩状态、清理 Done、复核 ADR、扫描规格漂移与悬空链接、清理术语，并输出整理报告。

## 十、需验证的假设

- LLM 能否持续执行会话结束协议。
- 新会话能否在约 2 分钟进入状态。
- 简报与文件实际变更是否一致。
- In Progress 上限与 `[[...]]` 引用纪律能否长期执行。

若流程无法维持，可在实际出现问题后增加自动检查；避免过早引入 Git hook 或内容哈希系统。

## 十一、人机交互接口

人类主要提供三类输入：高层意图（对话或项目目的文件）、关键裁决（open questions 或 ADR）、变更简报 review。通常由 Agent 写规格和代码；紧急情况下人类直接修复后，由 Agent 反向同步规格。

| 层级 | 内容 | 主要读者 |
|---|---|---|
| L0 | 一句话状态 | 人类 |
| L1 | 200–500 字变更简报 | 人类 |
| L2 | 项目状态、看板、ADR 摘要 | 人机共读 |
| L3 | 完整规格、ADR、意图块 | LLM 为主 |
| L4 | 代码、测试、日志 | LLM |

## 十二、盲区与启动

- 多会话并发修改看板容易冲突，默认坚持单会话推进。
- 简报可能遗漏模型自身未意识到的风险，人类仍需抽查。
- 注释可能比代码承诺更多，需由测试验证。
- 纯文本 + ripgrep（`rg`）面向单人项目；若规模增长后确有瓶颈，再引入更强索引。
- 更换模型后重新观察工作流协议的遵守情况。
- 文档也服务于未来遗忘的自己，入口文件是冷启动的固定门牌。

新项目启动顺序：创建知识目录；起草入口和工作流规则；由人类填写目的与边界；建立状态、看板、悬决问题和术语文件；初始化并提交 git；验证新会话能正确简报；再开始最小垂直切片。人类必须原创的核心内容只有项目方向与边界、关键决策的裁决，其余可由 LLM 起草并经 review。

仓库发版时，更新并提交 CHANGELOG 与 `scaffold-version.txt`，推送与版本戳匹配的 `v*` tag；GitHub Actions 从 tag 对应提交生成带固定顶层目录的 release tarball 并发布 GitHub Release。
