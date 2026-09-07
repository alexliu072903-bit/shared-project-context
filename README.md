# Shared Project Context

一个公开、可安装的 Agent Skill。它让每个人继续围绕自己的目标工作，同时把真正影响团队项目的进展、风险、阻塞、依赖和 Decision，整理成一份所有人共享的项目状态。

## 它解决什么问题

团队成员的目标和工作内容并不相同。设计师在更新方案，工程师在实现功能，产品经理在调整方向；通常只有开会、追问或写周报时，大家才知道彼此做到哪里。

Project Publisher 会让每个人的 Agent 判断：

- 这次变化是否影响某个共享项目；
- 其他成员是否需要知道；
- 它属于进展、风险、阻塞、依赖还是已确认的 Decision；
- 应该公开多少信息和哪些 Evidence。

与项目无关的个人工作不会进入共享状态。

## Public 机制，Private 数据

这个 public repository 只包含通用 Skill、Protocol、模板和安装器。

每个人的目标、工作记录、Evidence、授权信息和真实项目状态，保存在安装时创建的本地目录或独立 private repository 中，不会提交到这个 public repository。

## 在 Codex 中安装

```bash
git clone https://github.com/alexliu072903-bit/shared-project-context.git
cd shared-project-context
bash install.sh \
  --identity "你的名字" \
  --project "项目 ID" \
  --repository "$HOME/project-context"
```

安装器会：

1. 创建一个默认只保存在本机的 Context 实例；
2. 写入 `~/.project-context/config.json`；
3. 把 Skill 安装到 `~/.codex/skills/project-publisher`。

如果已经有包含 `project-context.json` 的实例，安装时增加 `--use-existing`。

安装完成后重新打开一个 Codex task，让 Skill 被稳定发现。

## 自己先试用

发生一次真实工作变化后，对 Agent 说：

> 用 `$project-publisher` 判断一下，这件事是否应该更新到我的某个共享项目。

Agent 会读取你的个人目标和相关项目，然后选择：

- 与项目无关：不发布；
- 与项目有关：生成一条最小必要更新；
- 影响当前项目理解：同时更新项目的 canonical `state.md`；
- 涉及延期、取消或方向改变：等待有权限的人确认。

## 给团队成员使用

设计师和工程师都安装同一个 public Skill，但维护各自的个人目标和 Context。

例如设计师完成一版 Onboarding 方案后，Agent 可以向共享项目发布：

> Onboarding 主要流程已更新，等待产品确认后进入工程实现。

工程师发现接口问题会阻塞该方案时，Agent 可以发布：

> 当前接口不支持新的 Onboarding 状态，工程实现被阻塞，需要先确认数据方案。

两个人不需要拥有相同的个人目标。系统只把他们工作中与共同项目有关的部分汇入同一份项目状态。

## 第一版边界

它目前不是任务分配工具、员工监控、绩效系统或完整 OKR 产品。第一版只验证：不同成员的不同目标，能否形成一份可信、可追溯、可纠正的共享项目状态。

## License

MIT
