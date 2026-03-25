// src/utils/date.ts
import dayjs from 'dayjs'  // 需安装 dayjs: npm install dayjs

export const formatDateTime = (date: string | Date, format = 'YYYY-MM-DD HH:mm:ss') => {
  return dayjs(date).format(format)
}
