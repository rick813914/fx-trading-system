// src/utils/format.ts
export const formatCurrency = (value: number, currency = 'USD') => {
  return new Intl.NumberFormat('zh-CN', {
    style: 'currency',
    currency,
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value)
}
