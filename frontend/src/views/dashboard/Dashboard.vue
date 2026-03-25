<!-- src/views/Dashboard.vue -->
<template>
  <div class="dashboard">
    <h2>仪表盘</h2>
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card>
          <div class="kpi-card">
            <div class="kpi-title">总订单数</div>
            <div class="kpi-value">{{ stats.total_orders }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <div class="kpi-card">
            <div class="kpi-title">总盈亏 (USD)</div>
            <div class="kpi-value" :class="stats.total_profit > 0 ? 'positive' : 'negative'">
              {{ stats.total_profit }}
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <div class="kpi-card">
            <div class="kpi-title">胜率 (%)</div>
            <div class="kpi-value">{{ stats.win_rate }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <div class="kpi-card">
            <div class="kpi-title">平均盈亏 (USD)</div>
            <div class="kpi-value">{{ stats.avg_profit }}</div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import axios from '@/utils/axios'

// 统计数据
const stats = ref({
  total_orders: 0,
  total_profit: 0,
  win_rate: 0,
  avg_profit: 0,
})

// 获取 KPI 数据
async function fetchKPI() {
  try {
    // 后端 KPI API 尚未实现，暂时模拟数据
    // 实际对接时改为：const response = await axios.get('/api/kpi/')
    // stats.value = response.data

    // 模拟数据（后续替换为真实API）
    const response = await axios.get('/api/kpi/')
    stats.value = response.data
  } catch (error) {
    console.error('获取KPI失败', error)
  }
}

onMounted(() => {
  fetchKPI()
})
</script>

<style scoped>
.dashboard {
  padding: 20px;
}
.kpi-card {
  text-align: center;
}
.kpi-title {
  font-size: 14px;
  color: #666;
  margin-bottom: 10px;
}
.kpi-value {
  font-size: 28px;
  font-weight: bold;
}
.positive {
  color: green;
}
.negative {
  color: red;
}
</style>
