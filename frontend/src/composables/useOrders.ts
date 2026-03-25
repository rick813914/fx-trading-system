// src/composables/useOrders.ts
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import * as api from '@/api'
import type { Order } from '@/types/orders'

export function useOrders() {
  const orders = ref<Order[]>([])
  const loading = ref(false)
  const pagination = reactive({
    page: 1,
    pageSize: 20,
    total: 0
  })
  const filters = reactive({
    symbol: '',
    direction: ''
  })

  // 获取订单列表
  const fetchOrders = async () => {
    loading.value = true
    try {
      const params = {
        page: pagination.page,
        page_size: pagination.pageSize,
        ...(filters.symbol && { symbol: filters.symbol }),
        ...(filters.direction && { direction: filters.direction })
      }
      const response = await api.getOrders(params)
      orders.value = response.data.results
      pagination.total = response.data.count
    } catch (error) {
      ElMessage.error('获取订单失败')
    } finally {
      loading.value = false
    }
  }

  // 重置筛选
  const resetFilters = () => {
    filters.symbol = ''
    filters.direction = ''
    pagination.page = 1
    fetchOrders()
  }

  // 创建订单
  const createOrder = async (data: Partial<Order>) => {
    try {
      await api.createOrder(data)
      ElMessage.success('创建成功')
      await fetchOrders()
    } catch (error) {
      ElMessage.error('创建失败')
      throw error
    }
  }

  // 更新订单
  const updateOrder = async (id: number, data: Partial<Order>) => {
    try {
      await api.updateOrder(id, data)
      ElMessage.success('更新成功')
      await fetchOrders()
    } catch (error) {
      ElMessage.error('更新失败')
      throw error
    }
  }

  // 删除订单
  const deleteOrder = async (id: number) => {
    try {
      await ElMessageBox.confirm('确认删除该订单吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      await api.deleteOrder(id)
      ElMessage.success('删除成功')
      await fetchOrders()
    } catch (error) {
      if (error !== 'cancel') {
        ElMessage.error('删除失败')
      }
    }
  }

  // 导入 CSV（仅启动任务，轮询由组件处理）
  const importCSV = async (file: File, onTaskStart: (taskId: string) => void) => {
    try {
      const response = await api.importCSV(file)
      onTaskStart(response.data.task_id)
    } catch (error: any) {
      ElMessage.error(error.response?.data?.error || '上传失败')
    }
  }

  // 导出 CSV
  const exportCSV = async () => {
    try {
      const response = await api.exportCSV()
      const url = window.URL.createObjectURL(new Blob([response.data]))
      const link = document.createElement('a')
      link.href = url
      link.setAttribute('download', 'orders_export.csv')
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      window.URL.revokeObjectURL(url)
      ElMessage.success('导出成功')
    } catch (error) {
      ElMessage.error('导出失败')
    }
  }

  return {
    orders,
    loading,
    pagination,
    filters,
    fetchOrders,
    resetFilters,
    createOrder,
    updateOrder,
    deleteOrder,
    importCSV,
    exportCSV
  }
}
