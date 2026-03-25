import { test, expect } from '@playwright/test'

test.describe('订单管理端到端测试', () => {
  test.beforeEach(async ({ page }) => {
    // 登录
    await page.goto('/login')
    await page.fill('input[name="username"]', 'testuser')
    await page.fill('input[name="password"]', 'testpass123')
    await page.click('button[type="submit"]')
    await page.waitForURL('/dashboard')
  })

  test('手动创建订单', async ({ page }) => {
    await page.click('text=订单管理')
    await page.click('text=新建订单')

    // 填写表单
    await page.fill('input[placeholder="请输入货币对"]', 'EURUSD')
    await page.fill('input[placeholder="请输入手数"]', '1.0')
    await page.fill('input[placeholder="请输入开仓价"]', '1.1000')
    // 选择开仓时间（简单选择日期选择器的第一个日期）
    await page.click('input[placeholder="选择日期时间"]')
    await page.click('.el-date-picker .el-date-table .available:first-child')

    await page.click('button:has-text("确定")')
    await expect(page.locator('.el-message--success')).toBeVisible()
    await expect(page.locator('text=EURUSD')).toBeVisible()
  })

  test('导入 CSV 文件', async ({ page }) => {
    await page.click('text=订单管理')
    await page.click('text=导入 CSV')

    // 上传文件（假设测试文件放在 fixtures 目录）
    const fileInput = page.locator('input[type="file"]')
    await fileInput.setInputFiles('./tests/e2e/fixtures/mt4-orders.csv')

    // 等待导入完成
    await expect(page.locator('text=正在处理')).toBeVisible()
    await expect(page.locator('text=导入完成')).toBeVisible({ timeout: 30000 })
    await expect(page.locator('text=成功导入 2 条订单')).toBeVisible()

    // 关闭对话框
    await page.click('button:has-text("关闭")')
    await expect(page.locator('text=EURUSD')).toBeVisible()
  })

  test('导出 CSV', async ({ page }) => {
    await page.click('text=订单管理')
    const downloadPromise = page.waitForEvent('download')
    await page.click('text=导出 CSV')
    const download = await downloadPromise
    expect(download.suggestedFilename()).toBe('orders_export.csv')
  })

  test('编辑订单', async ({ page }) => {
    // 先创建一个订单
    await page.click('text=订单管理')
    await page.click('text=新建订单')
    await page.fill('input[placeholder="请输入货币对"]', 'EURUSD')
    await page.fill('input[placeholder="请输入手数"]', '1.0')
    await page.fill('input[placeholder="请输入开仓价"]', '1.1000')
    await page.click('button:has-text("确定")')
    await expect(page.locator('text=EURUSD')).toBeVisible()

    // 编辑该订单
    await page.click('button:has-text("编辑")')
    await page.fill('input[placeholder="请输入手数"]', '2.0')
    await page.click('button:has-text("确定")')
    await expect(page.locator('.el-message--success')).toBeVisible()
    await expect(page.locator('text=2.0')).toBeVisible()
  })

  test('删除订单', async ({ page }) => {
    // 创建一个订单
    await page.click('text=订单管理')
    await page.click('text=新建订单')
    await page.fill('input[placeholder="请输入货币对"]', 'EURUSD')
    await page.fill('input[placeholder="请输入手数"]', '1.0')
    await page.click('button:has-text("确定")')
    await expect(page.locator('text=EURUSD')).toBeVisible()

    // 删除订单
    await page.click('button:has-text("删除")')
    await page.click('button:has-text("确定")')
    await expect(page.locator('.el-message--success')).toBeVisible()
    await expect(page.locator('text=EURUSD')).not.toBeVisible()
  })
})
