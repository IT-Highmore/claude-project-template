# 前后端双仓库 + Claude 配置联动模板

这是一个面向“前端仓库 / 后端仓库分离”场景的 Claude 配置模板仓库。

它解决的不是“如何把代码放进一个仓库”，而是：

- 前后端继续保持各自独立 Git 仓库
- Claude 仍然能同时理解两边代码和约束
- 通用规则只维护一份
- 项目级规则可以跟随各自仓库版本化

## 这个仓库现在包含什么

- 一份更完整的根说明文档，用来解释推荐目录、使用方式和注意事项
- 一个 `example/` 示例目录，演示一套可直接落地的模板内容
- 一组全局共享规则样板，放在 `example/.claude-global/`
- 一组前端项目级规则、文档、技能样板，放在 `example/frontend/.claude/`
- 一组后端项目级规则、文档、技能样板，放在 `example/backend/.claude/`
- 两个初始化脚本：
  - `example/init-unix.sh`
  - `example/init-windows.ps1`

## 适用场景

- 前端与后端是两个独立仓库
- 团队希望统一 Claude 的回答风格、命名规范、接口规范和联动规则
- 项目经常发生“前端字段改了，后端也要同步”或“后端返回结构改了，前端也要同步”的联调修改
- 希望把“全局共享规则”和“项目独有规则”分开维护

## 推荐设计

建议采用三层结构：

1. 全局共享层：放在本地用户目录，不归属于任一业务仓库
2. 前端项目层：保存前端独有规则，并链接到全局共享层和后端仓库
3. 后端项目层：保存后端独有规则，并链接到全局共享层和前端仓库

```text
~/work/
├─ frontend/                 # 前端 Git 仓库
│  ├─ .claude/
│  │  ├─ CLAUDE.md           # 符号链接 -> ~/.claude-global/CLAUDE.md
│  │  ├─ rules/
│  │  │  ├─ global/          # 符号链接 -> ~/.claude-global/rules
│  │  │  └─ frontend.md
│  │  ├─ docs/
│  │  └─ skills/
│  └─ backend/               # 符号链接 -> ~/work/backend
├─ backend/                  # 后端 Git 仓库
│  ├─ .claude/
│  │  ├─ CLAUDE.md           # 符号链接 -> ~/.claude-global/CLAUDE.md
│  │  ├─ rules/
│  │  │  ├─ global/          # 符号链接 -> ~/.claude-global/rules
│  │  │  └─ backend.md
│  │  ├─ docs/
│  │  └─ skills/
│  └─ frontend/              # 符号链接 -> ~/work/frontend
└─ .claude-global/           # 全局共享配置目录，不放进业务仓库
   ├─ CLAUDE.md
   ├─ docs/
   ├─ rules/
   └─ skills/
```

## 仓库结构

```text
.
├─ README.md
├─ LICENSE
└─ example/
   ├─ README.md
   ├─ init-unix.sh
   ├─ init-windows.ps1
   ├─ .claude-global/
   │  ├─ CLAUDE.md
   │  ├─ docs/
   │  ├─ rules/
   │  └─ skills/
   ├─ frontend/
   │  ├─ .gitignore
   │  └─ .claude/
   │     ├─ LINKS.md
   │     ├─ docs/
   │     ├─ rules/
   │     └─ skills/
   └─ backend/
      ├─ .gitignore
      └─ .claude/
         ├─ LINKS.md
         ├─ docs/
         ├─ rules/
         └─ skills/
```

## 推荐使用方式

### 方式一：直接拿 `example/` 作为蓝本

1. 复制 `example/.claude-global/` 到你的本地共享目录，如 `~/.claude-global/`
2. 将 `example/frontend/.claude/` 中的项目级内容复制到你的前端仓库
3. 将 `example/backend/.claude/` 中的项目级内容复制到你的后端仓库
4. 运行初始化脚本创建符号链接和互链目录

Unix / macOS / Git Bash：

```bash
bash example/init-unix.sh /path/to/frontend /path/to/backend
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\example\init-windows.ps1 `
  -FrontendPath C:\work\frontend `
  -BackendPath C:\work\backend
```

### 方式二：手工初始化

如果你不想用脚本，也可以按 `example/README.md` 中的步骤手动创建目录和符号链接。

## 关键原则

### 1. 全局共享内容放在本地，不放入业务仓库

适合放在 `~/.claude-global/` 的内容：

- 全局 `CLAUDE.md`
- 通用编码规范
- 通用接口规范
- 通用安全规范
- 团队协作规范

### 2. 项目独有内容应放入各自仓库并纳入版本控制

适合放在前端 / 后端仓库 `.claude/` 中并提交 Git 的内容：

- 项目独有规则
- 项目技术文档
- 项目问题排查手册
- 项目技能沉淀

### 3. 本地链接项应忽略，不要整目录忽略 `.claude/`

这是现成模板里最容易踩坑的一点。

如果直接忽略整个 `.claude/`，那么项目级规则、文档、技能也会一起被忽略，团队成员拿不到这些模板内容。更合理的做法是：

- 提交 `.claude/rules/*.md`、`.claude/docs/`、`.claude/skills/`
- 忽略本地符号链接本身：
  - `.claude/CLAUDE.md`
  - `.claude/rules/global/`
- 忽略跨项目互链目录：
  - 前端仓库中的 `backend/`
  - 后端仓库中的 `frontend/`

`example/frontend/.gitignore` 和 `example/backend/.gitignore` 已按这个思路调整。

## `example/` 里哪些是“真实文件”，哪些需要你本地创建

由于跨平台和 Git 对符号链接的处理差异，这个模板仓库不会直接提交真正的跨仓库链接。

因此：

- `example/.claude-global/` 里的内容都是真实模板文件
- `example/frontend/.claude/`、`example/backend/.claude/` 里的规则 / 文档 / 技能都是真实模板文件
- `.claude/CLAUDE.md`
- `.claude/rules/global/`
- 前端仓库里的 `backend/`
- 后端仓库里的 `frontend/`

这些“链接位”需要你在本地通过脚本或手工命令创建

## 模板定制建议

你可以优先替换下面几类内容：

- 技术栈名称：如 Vue / React、Spring Boot / Node.js / Go
- 接口约定：统一响应结构、状态码、鉴权方式
- 联动规则：字段变更、DTO 变更、枚举变更时 Claude 的同步要求
- 团队协作规范：分支策略、提交规范、联调流程
- 项目级技能库：常见报错排查、部署流程、性能优化清单

## 常见问题

### 看不到 `example/.claude-global`

这是隐藏目录。Windows 资源管理器和部分命令默认不显示隐藏项，请开启“显示隐藏的项目”，或使用：

```powershell
Get-ChildItem -Force example
```

### 符号链接创建失败

- Windows 需要管理员权限或启用开发者模式
- PowerShell 中建议使用 `New-Item -ItemType SymbolicLink`
- Git Bash / macOS / Linux 可使用 `ln -s`

### Claude 没有读取到另一侧仓库

先检查互链是否真实存在：

- 前端仓库下是否有 `backend/`
- 后端仓库下是否有 `frontend/`

再检查链接目标是否指向正确路径。

## 从哪里开始看

- 想先理解整体设计：看 `README.md`
- 想直接照着搭环境：看 `example/README.md`
- 想直接拿模板文件：看 `example/.claude-global/`、`example/frontend/.claude/`、`example/backend/.claude/`
- 想一键落地：运行 `example/init-unix.sh` 或 `example/init-windows.ps1`
