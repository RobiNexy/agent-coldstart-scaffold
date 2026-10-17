# 项目编码约定

> 本文件是代码层面的约定。设计层面的约束见 `30__DECISION_AND_DESIGN_ARE_EXPENSIVE/` 与 [[workflow_rules_for_ai]]。
> 技术栈确定后，本文件中的具体工具名需由人类确认并替换。

---

## 一、类型定律

- 类型检查器必须处于最严格模式（TODO：填入具体配置，如 `strict: true`）
- 禁止 `any`（TypeScript）、无类型注解的公共函数（Python）等逃逸类型的写法
- 外部输入（HTTP、文件、消息）在边界处做类型校验，内部逻辑信任类型
- 确需例外时，遵循 [[workflow_rules_for_ai]] 的"禁止压制告警"条款

---

## 二、测试定律

- 测试文件必须回链规格：在测试的描述或文件头写 `@spec [[FEATURE__<功能名>]]`
- 新增行为先写或同步更新测试，再写实现
- 修 bug 必须补回归测试
- 覆盖率不作为门禁指标；门禁是"每条规格至少有一条测试回链"
- 查看某规格的测试覆盖：`rg -l -F "[[FEATURE__xxx" 40__CODING_IS_CHEAP/tests/`

---

## 三、意图块

每个核心模块文件顶部写意图块。字段含义如下：

| 字段 | 必需 | 含义 |
|---|---|---|
| `@purpose` | 是 | 一句话说明本模块做什么 |
| `@invariants` | 是 | 必须始终成立的约束 |
| `@spec` | 是（有对应规格时） | 指向功能规格 |
| `@adr` | 否 | 指向相关 ADR |
| `@sequence` | 否 | 指向关键时序图 |
| `@state` | 否 | 指向关联状态机图 |
| `@touches` | 否 | 指向修改时需要一并考虑的其他设计 |

示例（TypeScript）：

```typescript
/**
 * @purpose 处理订单创建：库存扣减，订单落库，发起支付
 * @invariants
 *   - 订单创建原子性：要么完整成功，要么完全回滚
 *   - 库存扣减先于订单落库
 * @spec [[FEATURE__<功能名>]]
 * @adr [[ADR__NNNN-<结论>]]
 * @sequence [[SEQUENCE__<场景名>]]
 * @state [[STATE__<实体名>-lifecycle]]
 */
```

意图块中的 `[[]]` 引用须能被 `rg -nF` 检索到，因此不得拼写错误。

---

## 四、注释定律

只保留三类注释：

1. **why 注释**：解释反直觉选择的理由
2. **TODO / FIXME**：需要跟进的事项，须能对应到 `open_questions_for_human.md` 或 `task_board.md`
3. **意图块**：见第三节

**禁止**：
- 复述代码行为
- 版本历史（交给 git）
- ASCII 分隔线
- 同义反复的 docstring
- 没有测试覆盖的注释（注释与行为脱节时，以测试为准）

密度不均匀是预期：核心业务高，领域模型中，CRUD 极低，胶水代码近零。

---

## 五、引用格式

- 文档之间、代码意图块中：`[[<文件名>]]`，不带路径、不带扩展名
- 文档指向代码：行内代码，如 `` `40__CODING_IS_CHEAP/src/features/order/service.ts` ``
- 代码之间：语言原生 import
- 禁用：Obsidian 的别名、嵌入语法、块引用、标签

---

## 六、命名

- 文件名主体：小写加连字符，如 `place-order-with-inventory-lock.ts`（代码文件的命名以语言惯例为准，此处不强制）
- 设计文件：类型前缀加连字符，如 `FEATURE__`、`ADR__0003-`、`SEQUENCE__`
- 临时代码：下划线前缀目录，如 `src/_scratch/`、`src/_experiment-<名称>/`。这类目录豁免意图块与设计引用要求，但禁止被生产代码引用
- 不确定一段代码能否活过本周：放 `_scratch/`，不必纠结

---

## 七、目录约定

- `40__CODING_IS_CHEAP/src/`：生产代码
- `40__CODING_IS_CHEAP/tests/`：测试
- `40__CODING_IS_CHEAP/e2e-scenarios/`：端到端场景
- `40__CODING_IS_CHEAP/src/_scratch/`：临时验证，见第六节
