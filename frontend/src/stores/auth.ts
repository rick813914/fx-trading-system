// src/stores/auth.ts
import { defineStore } from 'pinia'
import { ref } from 'vue'
import axios from '@/utils/axios' // 稍后创建 axios 实例

export const useAuthStore = defineStore('auth', () => {
  // 状态
  const token = ref<string>(localStorage.getItem('access_token') || '')
  const user = ref<any>(null)

  // 登录方法
  async function login(username: string, password: string) {
    try {
      const response = await axios.post('/api/users/login/', { username, password })
      token.value = response.data.access
      localStorage.setItem('access_token', token.value)
      await fetchProfile() // 登录成功后获取用户信息
      return true
    } catch (error) {
      console.error('登录失败', error)
      return false
    }
  }

  // 注册方法
  async function register(username: string, email: string, password: string) {
    try {
      const response = await axios.post('/api/users/register/', { username, email, password })
      // 注册成功后自动登录
      await login(username, password)
      return true
    } catch (error) {
      console.error('注册失败', error)
      return false
    }
  }

  // 获取用户资料
  async function fetchProfile() {
    if (!token.value) return
    const response = await axios.get('/api/users/profile/', {
      headers: { Authorization: `Bearer ${token.value}` }
    })
    user.value = response.data
  }

  // 退出登录
  function logout() {
    token.value = ''
    user.value = null
    localStorage.removeItem('access_token')
  }

  return { token, user, login, register, fetchProfile, logout }
})
