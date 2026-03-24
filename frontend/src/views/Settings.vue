<!-- src/views/Settings.vue -->
<template>
  <div class="settings">
    <h2>系统设置</h2>
    <el-form :model="user" label-width="120px">
      <el-form-item label="时区">
        <el-select v-model="user.timezone" @change="updateProfile">
          <el-option label="UTC" value="UTC" />
          <el-option label="Asia/Shanghai" value="Asia/Shanghai" />
          <el-option label="America/New_York" value="America/New_York" />
        </el-select>
      </el-form-item>
      <el-form-item label="默认货币">
        <el-select v-model="user.currency" @change="updateProfile">
          <el-option label="USD" value="USD" />
          <el-option label="EUR" value="EUR" />
          <el-option label="CNY" value="CNY" />
        </el-select>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import axios from '@/utils/axios'
import { ElMessage } from 'element-plus'

const authStore = useAuthStore()
const user = ref({ timezone: 'UTC', currency: 'USD' })

// 获取用户资料
async function fetchProfile() {
  try {
    const response = await axios.get('/api/users/profile/')
    user.value = {
      timezone: response.data.timezone,
      currency: response.data.currency,
    }
  } catch (error) {
    ElMessage.error('获取用户资料失败')
  }
}

// 更新用户资料
async function updateProfile() {
  try {
    await axios.patch('/api/users/profile/', user.value)
    ElMessage.success('保存成功')
    // 同步到 store
    if (authStore.user) {
      authStore.user.timezone = user.value.timezone
      authStore.user.currency = user.value.currency
    }
  } catch (error) {
    ElMessage.error('保存失败')
  }
}

onMounted(() => {
  fetchProfile()
})
</script>

<style scoped>
.settings {
  padding: 20px;
}
</style>
