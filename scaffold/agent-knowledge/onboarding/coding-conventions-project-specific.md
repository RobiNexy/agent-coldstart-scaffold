# 项目特定编码约定

> 只列反直觉或项目特定的规则。技术栈确认后，将严格模式等约束落实到仓库配置。

## 三道验证防线

类型（编译/静态期）> 测试（运行期）> 意图块（LLM 加载期）。三者各守一个验证时机、互不替代：类型表达不了行为，测试表达不了设计意图，意图块本身不能自动验证。

## 类型法则（语言无关）

1. **逃逸口 = 债务**：例如 TS `any`/`as`、Python 无注解函数、C `void*`、Go `interface{}`、Java raw type。必须使用时写明 why、添加 `TODO(types)`，并在变更简报报告。
2. **边界必验**：HTTP 入口、消息消费、事件 payload、数据库行等进程/模块边界必须有运行时 schema 验证（如 zod、pydantic、JSON Schema 或 ORM 验证）；验证失败即拒绝，不进入内部逻辑。
3. **非法状态不可表示**：优先使用 branded type、判别联合、newtype；例如状态枚举而非任意 string，金额用带单位的整数分而非裸 number。
4. **strict 工具链强制**：启用语言 strict 模式并把配置提交进仓库，例如 TypeScript `strict: true`、pyright/mypy strict、C/C++ `-Wall -Wextra`。
5. **类型是优先意图载体**：能进入类型系统的约束不重复写成注释；载体优先级为类型 > 测试 > 命名 > docstring > 内联注释。

## 测试法则

- 测试文件意图块必须含 `@spec [[规格文件名]]` 回链，可用 `rg -l -F '[[规格文件名' tests/` 查询覆盖关联。
- 规格的每条验收标准至少映射一个测试。
- 行为变化测试先行；测试名描述行为，不用方法名代替行为。

## 意图块

- 源文件 `@purpose`、`@spec` 必填；核心业务文件 `@invariants` 必填；涉及决策时写 `@adr`；存在非局部影响时写 `@touches`。
- 测试文件必须写 `@purpose`、`@spec` 和 `@covers`。

## 注释法则

- 有价值的注释只有：解释反直觉选择的 why、非局部影响（优先用 `@touches`）、TODO/FIXME（必须关联看板或 open question）。
- 禁止复述代码、版本历史、分隔线艺术、没有测试支撑的行为描述。
- 注释密度不均匀是预期：核心逻辑高密、CRUD 极低、胶水近零。

## 引用格式

- 项目知识引用使用 `[[文件名]]`，包括代码与测试意图块。
- 文档引用代码使用带路径的行内代码，例如 `src/path/file.ts`。
- 禁用 aliases、block references、embed 和 `#tag`。
- 搜索统一用 ripgrep（`rg`），不使用 `grep`。

## 技术栈确认后补充的强制约束

- 数据库操作只走 Repository 层。
- 错误处理统一项目选定的结果类型，不抛异常（框架顶层除外）。
- 对外时间字段 ISO 8601 UTC；内部时间单位写明并统一。
- API 响应统一采用项目约定的 `{ data, error }` 包裹。
- 禁止 `console.log`（使用 logger）；时间读取使用 clock 抽象，不直接调用 `new Date()`。
