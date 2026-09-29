# 发给 Agent 的启动消息

请为本项目执行「AI 工作流冷启动」，按序执行以下步骤。这条消息只在初始化时使用；之后的会话从 `AI-AGENT-START-HERE.md` 自举。

## 阶段 1：安装脚手架

项目内应有 `agent-coldstart-scaffold/`（或 release.tar.gz）。

- 若是 tar.gz，在项目根目录解压下载的那个文件（例如 `tar -xzf agent-coldstart-scaffold-2.0.0.tar.gz`），确认得到 `agent-coldstart-scaffold/`。
- 若都没有，向我确认下载来源后再获取。
- 执行：`bash agent-coldstart-scaffold/install.sh .`

## 阶段 2：自检并报告

执行 `bash agent-coldstart-scaffold/install.sh --verify .`，向我报告结果。若有缺失，先修复再报告。

## 阶段 3：加载上下文

读取根目录 `AI-AGENT-START-HERE.md`，按其指引读完全部必读文件，并简报看到的项目状态（新项目应为“刚初始化，未开始业务开发”）。

## 阶段 4：项目访谈

以 `agent-knowledge/onboarding/project-purpose-and-scope.md` 中的 TODO 为提纲向我提问。每轮最多 3 个问题，得到回答后再问下一轮。

## 阶段 5：产出首版知识库

本会话不写任何业务代码。

1. 填写 `project-purpose-and-scope.md` 和 `domain-terminology-glossary.md`。
2. 与我确认技术栈；我拍板后按 `_TEMPLATE-adr.md` 写 ADR-0001，文件名包含结论。
3. 补全 `coding-conventions-project-specific.md` 的“强制约束”部分。
4. 在 `task-board.md` 的 Backlog 写下第一批粗粒度任务，开工时再拆解。

## 阶段 6：收尾

1. 询问我脚手架目录 `agent-coldstart-scaffold/` 要删除还是保留；若保留，将其加入 `.gitignore`。
2. 若本次通过 tar.gz 安装，确认压缩包不会被误提交：默认删除；若我要求保留，将该文件加入 `.gitignore`。
3. 提交 git（首次提交）。
4. 执行 `workflow-rules-for-ai-agent.md` 中的会话结束协议。
