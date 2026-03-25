import { describe, it, expect, vi } from 'vitest'
import * as api from '@/api/orders'
import axios from '@/utils/axios'

vi.mock('@/utils/axios')

describe('orders api', () => {
  it('getOrders should call axios.get with correct params', async () => {
    const mockParams = { page: 1, page_size: 20 }
    await api.getOrders(mockParams)
    expect(axios.get).toHaveBeenCalledWith('/api/orders/', { params: mockParams })
  })

  it('createOrder should call axios.post', async () => {
    const data = { symbol: 'EURUSD' }
    await api.createOrder(data)
    expect(axios.post).toHaveBeenCalledWith('/api/orders/', data)
  })

  it('importCSV should send FormData', async () => {
    const file = new File(['test'], 'test.csv')
    await api.importCSV(file)
    expect(axios.post).toHaveBeenCalledWith('/api/orders/import-csv/', expect.any(FormData), {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  })
})
