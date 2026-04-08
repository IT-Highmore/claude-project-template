# 前端项目独有规则（仅适用于当前前端项目，落地版）
## 一、技术栈规范（Vue3+TS主流配置）
1. 框架：Vue3 + TypeScript（Composition API 风格，禁止使用Options API）
2. 样式：Tailwind CSS + SCSS，全局样式放在src/assets/styles目录，组件样式使用scoped。
3. 状态管理：Pinia，全局状态放在src/stores目录，按模块划分（如userStore、settingStore）。
4. 接口请求：统一使用 axios 封装，请求拦截、响应拦截统一处理，接口封装放在src/api目录，按模块划分。
5. 路由：Vue Router 4.x，路由配置放在src/router目录，路由守卫实现权限控制，路由命名符合全局规范。
6. UI组件：Element Plus，统一组件样式，避免自定义样式与UI组件冲突。
7. 代码规范：使用ESLint + Prettier，统一代码格式，提交代码前必须执行lint检查。

## 二、前端特有规范
1. 组件拆分：遵循单一职责原则，组件粒度适中，可复用组件提取到src/components目录，页面组件放在src/views目录。
2. 页面结构：统一布局（头部Header、侧边栏Sidebar、底部Footer），页面命名语义化，放在src/views对应模块目录（如src/views/user）。
3. 状态管理：
   - 全局状态：存放用户信息、全局配置等公共数据，使用Pinia持久化存储（pinia-plugin-persistedstate）。
   - 局部状态：存放当前页面私有数据，使用ref、reactive，不滥用全局状态。
4. 异常处理：页面报错、接口请求失败，统一使用Element Plus的Message组件提示，友好反馈用户，错误信息统一封装在src/utils/errorHandle.ts。
5. 性能优化：
   - 组件懒加载，使用路由懒加载和组件异步导入，减少首屏加载时间。
   - 避免不必要的重渲染，合理使用computed、watch，大数据列表使用虚拟滚动（vue-virtual-scroller）。
   - 图片懒加载，使用v-lazy指令，优化页面加载速度。

## 三、联动注意事项
1. 前端修改接口参数、字段名后，需通知Claude同步修改后端对应接口、DTO、数据库字段。
2. 后端接口返回结构变更后，需同步修改前端对应api封装、页面渲染逻辑、状态管理中的字段。
3. 前后端共用枚举（如用户状态、订单类型），需与后端保持完全一致，修改时双向同步，前端枚举放在src/enums目录。
4. 前端接口请求失败时，需区分是接口错误还是网络错误，分别给出提示，同时触发重新请求机制（最多重试3次）。