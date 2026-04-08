# 4. frontend/skills/Vue3常用技巧.md（Vue3实战技巧）
## 一、Composition API 实战技巧
### 1. 响应式API高效使用
- ref与reactive选择：
  - 基本类型（string、number、boolean）：优先使用ref，无需额外解构，访问时加.value
  - 引用类型（object、array）：优先使用reactive，若需解构，使用toRefs保持响应式
    ```typescript
    import { ref, reactive, toRefs } from 'vue'
    // 基本类型用ref
    const count = ref(0)
    count.value++ // 需加.value
    
    // 引用类型用reactive
    const user = reactive({ name: '张三', age: 20 })
    // 解构后保持响应式
    const { name, age } = toRefs(user)
    ```
- 避免reactive嵌套过深：复杂对象可拆分为多个reactive，或使用ref包裹对象，提升性能和可维护性
- 只读响应式：使用readonly包装响应式数据，禁止修改，适用于全局配置、常量数据
  ```typescript
  import { readonly } from 'vue'
  const config = readonly({ baseUrl: 'https://api.example.com' })
  ```

### 2. 生命周期钩子使用
- 组合式生命周期与选项式对应关系：
  - onMounted → mounted（组件挂载完成）
  - onUpdated → updated（组件更新完成）
  - onUnmounted → beforeDestroy/destroyed（组件卸载）
  - onBeforeMount → beforeMount（组件挂载前）
- 生命周期钩子可多次使用：同一组件内可多次调用onMounted，按顺序执行，便于拆分逻辑
  ```typescript
  onMounted(() => {
    // 初始化接口请求
    getListData()
  })
  onMounted(() => {
    // 初始化组件事件监听
    initEventListener()
  })
  ```
- 卸载时清理资源：在onUnmounted中移除事件监听、取消接口请求，避免内存泄漏
  ```typescript
  onUnmounted(() => {
    window.removeEventListener('resize', handleResize)
    // 取消接口请求（Axios取消令牌）
    cancelToken.value.cancel('组件卸载，取消请求')
  })
  ```

### 3. 自定义组合式函数（复用逻辑）
- 定义规范：函数名以use开头（如useUser、useList），提取可复用逻辑，返回需要暴露的变量和方法
- 实战示例（接口请求复用）：
  ```typescript
  // src/utils/useRequest.ts
  import { ref } from 'vue'
  import axios from 'axios'

  export function useRequest(url: string) {
    const loading = ref(false)
    const data = ref(null)
    const error = ref(null)

    const fetchData = async (params?: object) => {
      loading.value = true
      try {
        const res = await axios.get(url, { params })
        data.value = res.data
        error.value = null
      } catch (err) {
        error.value = err.message
        data.value = null
      } finally {
        loading.value = false
      }
    }

    return { loading, data, error, fetchData }
  }
  ```
- 使用方式：在组件中引入，直接复用请求逻辑，减少重复代码
  ```typescript
  import { useRequest } from '@/utils/useRequest'
  const { loading, data, fetchData } = useRequest('/api/v1/user/list')
  onMounted(() => {
    fetchData({ pageNum: 1, pageSize: 10 })
  })
  ```

## 二、Vue3 模板与指令技巧
### 1. 模板语法优化
- 简化条件渲染：使用逻辑与（&&）、逻辑或（||）简化简单条件判断
  ```vue
  <!-- 简化前 -->
  显示内容<!-- 简化后 -->
  显示内容
  ```
- 模板中使用计算属性：复杂逻辑提取到computed，避免模板中编写表达式运算
  ```vue
  <!-- 优化前：模板中编写复杂计算 -->
  {{ user.age > 18 ? '成年' : '未成年' }}<!-- 优化后：使用计算属性 -->{{ ageStatus }}
  ```
- 模板片段：使用{{ item.title }}{{ item.content }}{{ item.name }} - {{ item.age }}</List>
  ```
- v-bind 批量绑定属性：使用对象批量绑定元素属性，简化代码
  ```typescript
  const btnProps = {
    type: 'primary',
    size: 'medium',
    disabled: false
  }
  ```
  ```vue
  <el-button v-bind="btnProps">提交</el-button>
  ```

## 三、Pinia 实战技巧
### 1. 状态管理优化
- 模块化拆分：按业务模块拆分store，避免单个store过大（如userStore、orderStore、settingStore）
- 状态持久化：使用pinia-plugin-persistedstate，指定需要持久化的状态，避免页面刷新丢失
  ```typescript
  // src/stores/userStore.ts
  import { defineStore } from 'pinia'
  import { persist } from 'pinia-plugin-persistedstate'

  export const useUserStore = defineStore(
    'user',
    {
      state: () => ({
        token: '',
        userInfo: {}
      }),
      actions: {
        setToken(token: string) {
          this.token = token
        },
        setUserInfo(info: object) {
          this.userInfo = info
        }
      },
      // 持久化配置：只持久化token和userInfo
      persist: {
        paths: ['token', 'userInfo'],
        storage: localStorage // 存储到localStorage
      }
    },
    {
      plugins: [persist()]
    }
  )
  ```
- 避免重复调用useStore：在组件中只调用一次useStore，赋值给变量后复用
  ```typescript
  // 推荐
  const userStore = useUserStore()
  userStore.setToken('xxx')
  // 不推荐：多次调用，影响性能
  useUserStore().setToken('xxx')
  ```

### 2. actions 与 getters 使用
- getters 缓存计算结果：复杂状态计算使用getters，自动缓存，状态变化时自动更新
  ```typescript
  getters: {
    // 计算用户是否为管理员
    isAdmin: (state) => state.userInfo.role === 'admin',
    // 过滤已禁用的用户
    activeUsers: (state) => state.userList.filter(item => item.status === 1)
  }
  ```
- actions 处理异步逻辑：所有异步操作（接口请求）放在actions中，避免组件中编写异步逻辑
  ```typescript
  actions: {
    async login(data: { username: string; password: string }) {
      const res = await loginApi(data)
      this.setToken(res.data.token)
      this.setUserInfo(res.data.userInfo)
      return res.data
    }
  }
  ```

## 四、Vue Router 实战技巧
### 1. 路由配置优化
- 路由模块化：按业务模块拆分路由，单独创建路由文件，再引入主路由配置
  ```typescript
  // src/router/modules/userRouter.ts
  export const userRoutes = [
    { path: '/user/list', name: 'UserList', component: () => import('@/views/user/UserList.vue') },
    { path: '/user/detail/:id', name: 'UserDetail', component: () => import('@/views/user/UserDetail.vue') }
  ]

  // src/router/index.ts
  import { userRoutes } from './modules/userRouter'
  const routes = [
    { path: '/', redirect: '/login' },
    { path: '/login', name: 'Login', component: () => import('@/views/Login.vue') },
    ...userRoutes
  ]
  ```
- 路由守卫全局统一管理：将路由守卫逻辑提取到单独文件，便于维护
  ```typescript
  // src/router/guard.ts
  import { Router } from 'vue-router'

  export function setupRouterGuard(router: Router) {
    // 全局前置守卫：权限控制
    router.beforeEach((to, from, next) => {
      const userStore = useUserStore()
      // 未登录且访问非登录页，跳转登录页
      if (!userStore.token && to.name !== 'Login') {
        next({ name: 'Login' })
      } else {
        next()
      }
    })
  }
  ```

### 2. 路由参数处理
- 动态路由参数获取：使用useRoute()获取路由参数，避免组件 props 接收参数
  ```typescript
  import { useRoute } from 'vue-router'
  const route = useRoute()
  // 获取动态参数id
  const userId = route.params.id as string
  ```
- 路由query参数格式化：使用computed格式化query参数，避免多次解析
  ```typescript
  const route = useRoute()
  const queryParams = computed(() => {
    return {
      pageNum: Number(route.query.pageNum) || 1,
      pageSize: Number(route.query.pageSize) || 10
    }
  })
  ```

## 五、常见问题解决方案
### 1. 响应式数据失效
- 问题：修改reactive对象的属性后，页面不更新
- 解决方案：
  1.  避免直接替换reactive对象（reactive对象不能直接赋值）
      ```typescript
      // 错误
      const user = reactive({ name: '张三' })
      user = { name: '李四' } // 响应式失效
      // 正确
      user.name = '李四'
      ```
  2.  数组修改使用数组方法（push、pop、splice等），或使用ref包裹数组
      ```typescript
      const list = reactive([])
      // 正确：使用push方法
      list.push({ id: 1, name: '张三' })
      // 正确：使用ref包裹数组
      const list = ref([])
      list.value = [{ id: 1, name: '张三' }]
      ```

### 2. 组件通信技巧
- 父子组件通信：props + emit（简单场景）、provide + inject（深层组件）
  ```typescript
  // 父组件provide
  provide('theme', 'dark')
  // 子组件inject
  const theme = inject('theme', 'light') // 第二个参数为默认值
  ```
- 跨组件通信：优先使用Pinia，避免使用EventBus（Vue3已移除EventBus，需自行实现）
- 兄弟组件通信：通过父组件中转，或使用Pinia共享状态

### 3. 接口请求拦截与统一处理
- 请求拦截：添加token、设置请求头，统一处理请求参数
- 响应拦截：统一处理状态码、错误信息，避免组件中重复编写异常处理
  ```typescript
  // src/utils/request.ts
  import axios from 'axios'
  import { ElMessage } from 'element-plus'
  import { useUserStore } from '@/stores/userStore'

  const request = axios.create({
    baseURL: import.meta.env.VITE_API_BASE_URL,
    timeout: 5000
  })

  // 请求拦截
  request.interceptors.request.use(
    (config) => {
      const userStore = useUserStore()
      // 添加token
      if (userStore.token) {
        config.headers.Authorization = `Bearer ${userStore.token}`
      }
      return config
    },
    (error) => {
      return Promise.reject(error)
    }
  )

  // 响应拦截
  request.interceptors.response.use(
    (response) => {
      const res = response.data
      // 状态码非200，提示错误
      if (res.code !== 200) {
        ElMessage.error(res.message || '请求失败')
        return Promise.reject(res)
      }
      return res
    },
    (error) => {
      // 处理401（token过期）
      if (error.response?.status === 401) {
        const userStore = useUserStore()
        userStore.setToken('')
        window.location.href = '/login'
      }
      ElMessage.error(error.message || '网络异常')
      return Promise.reject(error)
    }
  )

  export default request
  ```