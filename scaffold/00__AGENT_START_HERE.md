# AI 助手必读 · 从这里开始

你是协助单人开发者维护本项目的 AI 助手。读完本文件，你应该知道如何在本项目工作。

---

## 四条心法（内化到每个动作）

1. **相信 ls，不要记忆**：工作流写在目录名里，迷茫就 `ls`
2. **设计昂贵，代码便宜**：改代码前必查、必更新对应设计
3. **文件名即结论**：看文件名就能定位信息，`rg` 即影响面分析
4. **人类是裁决者，不是打字员**：规格、代码、文档由你产出，关键裁决由人类做

完整展开见 [[core_mindset]]。

---

## 新会话启动三步

### 第一步：扫视地图

```bash
ls -F .
```

你应该看到：

```
00__AGENT_START_HERE.md
10__ALWAYS_LOAD_FIRST/
20__EDIT_BEFORE_SESSION_END/
30__DECISION_AND_DESIGN_ARE_EXPENSIVE/
40__CODING_IS_CHEAP/
50__HUMAN_SOURCE_DO_NOT_EDIT/
```

目录名就是指令。序号即动作顺序：先 10 后 20，设计 30 先于代码 40。

### 第二步：加载底座

读完 `10__ALWAYS_LOAD_FIRST/` 下的全部文件：

- `core_mindset.md`：心法总纲
- `project_purpose_and_boundary.md`：项目做什么、不做什么
- `workflow_rules_for_ai.md`：工作流细则（含三绿门禁、会话结束协议）
- `coding_conventions_project_specific.md`：项目特定代码约定
- `domain_terminology_glossary.md`：术语表

### 第三步：检查现状

读 `20__EDIT_BEFORE_SESSION_END/` 下三份文件：

- `project_state_now.md`：系统现在什么样
- `task_board.md`：接下来做什么（In Progress / Ready / Backlog）
- `open_questions_for_human.md`：什么等人类裁决

然后向人类简报：

```
我已加载项目上下文。
当前状态：[一句话]
In Progress 任务：[列表]
未决问题：[数量]
今天继续哪个任务，还是有新需求？
```

---

## 工作中遇到具体问题去哪找

| 情境 | 去处 |
|---|---|
| 查功能规格 | `ls 30__DECISION_AND_DESIGN_ARE_EXPENSIVE/10__FEATURES/` |
| 查架构决策 | `ls 30__DECISION_AND_DESIGN_ARE_EXPENSIVE/20__DECISIONS/` |
| 查 API 契约 | `ls 30__DECISION_AND_DESIGN_ARE_EXPENSIVE/30__CONTRACTS/` |
| 查数据模型 | `ls 30__DECISION_AND_DESIGN_ARE_EXPENSIVE/40__DATA_MODELS/` |
| 查时序 / 状态机 / 数据流 / 模块图 | `ls 30__DECISION_AND_DESIGN_ARE_EXPENSIVE/50__STRUCTURAL_DESIGNS/` |
| 查部署 / 运维 | `ls 30__DECISION_AND_DESIGN_ARE_EXPENSIVE/60__OPERATIONS/` |
| 查人类资料 / 人类指定的视角材料 | 仅当人类点名时读取，路径见下，只读 |
| 影响面分析 | `rg -nF "[[目标文件名"` |
| 卡住需要人类拍板 | 追加到 `20__EDIT_BEFORE_SESSION_END/open_questions_for_human.md` |

人类指定的视角材料位于 `50__HUMAN_SOURCE_DO_NOT_EDIT/capability-primers/`。这些材料只在人类明确点名时读取（例如"请参考 capability-primers/security-audit-perspective.md 来 review"），不自动加载，不自动路由。

---

## 常用 rg 命令

| 场景 | 命令 |
|---|---|
| 查某文件被哪些地方引用（含代码意图块） | `rg -nF "[[ADR__0003-use-redis"` |
| 查代码里的所有双链 | `rg -nF "[[" 40__CODING_IS_CHEAP/src/` |
| 查所有 TODO / FIXME | `rg -n "TODO\|FIXME"` |
| 查某术语在设计文档中的分布 | `rg -n "乐观锁" 30__DECISION_AND_DESIGN_ARE_EXPENSIVE/` |
| 列出所有意图块的 @spec 引用 | `rg -n "@spec \[\[" 40__CODING_IS_CHEAP/src/` |

统一使用 `rg`，不使用 `grep`。

---

## 硬规则

1. **改代码前必查设计**：读目标文件顶部意图块，顺着 `@spec` `@adr` `@sequence` `@state` 全部打开。设计需要变，先改设计，再改代码。
2. **代码变更必同步规格**：不许只改 `40__CODING_IS_CHEAP/` 而不动 `30__DECISION_AND_DESIGN_ARE_EXPENSIVE/`。
3. **ADR 的一切动作都需要人类拍板**：包括新建、状态变更、添加"被取代"关系。
4. **已 Accepted 的 ADR，内容字段永不修改**（背景、决策、理由、后果、触发重新评估条件）。决策要变，新建 ADR 并由人类裁决取代关系。
5. **禁止写入 `50__HUMAN_SOURCE_DO_NOT_EDIT/`**：该目录的内容完全由人类管理，LLM 只在人类点名时读取。
6. **引用一律用 `[[<文件名>]]`**：文档之间与代码意图块中。路径引用只用于文档指向代码（行内代码）。
7. **三绿门禁**：类型、测试、Lint 全部通过才算任务完成，详见 `workflow_rules_for_ai.md`。
8. **结束前执行会话结束协议**：检查并更新 `20__EDIT_BEFORE_SESSION_END/` 下的三份文件，再输出变更简报。

---

## 必须征求人类同意的动作

- 修改数据库 schema（删列、改类型）
- 对外 API 的破坏性变更
- 新建或修改 `30__DECISION_AND_DESIGN_ARE_EXPENSIVE/50__STRUCTURAL_DESIGNS/` 下的任何图
- 任何 ADR 相关动作（新建、状态变更、添加取代关系）
- 引入新的外部依赖
- 花钱、发邮件、生产环境的第三方调用
- 删除超过 3 个文件

---

## 可以自主执行

- 不影响对外接口的内部重构
- 增加测试、修复 bug（同时补回归测试）
- 更新 `20__EDIT_BEFORE_SESSION_END/` 下的任意文件
- 更新 `10__ALWAYS_LOAD_FIRST/domain_terminology_glossary.md`
- 在 `40__CODING_IS_CHEAP/src/_scratch/` 或 `_experiment-<名称>/` 等下划线前缀目录中做临时验证（豁免意图块与设计引用，但禁止被生产代码引用）

---

## 变更简报格式（每次会话结束输出给人类）

```
## 本次变更
- 影响：[功能]
- 规格：[[<规格名>]]
- 代码：N 个文件
- ADR：[[<ADR名>]]（如有，均待人类拍板）

## 三绿状态
- 类型：pass
- 测试：X passed, Y failed
- Lint：clean

## 需要你决策
- [ ] 问题描述（我暂选 X，理由 Y）

## 我不确定的部分
- ...

## 下一步
- task_board 已更新，建议下次从 [...] 开始
```

---

## 不确定时的默认行为

- 优先问人类，不要猜
- 人类不在，写入 `open_questions_for_human.md` 并暂停受影响的决策
- 迷茫就 `ls`

---

**你不需要记住该做什么。`ls` 会告诉你。**
