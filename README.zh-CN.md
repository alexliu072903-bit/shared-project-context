# Shared Project Context

[English](README.md)

一套让真实工作持续对齐人设 Goal 的开源 Agent Skill。

它在任何规模下都使用同一套模型：

```text
N 个 Human / Agent Actor
→ M 个由人设定的 Goal
→ 一份有 Evidence 的 Goal State
```

一个人使用时 `N=1`；小团队或公司使用时 `N>1`。个人和团队不是两种产品模式。

## 它做什么

Actor 继续在 Codex、Claude Code，以及未来的 AirJelly 中正常工作。Project Publisher 自动识别有意义的进展、偏离、风险、Blocker、Dependency 和已确认 Decision，并判断它们如何影响当前 Goal。

它负责维护：

- 由人设定的 Goal 与验收条件；
- 每个 Actor 的 append-only Update；
- 一份 canonical Goal State；
- Decision 历史与纠错；
- Agent turn 收尾或下次进入时的克制提醒；
- Evidence 引用，而不是原始 Activity dump。

它不重复任务分配、IM、日历、组织管理或绩效评价等现有软件能力。

## Public Engine，可配置 Workspace

这个 public repository 只分发 Skill、Schema、Protocol、安装器和可选同步脚本。真实 Goal、Actor Update、Evidence 和 State 保存在由模板创建的 Workspace 中。

Workspace 可以只放本机、使用 private repository，或由 Owner 选择其他可见性边界。无论有多少 Actor，数据模型相同。

## 安装

```bash
git clone https://github.com/alexliu072903-bit/shared-project-context.git
cd shared-project-context
bash install.sh \
  --identity "你的名字" \
  --workspace "my-goals" \
  --repository "$HOME/goal-context" \
  --codex \
  --claude-code
```

支持：

- `--codex`
- `--claude-code`
- `--airjelly-production`
- `--airjelly-development PATH`

安装器会创建第一个 Actor、一条待确认 Goal、`state.md` 和该 Actor 的空 Attention State；同时写入 `~/.project-context/config.json`，并把同一份 canonical Skill 安装到所选 Runtime。

早期原型阶段仍接受 `--project` 作为 `--workspace` 的兼容别名。

## 加入已有 Workspace

获得已有 Workspace 权限并 clone 后，运行：

```bash
bash install.sh \
  --identity "Designer A" \
  --workspace "airjelly" \
  --repository "$HOME/airjelly-goal-context" \
  --use-existing \
  --codex \
  --claude-code
```

如果 Actor 尚不存在，安装器只新增该 Actor 的 Profile、Update 目录和 Attention State。Repository 权限和成员管理继续由现有协作平台负责。

## 提醒方式

当前支持两种 Agent-native 提醒：

1. `turn_end`：完成正常工作回复后，在确实有帮助时增加一句 Goal Alignment 提醒；
2. `next_entry`：保存 Focus Brief，在 Actor 下次进入相关 Agent turn 时展示。

一次孤立的无关行为不自动等于偏离。系统需要看到完整 Work Episode，并且继续下去确实可能造成机会成本、Goal 停滞、Dependency 风险或 deadline 风险，才生成提醒。

## AirJelly Context Source

Agent turn 内的判断不依赖 AirJelly。未来 AirJelly 可以提供 Codex、Claude Code 之外的增量 Work Episode，要求可去重、可追溯、有 Evidence。Goal 归属、提醒、Decision 确认和 canonical State 仍由 Project Publisher 负责。详见 [Context Source Contract](references/context-source-contract.md)。

## 可选 Git Sync

生成的 Workspace 包含 macOS 30 分钟 commit、rebase、push 脚本。连接合适的 remote 后，用户主动运行：

```bash
bash "$HOME/goal-context/scripts/setup-autosync.sh"
```

如果 GitHub 报告 remote 为 public，默认脚本会拒绝同步，因为 Work Context 可能包含敏感信息。Workspace Owner 可以选择其他共享方式，或明确修改策略。

## License

MIT
