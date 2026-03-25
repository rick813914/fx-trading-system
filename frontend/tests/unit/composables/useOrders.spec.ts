import { describe, it, expect, vi, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useOrders } from '@/composables/useOrders'
import * as api from '@/api/orders'
import { ElMessage, ElMessageBox } from 'element-plus'

// 模拟 API 和 Element Plus 消息
vi.mock('@/api/orders', () => ({
  getOrders: vi.fn(),
  createOrder: vi.fn(),
  updateOrder: vi.fn(),
  deleteOrder: vi.fn(),
  importCSV: vi.fn(),
  exportCSV: vi.fn(),
}))

vi.mock('element-plus', () => ({
  ElMessage: {
    success: vi.fn(),
    error: vi.fn(),
  },
  ElMessageBox: {
    confirm: vi.fn(),
  },
}))

describe('useOrders', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.clearAllMocks()
  })

  it('should fetch orders', async () => {
    const mockData = {
      data: {
        results: [{ id: 1, symbol: 'EURUSD' }],
        count: 1,
      },
    }
    vi.mocked(api.getOrders).mockResolvedValueOnce(mockData as any)

    const { orders, fetchOrders } = useOrders()
    await fetchOrders()

    expect(api.getOrders).toHaveBeenCalled()
    expect(orders.value).toEqual([{ id: 1, symbol: 'EURUSD' }])
  })

  it('should create order', async () => {
    const newOrder = { symbol: 'EURUSD', volume: 1.0 }
    vi.mocked(api.createOrder).mockResolvedValueOnce({ data: { id: 1 } } as any)
    vi.mocked(api.getOrders).mockResolvedValueOnce({ data: { results: [], count: 0 } } as any)

    const { createOrder, fetchOrders } = useOrders()
    await createOrder(newOrder)

    expect(api.createOrder).toHaveBeenCalledWith(newOrder)
    expect(ElMessage.success).toHaveBeenCalledWith('创建成功')
    // 创建成功后应刷新列表
    expect(api.getOrders).toHaveBeenCalled()
  })

  it('should delete order after confirmation', async () => {
    vi.mocked(ElMessageBox.confirm).mockResolvedValueOnce(undefined as any)
    vi.mocked(api.deleteOrder).mockResolvedValueOnce({} as any)
    vi.mocked(api.getOrders).mockResolvedValueOnce({ data: { results: [], count: 0 } } as any)

    const { deleteOrder, fetchOrders } = useOrders()
    await deleteOrder(1)

    expect(ElMessageBox.confirm).toHaveBeenCalled()
    expect(api.deleteOrder).toHaveBeenCalledWith(1)
    expect(ElMessage.success).toHaveBeenCalledWith('删除成功')
  })

  it('should export CSV', async () => {
    const blob = new Blob(['test'], { type: 'text/csv' })
    vi.mocked(api.exportCSV).mockResolvedValueOnce({ data: blob } as any)
    // Mock URL.createObjectURL
    global.URL.createObjectURL = vi.fn(() => 'blob:url')
    global.URL.revokeObjectURL = vi.fn()

    const { exportCSV } = useOrders()
    await exportCSV()

    expect(api.exportCSV).toHaveBeenCalled()
    expect(ElMessage.success).toHaveBeenCalledWith('导出成功')
  })
})
