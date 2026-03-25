// src/api/orders.ts
import axios from '@/utils/axios'
import type { Order, OrderListParams, ImportStatusResponse } from '@/types/orders'

export const getOrders = (params: OrderListParams) => {
  return axios.get('/api/orders/', { params })
}

export const createOrder = (data: Partial<Order>) => {
  return axios.post('/api/orders/', data)
}

export const updateOrder = (id: number, data: Partial<Order>) => {
  return axios.put(`/api/orders/${id}/`, data)
}

export const deleteOrder = (id: number) => {
  return axios.delete(`/api/orders/${id}/`)
}

export const importCSV = (file: File) => {
  const formData = new FormData()
  formData.append('file', file)
  return axios.post('/api/orders/import-csv/', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export const getImportStatus = (taskId: string) => {
  return axios.get<ImportStatusResponse>(`/api/orders/import-status/${taskId}/`)
}

export const exportCSV = () => {
  return axios.get('/api/orders/export-csv/', { responseType: 'blob' })
}
