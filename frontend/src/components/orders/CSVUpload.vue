<template>
  <div>
    <el-upload
      class="upload-demo"
      drag
      action=""
      :http-request="handleUpload"
      :before-upload="beforeUpload"
      :show-file-list="false"
    >
      <el-icon class="el-icon--upload"><UploadFilled /></el-icon>
      <div class="el-upload__text">
        将 CSV 文件拖到此处，或<em>点击上传</em>
      </div>
      <template #tip>
        <div class="el-upload__tip">
          支持 MT4/5 导出的 CSV 格式，文件大小不超过 5MB
        </div>
      </template>
    </el-upload>

    <el-dialog v-model="dialogVisible" title="导入进度" width="30%">
      <div v-if="taskState === 'PENDING' || taskState === 'PROGRESS'">
        <el-progress :percentage="50" indeterminate />
        <p>正在处理，请稍后...</p>
      </div>
      <div v-else-if="taskState === 'SUCCESS'">
        <el-alert
          title="导入完成"
          type="success"
          :description="`成功导入 ${importResult.created} 条订单，失败 ${importResult.errors.length} 条`"
          show-icon
        />
        <div v-if="importResult.errors.length" style="margin-top: 10px">
          <el-collapse>
            <el-collapse-item title="查看错误详情">
              <ul>
                <li v-for="(err, idx) in importResult.errors" :key="idx">{{ err }}</li>
              </ul>
            </el-collapse-item>
          </el-collapse>
        </div>
      </div>
      <div v-else-if="taskState === 'FAILURE'">
        <el-alert title="导入失败" type="error" :description="importError" show-icon />
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { UploadFilled } from '@element-plus/icons-vue'
import axios from '@/utils/axios'

const emit = defineEmits<{
  (e: 'refresh'): void
}>()

const dialogVisible = ref(false)
const taskId = ref('')
const taskState = ref('')
const importResult = ref<any>(null)
const importError = ref('')
let pollTimer: any = null

const beforeUpload = (file: File) => {
  const isCSV = file.type === 'text/csv' || file.name.endsWith('.csv')
  if (!isCSV) {
    ElMessage.error('只能上传 CSV 文件')
    return false
  }
  const isLt5M = file.size / 1024 / 1024 < 5
  if (!isLt5M) {
    ElMessage.error('文件大小不能超过 5MB')
    return false
  }
  return true
}

const handleUpload = async (options: any) => {
  const formData = new FormData()
  formData.append('file', options.file)

  try {
    const response = await axios.post('/api/orders/import-csv/', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    taskId.value = response.data.task_id
    dialogVisible.value = true
    startPolling()
  } catch (error: any) {
    ElMessage.error(error.response?.data?.error || '上传失败')
  }
}

const startPolling = () => {
  if (pollTimer) clearInterval(pollTimer)
  pollTimer = setInterval(async () => {
    try {
      const res = await axios.get(`/api/orders/import-status/${taskId.value}/`)
      taskState.value = res.data.state
      if (res.data.state === 'SUCCESS') {
        importResult.value = res.data.result
        clearInterval(pollTimer)
        emit('refresh')
      } else if (res.data.state === 'FAILURE') {
        importError.value = res.data.error
        clearInterval(pollTimer)
      }
    } catch (error) {
      console.error('轮询状态失败', error)
      clearInterval(pollTimer)
    }
  }, 2000)
}
</script>

<style scoped>
</style>
