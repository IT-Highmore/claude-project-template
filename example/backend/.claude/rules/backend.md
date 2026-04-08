# 后端项目独有规则
## 一、技术栈规范（Spring Boot主流配置）
1. 语言：Java 11（统一JDK版本，避免版本冲突）
2. 框架：Spring Boot 2.7.x，Spring MVC，Spring Security，MyBatis-Plus 3.5.x
3. 数据库：MySQL 8.0，Redis 6.x（用于缓存、限流）
4. 分层架构：严格遵循 Controller → Service → Repository 分层，职责清晰，包结构如下：
   - com.example.backend.controller：接口层
   - com.example.backend.service：业务逻辑层（接口+实现类）
   - com.example.backend.repository：数据访问层（Mapper）
   - com.example.backend.dto：数据传输对象（前后端交互）
   - com.example.backend.entity：数据库实体类
   - com.example.backend.enums：枚举类
   - com.example.backend.config：配置类
5. 接口文档：Swagger 3.0（knife4j），接口注释完整，生成在线接口文档，便于前端联调。

## 二、后端特有规范
1. 分层职责：
   - Controller：接收前端请求，参数校验（使用JSR380注解），返回响应，不处理业务逻辑，方法命名符合全局规范。
   - Service：处理核心业务逻辑，调用Repository操作数据库，事务控制（@Transactional），接口与实现类分离。
   - Repository：负责数据库CRUD操作，使用MyBatis-Plus，不包含业务逻辑，复杂查询使用XML映射文件。
2. 异常处理：统一全局异常拦截（@RestControllerAdvice），返回统一格式错误信息，便于前端处理，自定义异常放在com.example.backend.exception包下。
3. 数据校验：接口参数校验、数据库字段校验，使用javax.validation注解（如@NotNull、@NotBlank），避免非法数据入库。
4. 事务管理：涉及多表操作时，添加@Transactional注解，指定事务传播机制，确保数据一致性，避免事务滥用。
5. 日志规范：关键业务操作、异常信息，统一使用SLF4J+Logback记录日志，日志级别区分（INFO、WARN、ERROR），便于排查问题，日志文件按日期分割。
6. 缓存规范：高频查询接口使用Redis缓存，缓存key命名规范：prefix:module:id（如backend:user:1），设置合理的缓存过期时间，避免缓存雪崩、缓存穿透。

## 三、联动注意事项
1. 后端修改接口返回结构、字段类型后，需通知Claude同步修改前端对应api封装、页面渲染逻辑。
2. 前端字段、接口参数变更后，需同步修改后端接口接收（DTO）、参数校验、DTO转换、数据库字段。
3. 前后端共用枚举、常量，需与前端保持完全一致，修改时双向同步，后端枚举放在com.example.backend.enums包下。
4. 接口版本迭代时，需保持向下兼容，避免影响前端现有功能，版本升级使用路径前缀区分（如/api/v1、/api/v2）。
5. 后端接口修改后，需更新Swagger接口文档，确保前端能及时获取最新接口信息。