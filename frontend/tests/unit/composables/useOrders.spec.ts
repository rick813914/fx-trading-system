import { describe, it, expect, vi, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useOrders } from '@/composables/useOrders'
import * as api from '@/api/orders'
import { ElMessage, ElMessageBox } from 'element-plus'

// Mock API 和 Element Plus
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

  it('fetchOrders 应正确获取订单列表', async () => {
    const mockOrders = [{ id: 1, symbol: 'EURUSD' }]
    vi.mocked(api.getOrders).mockResolvedValueOnce({
      data: { results: mockOrders, count: 1 }
    } as any)

    const { orders, fetchOrders, pagination } = useOrders()
    await fetchOrders()

    expect(api.getOrders).toHaveBeenCalledWith({
      page: 1,
      page_size: 20,
    })
    expect(orders.value).toEqual(mockOrders)
    expect(pagination.total).toBe(1)
  })

  it('createOrder 应成功创建订单', async () => {
    const newOrder = { symbol: 'EURUSD', volume: 1.0 }
    vi.mocked(api.createOrder).mockResolvedValueOnce({} as any)
    vi.mocked(api.getOrders).mockResolvedValueOnce({
      data: { results: [], count: 0 }
    } as any)

    const { createOrder, fetchOrders } = useOrders()
    await createOrder(newOrder)

    expect(api.createOrder).toHaveBeenCalledWith(newOrder)
    expect(ElMessage.success).toHaveBeenCalledWith('创建成功')
    expect(api.getOrders).toHaveBeenCalled()
  })

  it('deleteOrder 应在确认后删除订单', async () => {
    vi.mocked(ElMessageBox.confirm).mockResolvedValueOnce(undefined as any)
    vi.mocked(api.deleteOrder).mockResolvedValueOnce({} as any)
    vi.mocked(api.getOrders).mockResolvedValueOnce({
      data: { results: [], count: 0 }
    } as any)

    const { deleteOrder, fetchOrders } = useOrders()
    await deleteOrder(1)

    expect(ElMessageBox.confirm).toHaveBeenCalled()
    expect(api.deleteOrder).toHaveBeenCalledWith(1)
    expect(ElMessage.success).toHaveBeenCalledWith('删除成功')
  })

  it('exportCSV 应触发下载', async () => {
    const blob = new Blob(['test'], { type: 'text/csv' })
    vi.mocked(api.exportCSV).mockResolvedValueOnce({ data: blob } as any)
    global.URL.createObjectURL = vi.fn(() => 'blob:url')
    global.URL.revokeObjectURL = vi.fn()

    const { exportCSV } = useOrders()
    await exportCSV()

    expect(api.exportCSV).toHaveBeenCalled()
    expect(ElMessage.success).toHaveBeenCalledWith('导出成功')
    expect(global.URL.createObjectURL).toHaveBeenCalledWith(blob)
  })
})
