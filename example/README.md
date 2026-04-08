# `example/` 使用说明

`example/` 不是一个可直接运行的业务项目，而是一套“可以复制到你自己仓库”的模板样板。

它的目标是帮助你快速搭好下面这三类内容：

- 全局共享 Claude 配置
- 前端仓库的项目级 `.claude` 内容
- 后端仓库的项目级 `.claude` 内容

## 目录说明

### `example/.claude-global/`

这部分应该复制到你本机的共享目录，例如 `~/.claude-global/`。

包含：

- `CLAUDE.md`
- `docs/`：通用接口文档、枚举文档、协作规范
- `rules/`：通用编码 / 命名 / Prompt / 安全规则
- `skills/`：调试技巧、常用命令、依赖说明

### `example/frontend/.claude/`

这部分应该复制到你的前端仓库中，例如：

```text
/path/to/frontend/.claude/
```

包含：

- `rules/frontend.md`
- `docs/`
- `skills/`
- `LINKS.md`

### `example/backend/.claude/`

这部分应该复制到你的后端仓库中，例如：

```text
/path/to/backend/.claude/
```

包含：

- `rules/backend.md`
- `docs/`
- `skills/`
- `LINKS.md`

## 为什么示例里没有真正的链接文件

这个仓库是模板仓库，不直接提交以下本地链接项：

- 前端仓库的 `.claude/CLAUDE.md`
- 前端仓库的 `.claude/rules/global`
- 前端仓库的 `backend/`
- 后端仓库的 `.claude/CLAUDE.md`
- 后端仓库的 `.claude/rules/global`
- 后端仓库的 `frontend/`

原因是：

- 这些路径在每个人机器上都不同
- 跨平台对符号链接的支持不完全一致
- 模板仓库更适合提交“内容模板”，而不是强绑定的本地链接

这些链接应在你本地通过脚本创建。

## 最简单的落地方式

假设你的目录如下：

```text
~/work/frontend
~/work/backend
~/.claude-global
```

### Unix / macOS / Git Bash

```bash
bash example/init-unix.sh ~/work/frontend ~/work/backend
```

### Windows PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\example\init-windows.ps1 `
  -FrontendPath C:\work\frontend `
  -BackendPath C:\work\backend `
  -GlobalPath C:\Users\YourName\.claude-global
```

## 脚本会做什么

两个初始化脚本都会完成下面这些动作：

1. 将 `example/.claude-global/` 复制到你的共享目录
2. 将前端项目级 `.claude` 模板复制到前端仓库
3. 将后端项目级 `.claude` 模板复制到后端仓库
4. 创建 `.claude/CLAUDE.md` 符号链接
5. 创建 `.claude/rules/global` 符号链接
6. 创建前后端互链目录
7. 将推荐忽略项补充到两侧 `.gitignore`

## 建议的 Git 忽略策略

前端仓库建议忽略：

```gitignore
.claude/CLAUDE.md
.claude/rules/global/
backend/
```

后端仓库建议忽略：

```gitignore
.claude/CLAUDE.md
.claude/rules/global/
frontend/
```

不要直接忽略整个 `.claude/`，否则项目级规则、文档、技能也会一起被忽略。

## 你应该优先替换哪些模板内容

### 全局共享层

- `example/.claude-global/CLAUDE.md`
- `example/.claude-global/rules/*.md`
- `example/.claude-global/docs/*.md`

### 前端项目层

- `example/frontend/.claude/rules/frontend.md`
- `example/frontend/.claude/docs/*.md`
- `example/frontend/.claude/skills/*.md`

### 后端项目层

- `example/backend/.claude/rules/backend.md`
- `example/backend/.claude/docs/*.md`
- `example/backend/.claude/skills/*.md`

## 可按需扩展的方向

- 增加测试规范
- 增加 API 版本发布说明
- 增加数据库变更流程
- 增加日志与监控约定
- 增加更细分的业务模块规则

## 额外提示

- `example/.claude-global/` 是隐藏目录，注意开启隐藏文件显示
- Windows 下创建符号链接通常需要管理员权限或开发者模式
- 如果你的团队不想使用符号链接，也可以把全局规则改成脚本同步或复制策略
