<template>
  <div class="login-logs">
    <div class="page-header">
      <h1>登入日誌</h1>
      <div class="header-actions">
        <el-select v-model="filters.status" placeholder="登入狀態" clearable style="width: 150px">
          <el-option label="成功" value="success" />
          <el-option label="失敗" value="failed" />
        </el-select>
        <el-date-picker
          v-model="filters.dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="開始日期"
          end-placeholder="結束日期"
          style="width: 250px"
        />
        <el-button @click="exportLogs">匯出</el-button>
      </div>
    </div>

    <el-table :data="logs" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="admin_email" label="管理員" min-width="200" />
      <el-table-column prop="action" label="動作" width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="row.action === 'login' ? 'success' : 'warning'" size="small">
            {{ row.action === 'login' ? '登入' : '登出' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="狀態" width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="row.status === 'success' ? 'success' : 'danger'" size="small">
            {{ row.status === 'success' ? '成功' : '失敗' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="ip" label="IP 位址" width="140" />
      <el-table-column prop="location" label="位置" width="150" />
      <el-table-column prop="device" label="裝置" min-width="200" />
      <el-table-column prop="created_at" label="時間" width="180" />
      <el-table-column v-if="!isCollapsed" prop="fail_reason" label="失敗原因" width="200">
        <template #default="{ row }">
          <span v-if="row.status === 'failed'" class="fail-reason">
            {{ row.fail_reason }}
          </span>
          <span v-else>-</span>
        </template>
      </el-table-column>
    </el-table>

    <div class="pagination">
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.limit"
        :total="pagination.total"
        layout="total, prev, pager, next"
        @current-change="fetchLogs"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'

const loading = ref(false)
const isCollapsed = ref(false)
const logs = ref<any[]>([])
const pagination = reactive({ page: 1, limit: 20, total: 0 })
const filters = reactive({
  status: '',
  dateRange: null as [Date, Date] | null,
})

async function fetchLogs() {
  loading.value = true
  try {
    logs.value = [
      {
        id: 'log-001',
        admin_email: 'admin@nicespeak.app',
        action: 'login',
        status: 'success',
        ip: '192.168.1.100',
        location: '台灣',
        device: 'Chrome 120 / Windows 10',
        fail_reason: null,
        created_at: '2024-01-15 10:30:00',
      },
      {
        id: 'log-002',
        admin_email: 'admin@nicespeak.app',
        action: 'login',
        status: 'failed',
        ip: '192.168.1.100',
        location: '台灣',
        device: 'Chrome 120 / Windows 10',
        fail_reason: '密碼錯誤',
        created_at: '2024-01-15 09:15:00',
      },
    ]
    pagination.total = 2
  } catch (error: any) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

function exportLogs() {
  console.log('Export login logs')
}

onMounted(() => {
  fetchLogs()
})
</script>

<style scoped>
.login-logs { padding: 20px; }
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.page-header h1 { margin: 0; font-size: 24px; font-weight: 600; }
.header-actions { display: flex; gap: 10px; }
.pagination { display: flex; justify-content: flex-end; margin-top: 20px; }
.fail-reason { color: #f56c6c; font-size: 13px; }
</style>
