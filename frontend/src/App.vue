<template>
  <div id="app">
    <el-container>
      <el-header v-if="authStore.token">
        <el-menu mode="horizontal" router>
          <el-menu-item index="/">仪表盘</el-menu-item>
          <el-menu-item index="/orders">订单管理</el-menu-item>
          <el-menu-item index="/settings">系统设置</el-menu-item>
          <el-menu-item style="float: right" @click="logout">退出登录</el-menu-item>
        </el-menu>
      </el-header>
      <el-main>
        <router-view />
      </el-main>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

const authStore = useAuthStore()
const router = useRouter()

function logout() {
  authStore.logout()
  ElMessage.success('已退出登录')
  router.push('/login')
}
</script>

<style>
body {
  margin: 0;
}
.el-header {
  background-color: #409eff;
  color: white;
  line-height: 60px;
}
.el-menu {
  background-color: #409eff;
}
.el-menu-item {
  color: white;
}
.el-menu-item.is-active {
  background-color: #66b1ff;
}
</style>
