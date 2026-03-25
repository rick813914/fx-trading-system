// src/types/orders.ts
export interface Order {
  id?: number
  symbol: string
  volume: number
  direction: 'BUY' | 'SELL'
  open_price: number
  close_price?: number | null
  open_time: string
  close_time?: string | null
  profit: number
  ticket?: string
  commission?: number
  swap?: number
  comment?: string
}

export interface OrderListParams {
  page?: number
  page_size?: number
  symbol?: string
  direction?: string
}

export interface ImportStatusResponse {
  state: 'PENDING' | 'PROGRESS' | 'SUCCESS' | 'FAILURE'
  result?: {
    status: string
    created: number
    errors: string[]
    total: number
  }
  error?: string
}
