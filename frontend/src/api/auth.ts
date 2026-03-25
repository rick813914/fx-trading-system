// src/api/auth.ts
import axios from '@/utils/axios'

export const login = (username: string, password: string) => {
  return axios.post('/api/token/', { username, password })
}

export const refreshToken = (refresh: string) => {
  return axios.post('/api/token/refresh/', { refresh })
}

export const register = (userData: any) => {
  return axios.post('/api/register/', userData)
}
