// src/utils/axios.ts
import axios from 'axios'
import { useAuthStore } from '@/stores/auth'
import router from '@/router'

// 创建 axios 实例
const instance = axios.create({
  baseURL: '/',          // 代理后直接使用 /api
  timeout: 10000,
})

// 请求拦截器：自动添加 JWT token
instance.interceptors.request.use(
  (config) => {
    const authStore = useAuthStore()
    if (authStore.token) {
      config.headers.Authorization = `Bearer ${authStore.token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// 响应拦截器：处理 401 未认证
instance.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      const authStore = useAuthStore()
      authStore.logout()
      router.push('/login')
    }
    return Promise.reject(error)
  }
)

export default instance
