### 说明
本地部署约定路径：~/work/（工作目录）、~/.claude-global/（全局共享配置，非Git仓库）
适配系统：Unix/macOS/Git Bash（Windows路径可对应替换为 C:\Users\YourName\ 下）
技术栈适配：前端（Vue3+TS）、后端（Spring Boot+Java）
## 一、全局共享配置目录（~/.claude-global/）【前后端共用，非Git仓库】

```
.claude-global/                # 全局共享配置根目录（一处修改，双仓库同步生效）
├── CLAUDE.md                  # 全局通用Claude配置（联动规则、通用规范、项目路径）
└── rules/                     # 全局通用规则目录
    ├── general.md             # 通用编码规范（前后端共用，缩进、注释、冗余要求）
    ├── naming.md              # 全局命名规范（变量、类、接口、数据库字段命名）
    ├── prompt.md              # AI交互规则（与Claude协作的规范、响应要求）
    └── security.md            # 安全规范（前后端共用，XSS、SQL注入、权限控制等）
```

## 二、前端项目目录（~/work/frontend/）【前端Git仓库】

```
frontend/                     # 前端项目根目录（Git仓库：https://git.example.com/frontend.git）
├── .claude/                  # 前端Claude配置目录（关联全局配置，存放独有规则）
│   ├── CLAUDE.md             # 符号链接 → ~/.claude-global/CLAUDE.md（复用全局配置）
│   └── rules/                # 前端规则目录
│       ├── global/           # 符号链接 → ~/.claude-global/rules（复用全局通用规则）
│       └── frontend.md       # 前端独有规则（技术栈规范、前端特有约束、联动注意事项）
├── backend/                  # 符号链接 → ~/work/backend（让Claude访问后端代码，实现联动）
├── .gitignore                # 前端Git忽略文件（忽略Claude配置、符号链接、依赖等）
├── claude-init.sh            # 一键配置脚本（Unix/macOS，可选，用于快速初始化）
└── src/                      # 前端业务代码目录（Vue3+TS核心代码，按项目规范组织）
    ├── api/                  # 接口封装目录（按模块划分，与后端接口对应）
    ├── components/           # 可复用组件目录
    ├── enums/                # 前端枚举目录（与后端枚举保持一致）
    ├── assets/               # 静态资源目录（样式、图片等）
    ├── stores/               # Pinia状态管理目录
    ├── router/               # Vue Router路由配置目录
    ├── views/                # 页面组件目录
    └── utils/                # 工具函数目录（异常处理、请求拦截等）
```

## 三、后端项目目录（~/work/backend/）【后端Git仓库】

```
backend/                      # 后端项目根目录（Git仓库：https://git.example.com/backend.git）
├── .claude/                  # 后端Claude配置目录（关联全局配置，存放独有规则）
│   ├── CLAUDE.md             # 符号链接 → ~/.claude-global/CLAUDE.md（复用全局配置）
│   └── rules/                # 后端规则目录
│       ├── global/           # 符号链接 → ~/.claude-global/rules（复用全局通用规则）
│       └── backend.md        # 后端独有规则（技术栈规范、分层职责、联动注意事项）
├── frontend/                 # 符号链接 → ~/work/frontend（让Claude访问前端代码，实现联动）
├── .gitignore                # 后端Git忽略文件（忽略Claude配置、符号链接、依赖等）
├── claude-init.sh            # 一键配置脚本（Unix/macOS，可选，用于快速初始化）
└── src/                      # 后端业务代码目录（Spring Boot核心代码，按分层架构组织）
    └── main/
        ├── java/
        │   └── com/
        │       └── example/
        │           └── backend/
        │               ├── controller/  # 接口层（接收前端请求，返回响应）
        │               ├── service/     # 业务逻辑层（接口+实现类）
        │               ├── repository/  # 数据访问层（Mapper，操作数据库）
        │               ├── dto/         # 数据传输对象（前后端交互）
        │               ├── entity/      # 数据库实体类
        │               ├── enums/       # 后端枚举目录（与前端枚举保持一致）
        │               ├── config/      # 配置类（Spring Security、Redis等）
        │               └── exception/   # 自定义异常目录
        └── resources/
            ├── application.yml          # 后端核心配置文件
            ├── application-dev.yml      # 开发环境配置
            └── mybatis/                 # MyBatis映射文件目录
```


### 关键说明
- 带「符号链接」标识的文件/目录，无需手动创建，由一键脚本自动生成，用于关联全局配置和跨项目访问。
- .gitignore文件已完善，可直接提交到Git仓库，避免符号链接、Claude配置、本地依赖等污染仓库。
- src目录为业务代码目录，目录结构按对应技术栈最佳实践组织，可根据实际项目需求调整。
- 全局配置目录（.claude-global）不属于任何Git仓库，建议由团队负责人统一维护，确保团队规范一致。