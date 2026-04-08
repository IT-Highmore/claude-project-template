# 本目录需要在本地额外创建的链接

复制本模板到真实前端仓库后，请再创建下面这些本地链接：

1. `.claude/CLAUDE.md` -> 你的全局共享 `CLAUDE.md`
2. `.claude/rules/global` -> 你的全局共享 `rules/`
3. `backend/` -> 你的真实后端仓库目录

推荐直接使用仓库根目录下的初始化脚本：

- `example/init-unix.sh`
- `example/init-windows.ps1`

如果你手动创建，请确保这些链接项被 `.gitignore` 忽略，而 `.claude/docs/`、`.claude/rules/frontend.md`、`.claude/skills/` 仍然提交到仓库。
