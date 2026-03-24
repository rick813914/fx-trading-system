<!-- src/views/Orders.vue -->
<template>
  <div class="orders-container">
    <div class="header">
      <h2>订单管理</h2>
      <el-button type="primary" @click="openCreateDialog">新建订单</el-button>
    </div>

    <!-- 筛选栏 -->
    <el-form :inline="true" class="filter-form">
      <el-form-item label="货币对">
        <el-input v-model="filters.symbol" placeholder="请输入" clearable @change="fetchOrders" />
      </el-form-item>
      <el-form-item label="方向">
        <el-select v-model="filters.direction" clearable placeholder="请选择" @change="fetchOrders">
          <el-option label="买入" value="BUY" />
          <el-option label="卖出" value="SELL" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="fetchOrders">搜索</el-button>
        <el-button @click="resetFilters">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 订单表格 -->
    <el-table :data="orders" v-loading="loading" border style="width: 100%">
      <el-table-column prop="symbol" label="货币对" />
      <el-table-column prop="volume" label="手数" />
      <el-table-column prop="direction" label="方向" :formatter="formatDirection" />
      <el-table-column prop="open_price" label="开仓价" />
      <el-table-column prop="close_price" label="平仓价" />
      <el-table-column prop="open_time" label="开仓时间" />
      <el-table-column prop="profit" label="盈亏">
        <template #default="{ row }">
          <span :style="{ color: row.profit > 0 ? 'green' : row.profit < 0 ? 'red' : 'black' }">
            {{ row.profit }}
          </span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150">
        <template #default="{ row }">
          <el-button type="primary" size="small" @click="openEditDialog(row)">编辑</el-button>
          <el-button type="danger" size="small" @click="deleteOrder(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <el-pagination
      v-model:current-page="pagination.page"
      v-model:page-size="pagination.pageSize"
      :total="pagination.total"
      :page-sizes="[10, 20, 50]"
      layout="total, sizes, prev, pager, next, jumper"
      @size-change="fetchOrders"
      @current-change="fetchOrders"
      style="margin-top: 20px"
    />

    <!-- 新建/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="货币对" prop="symbol">
          <el-input v-model="form.symbol" />
        </el-form-item>
        <el-form-item label="手数" prop="volume">
          <el-input-number v-model="form.volume" :precision="2" :step="0.01" />
        </el-form-item>
        <el-form-item label="方向" prop="direction">
          <el-radio-group v-model="form.direction">
            <el-radio label="BUY">买入</el-radio>
            <el-radio label="SELL">卖出</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="开仓价" prop="open_price">
          <el-input-number v-model="form.open_price" :precision="5" :step="0.00001" />
        </el-form-item>
        <el-form-item label="平仓价" prop="close_price">
          <el-input-number v-model="form.close_price" :precision="5" :step="0.00001" />
        </el-form-item>
        <el-form-item label="开仓时间" prop="open_time">
          <el-date-picker v-model="form.open_time" type="datetime" placeholder="选择日期时间" />
        </el-form-item>
        <el-form-item label="平仓时间" prop="close_time">
          <el-date-picker v-model="form.close_time" type="datetime" placeholder="选择日期时间" />
        </el-form-item>
        <el-form-item label="盈亏" prop="profit">
          <el-input-number v-model="form.profit" :precision="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import axios from '@/utils/axios'
import { ElMessage, ElMessageBox, FormInstance } from 'element-plus'

// 定义订单类型
interface Order {
  id?: number
  symbol: string
  volume: number
  direction: 'BUY' | 'SELL'
  open_price: number
  close_price?: number | null
  open_time: string
  close_time?: string | null
  profit: number
}

// 状态
const orders = ref<Order[]>([])
const loading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新建订单')
const formRef = ref<FormInstance>()
const form = reactive<Order>({
  symbol: '',
  volume: 0,
  direction: 'BUY',
  open_price: 0,
  close_price: null,
  open_time: '',
  close_time: null,
  profit: 0
})
const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})
const filters = reactive({
  symbol: '',
  direction: ''
})

// 表单验证规则
const rules = {
  symbol: [{ required: true, message: '请输入货币对', trigger: 'blur' }],
  volume: [{ required: true, message: '请输入手数', trigger: 'blur' }],
  direction: [{ required: true, message: '请选择方向', trigger: 'change' }],
  open_price: [{ required: true, message: '请输入开仓价', trigger: 'blur' }],
  open_time: [{ required: true, message: '请选择开仓时间', trigger: 'change' }],
}

// 获取订单列表
async function fetchOrders() {
  loading.value = true
  try {
    const params: any = {
      page: pagination.page,
      page_size: pagination.pageSize,
    }
    if (filters.symbol) params.symbol = filters.symbol
    if (filters.direction) params.direction = filters.direction

    const response = await axios.get('/api/orders/', { params })
    orders.value = response.data.results
    pagination.total = response.data.count
  } catch (error) {
    ElMessage.error('获取订单失败')
  } finally {
    loading.value = false
  }
}

// 重置筛选
function resetFilters() {
  filters.symbol = ''
  filters.direction = ''
  pagination.page = 1
  fetchOrders()
}

// 打开新建对话框
function openCreateDialog() {
  dialogTitle.value = '新建订单'
  Object.assign(form, {
    id: undefined,
    symbol: '',
    volume: 0,
    direction: 'BUY',
    open_price: 0,
    close_price: null,
    open_time: '',
    close_time: null,
    profit: 0
  })
  dialogVisible.value = true
}

// 打开编辑对话框
function openEditDialog(row: Order) {
  dialogTitle.value = '编辑订单'
  // 复制数据，避免直接修改原数据
  Object.assign(form, {
    ...row,
    close_price: row.close_price ?? null,
    close_time: row.close_time ?? null,
  })
  dialogVisible.value = true
}

// 提交表单（新建或编辑）
async function submitForm() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      if (form.id) {
        // 更新
        await axios.put(`/api/orders/${form.id}/`, form)
        ElMessage.success('更新成功')
      } else {
        // 新建
        await axios.post('/api/orders/', form)
        ElMessage.success('创建成功')
      }
      dialogVisible.value = false
      fetchOrders() // 刷新列表
    } catch (error) {
      ElMessage.error('操作失败')
    }
  })
}

// 删除订单
function deleteOrder(row: Order) {
  ElMessageBox.confirm('确认删除该订单吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await axios.delete(`/api/orders/${row.id}/`)
      ElMessage.success('删除成功')
      fetchOrders()
    } catch (error) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

// 格式化方向显示
function formatDirection(row: Order) {
  return row.direction === 'BUY' ? '买入' : '卖出'
}

// 初始加载
onMounted(() => {
  fetchOrders()
})
</script>

<style scoped>
.orders-container {
  padding: 20px;
}
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.filter-form {
  margin-bottom: 20px;
}
</style>
