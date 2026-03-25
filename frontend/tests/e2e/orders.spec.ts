import { test, expect } from '@playwright/test'

test.describe('订单管理端到端测试', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login')
    await page.waitForLoadState('networkidle')
    await page.fill('[data-testid="username-input"]', 'testuser')
    await page.fill('[data-testid="password-input"]', 'testpass123')
    await page.click('[data-testid="login-button"]')
    await page.waitForURL('/')
    await page.waitForLoadState('networkidle')

    // 进入订单管理页面（确保文本匹配）
    await page.click('text=订单管理')
    await page.waitForURL('/orders')
    await page.waitForLoadState('networkidle')
  })

  test('手动创建订单', async ({ page }) => {
    await page.click('[data-testid="new-order-button"]')
    await page.waitForSelector('.el-dialog', { timeout: 5000 })

    await page.fill('[data-testid="symbol-input"]', 'EURUSD')
    await page.fill('[data-testid="volume-input"] input', '1.0')
    await page.fill('[data-testid="openPrice-input"] input', '1.1000')

    // 通过 label 定位表单项，再点击内部的输入框
    const dateFormItem = page.getByLabel('开仓时间')
    await dateFormItem.locator('input').click()
    await page.waitForSelector('.el-picker-panel', { timeout: 5000 })
    await page.locator('.el-date-table .available:first-child').click()
    await page.click('[data-testid="submit-order-button"]')
    await expect(page.locator('.el-message--success')).toBeVisible()
    await page.waitForSelector('.el-overlay', { state: 'hidden', timeout: 5000 })
    await expect(page.locator('text=EURUSD').first()).toBeVisible()
  })

  test('导入 CSV 文件', async ({ page }) => {
    await page.click('[data-testid="import-csv-button"]')
    await page.waitForSelector('.el-dialog', { timeout: 5000 })
    const fileInput = page.locator('[data-testid="csv-upload-area"] input[type="file"]')
    await fileInput.setInputFiles('./tests/e2e/fixtures/mt4-orders.csv')
    await expect(page.locator('text=EURUSD').first()).toBeVisible({ timeout: 30000 })
    await page.click('[data-testid="close-import-dialog"]')
    await page.waitForSelector('.el-overlay', { state: 'hidden', timeout: 5000 })
  })

  test('导出 CSV', async ({ page }) => {
    const downloadPromise = page.waitForEvent('download')
    await page.click('[data-testid="export-csv-button"]')
    const download = await downloadPromise
    expect(download.suggestedFilename()).toBe('orders_export.csv')
  })

  test('编辑订单', async ({ page }) => {
    // 先创建一条订单
    await page.click('[data-testid="new-order-button"]')
    await page.waitForSelector('.el-dialog')
    await page.fill('[data-testid="symbol-input"]', 'EURUSD')
    await page.fill('[data-testid="volume-input"] input', '1.0')
    await page.fill('[data-testid="openPrice-input"] input', '1.1000')
    const dateFormItem = page.getByLabel('开仓时间')
    await dateFormItem.locator('input').click()
    await page.waitForSelector('.el-picker-panel')
    await page.locator('.el-date-table .available:first-child').click()
    await page.click('[data-testid="submit-order-button"]')
    await expect(page.locator('.el-message--success')).toBeVisible()
    await page.waitForSelector('.el-overlay', { state: 'hidden' })
    await expect(page.locator('text=EURUSD').first()).toBeVisible()

    // 编辑
    await page.click('[data-testid="edit-order-button"]')
    await page.waitForSelector('.el-dialog')
    await page.fill('[data-testid="volume-input"] input', '2.0')
    await page.click('[data-testid="submit-order-button"]')
    await expect(page.locator('.el-message--success')).toBeVisible()
    await page.waitForSelector('.el-overlay', { state: 'hidden' })
    await expect(page.locator('text=2.0').first()).toBeVisible()
  })

  test('删除订单', async ({ page }) => {
    // 先创建一条订单
    await page.click('[data-testid="new-order-button"]')
    await page.waitForSelector('.el-dialog')
    await page.fill('[data-testid="symbol-input"]', 'EURUSD')
    await page.fill('[data-testid="volume-input"] input', '1.0')
    await page.fill('[data-testid="openPrice-input"] input', '1.1000')
    const dateFormItem = page.getByLabel('开仓时间')
    await dateFormItem.locator('input').click()
    await page.waitForSelector('.el-picker-panel')
    await page.locator('.el-date-table .available:first-child').click()
    await page.click('[data-testid="submit-order-button"]')
    await expect(page.locator('.el-message--success')).toBeVisible()
    await page.waitForSelector('.el-overlay', { state: 'hidden' })
    await expect(page.locator('text=EURUSD').first()).toBeVisible()

    // 删除
    await page.click('[data-testid="delete-order-button"]')
    await page.waitForSelector('.el-message-box')
    await page.getByRole('button', { name: '确定' }).click()
    await expect(page.locator('.el-message--success')).toBeVisible()
    await expect(page.locator('text=EURUSD').first()).not.toBeVisible()
  })
})
