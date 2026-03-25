<template>
  <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
    <el-form-item label="货币对" prop="symbol">
      <el-input v-model="formData.symbol" placeholder="请输入货币对" data-testid="symbol-input" />
    </el-form-item>
    <el-form-item label="方向" prop="direction">
      <el-select v-model="formData.direction" placeholder="请选择方向" data-testid="direction-select">
        <el-option label="买入" value="BUY" />
        <el-option label="卖出" value="SELL" />
      </el-select>
    </el-form-item>
    <el-form-item label="手数" prop="volume">
      <el-input-number v-model="formData.volume" :min="0.01" :step="0.01" data-testid="volume-input" />
    </el-form-item>
    <el-form-item label="开仓价" prop="openPrice">
      <el-input-number v-model="formData.openPrice" :precision="5" data-testid="openPrice-input" />
    </el-form-item>
    <el-form-item label="开仓时间" prop="openTime">
      <el-date-picker v-model="formData.openTime" type="datetime" placeholder="选择日期时间" data-testid="openTime-input" />
    </el-form-item>
    <el-form-item>
      <el-button type="primary" @click="submit" data-testid="submit-order-button">确定</el-button>
      <el-button @click="cancel" data-testid="cancel-order-button">取消</el-button>
    </el-form-item>
  </el-form>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import type { FormInstance, FormRules } from 'element-plus'

const props = defineProps<{
  initialData?: any
}>()
const emit = defineEmits<{
  (e: 'submit', data: any): void
  (e: 'cancel'): void
}>()

const formRef = ref<FormInstance>()
const formData = reactive({
  symbol: props.initialData?.symbol || '',
  direction: props.initialData?.direction || 'BUY',
  volume: props.initialData?.volume || null,
  openPrice: props.initialData?.openPrice || null,
  openTime: props.initialData?.openTime || new Date(),
})

const rules: FormRules = {
  symbol: [{ required: true, message: '请输入货币对', trigger: 'blur' }],
  volume: [{ required: true, message: '请输入手数', trigger: 'blur' }],
  openPrice: [{ required: true, message: '请输入开仓价', trigger: 'blur' }],
  openTime: [{ required: true, message: '请选择开仓时间', trigger: 'change' }],
}

const submit = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => {
    if (valid) emit('submit', { ...formData })
  })
}
const cancel = () => emit('cancel')
</script>
