# 全局命名规范（前后端必须严格遵循）
## 1. 变量/函数/方法
- 小驼峰命名：首字母小写，后续单词首字母大写（如 userInfo、getUserDetail）
- 语义化命名：避免无意义命名（如 a、temp、data1），明确变量/方法用途。

## 2. 类/接口/组件
- 大驼峰命名：首字母大写，后续单词首字母大写（如 UserController、LoginComponent）
- 接口命名：后端接口前缀加 I（如 IUserService），前端组件无需加前缀。

## 3. 常量/枚举
- 全大写+下划线：如 MAX_PAGE_SIZE、USER_STATUS_ACTIVE
- 枚举值：与数据库字段保持一致，避免歧义，前端枚举放在src/enums目录，后端枚举放在com.example.backend.enums包下。

## 4. 文件/目录
- 前端：组件文件大驼峰（Login.vue），工具文件小驼峰（utils.ts），目录小写+横线（src/components/user-manage）。
- 后端：类文件大驼峰（UserService.java），配置文件小写+下划线（application_dev.yml），包名全小写（com.example.backend.controller）。

## 5. 数据库/接口
- 数据库表名/字段：小写+下划线（user_info、order_id），表名前缀统一为t_（如t_user_info）。
- 接口路径：小写+横线（/api/v1/user/list），接口命名：动词+名词（getUser、createOrder）。
- 前端接口请求方法：get（查询）、post（新增）、put（修改）、delete（删除）。