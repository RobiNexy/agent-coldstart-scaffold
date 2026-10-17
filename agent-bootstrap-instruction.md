# 发给 Agent 的启动消息

请为本项目执行「AI 工作流冷启动」，按序执行以下步骤。这条消息只在初始化时使用；之后的会话从 `00__AGENT_START_HERE.md` 自举。

## 阶段 1：安装脚手架

项目内应有 `agent-coldstart-scaffold/`（或 release tar.gz）。

- 若是 tar.gz，在项目根目录解压该文件（例如 `tar -xzf agent-coldstart-scaffold-4.1.0.tar.gz`），确认得到 `agent-coldstart-scaffold/`。
- 若两者都没有，向我确认下载来源后再获取。
- Windows（PowerShell 7.x）：执行 `pwsh -File .\agent-coldstart-scaffold\install.ps1 -TargetDir .`。
- Unix：执行 `bash agent-coldstart-scaffold/install.sh .`。

## 阶段 2：自检并报告

Windows 执行 `pwsh -File .\agent-coldstart-scaffold\install.ps1 -Verify -TargetDir .`；Unix 执行 `bash agent-coldstart-scaffold/install.sh --verify .`。向我报告结果。若有缺失，先修复再报告。

## 阶段 3：加载上下文

按 `00__AGENT_START_HERE.md` 的三步启动执行：
1. `ls -F .`
2. 读取 `10__ALWAYS_LOAD_FIRST/` 下全部文件
3. 读取 `20__EDIT_BEFORE_SESSION_END/` 下三份文件

然后简报项目状态。新项目应为"刚初始化，未开始业务开发"。

## 阶段 4：项目访谈

以 `10__ALWAYS_LOAD_FIRST/project_purpose_and_boundary.md` 中的 TODO 为提纲向我提问。每轮最多 3 个问题，得到回答后再问下一轮。

该文件由我维护：你可以起草内容，但写入前须经我确认。

## 阶段 5：产出首版知识库

本会话不写任何业务代码，不修改 `50__HUMAN_SOURCE_DO_NOT_EDIT/`。

1. 与我确认后，填写 `10__ALWAYS_LOAD_FIRST/project_purpose_and_boundary.md`。
2. 补全 `10__ALWAYS_LOAD_FIRST/domain_terminology_glossary.md` 中的术语，初始状态标为"待确认"。
3. 与我确认技术栈，然后将它记录为 ADR 草案：复制 `30__DECISION_AND_DESIGN_ARE_EXPENSIVE/20__DECISIONS/_TEMPLATE__ADR.md`，文件名包含结论。ADR 状态保持 Proposed，等待我拍板。
4. 在 `10__ALWAYS_LOAD_FIRST/coding_conventions_project_specific.md` 中，将 TODO 标注的工具名与配置替换为确认后的值。
5. 在 `20__EDIT_BEFORE_SESSION_END/task_board.md` 的 Backlog 中写下第一批粗粒度任务，开工时再拆解。

## 阶段 6：收尾

1. 询问我脚手架目录 `agent-coldstart-scaffold/` 要删除还是保留；若保留，将其加入 `.gitignore`。
2. 若本次通过 tar.gz 安装，确认压缩包不会被误提交：默认删除；若我要求保留，将该文件加入 `.gitignore`。
3. 提交 git（首次提交），仅提交本次安装与初始化产生的文件。
4. 按 `10__ALWAYS_LOAD_FIRST/workflow_rules_for_ai.md` 第五节执行会话结束协议，输出变更简报。
