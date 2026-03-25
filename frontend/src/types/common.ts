// src/types/common.ts
// 通用类型定义，例如分页响应结构等
export interface PaginatedResponse<T> {
  count: number
  next: string | null
  previous: string | null
  results: T[]
}
