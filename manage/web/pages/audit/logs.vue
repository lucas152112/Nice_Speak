<template>
  <div class="audit-logs">
    <div class="page-header">
      <h1>操作日誌</h1>
      <div class="header-actions">
        <el-select v-model="filters.module" placeholder="選擇模組" clearable style="width: 150px">
          <el-option label="用戶管理" value="users" />
          <el-option label="客戶管理" value="customers" />
          <el-option label="情境管理" value="scenarios" />
          <el-option label="訂閱管理" value="subscriptions" />
          <el-option label="系統設定" value="settings" />
        </el-select>
        <el-select v-model="filters.action" placeholder="選擇動作" clearable style="width: 150px">
          <el-option label="新增" value="create" />
          <el-option label="更新" value="update" />
          <el-option label="刪除" value="delete" />
          <el-option label="登入" value="login" />
          <el-option label="登出" value="logout" />
        </el-select>
        <el-button @click="exportLogs">匯出</el-button>
      </div>
    </div>

    <el-table :data="logs" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="created_at" label="時間" width="180" />
      <el-table-column prop="admin_name" label="管理員" width="120" />
      <el-table-column prop="module" label="模組" width="120">
        <template #default="{ row }">
          <el-tag size="small">{{ getModuleName(row.module) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="action" label="動作" width="100">
        <template #default="{ row }">
          <el-tag :type="getActionTag(row.action)" size="small">
            {{ getActionName(row.action) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="target" label="操作對象" min-width="200" />
      <el-table-column prop="ip" label="IP" width="140" />
      <el-table-column prop="status" label="狀態" width="100">
        <template #default="{ row }">
          <el-tag :type="row.status === 'success' ? 'success' : 'danger'" size="small">
            {{ row.status === 'success' ? '成功' : '失敗' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="詳情" width="80" align="center">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="viewDetail(row)">
            查看
          </el-button>
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

    <!-- 詳情 Dialog -->
    <el-dialog v-model="showDetailDialog" title="日誌詳情" width="500px">
      <el-descriptions :column="1" border v-if="currentLog">
        <el-descriptions-item label="ID">{{ currentLog.id }}</el-descriptions-item>
        <el-descriptions-item label="時間">{{ currentLog.created_at }}</el-descriptions-item>
        <el-descriptions-item label="管理員">{{ currentLog.admin_name }}</el-descriptions-item>
        <el-descriptions-item label="IP">{{ currentLog.ip }}</el-descriptions-item>
        <el-descriptions-item label="User Agent">{{ currentLog.user_agent }}</el-descriptions-item>
        <el-descriptions-item label="操作內容">
          <pre>{{ currentLog.details }}</pre>
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'

const loading = ref(false)
const showDetailDialog = ref(false)
const currentLog = ref<any>(null)
const logs = ref<any[]>([])
const pagination = reactive({ page: 1, limit: 20, total: 0 })
const filters = reactive({ module: '', action: '' })

async function fetchLogs() {
  loading.value = true
  try {
    logs.value = [
      {
        id: 'log-001',
        created_at: '2024-01-15 10:30:00',
        admin_name: '超級管理員',
        module: 'users',
        action: 'create',
        target: '新增用戶: admin2@nicespeak.app',
        ip: '192.168.1.100',
        status: 'success',
        user_agent: 'Mozilla/5.0...',
        details: JSON.stringify({ email: 'admin2@nicespeak.app', role: 'system_admin' }, null, 2),
      },
    ]
    pagination.total = 1
  } catch (error: any) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

function viewDetail(log: any) {
  currentLog.value = log
  showDetailDialog.value = true
}

function exportLogs() {
  console.log('Export logs')
}

function getModuleName(module: string): string {
  const map: Record<string, string> = {
    users: '用戶管理',
    customers: '客戶管理',
    scenarios: '情境管理',
    subscriptions: '訂閱管理',
    settings: '系統設定',
  }
  return map[module] || module
}

function getActionName(action: string): string {
  const map: Record<string, string> = {
    create: '新增',
    update: '更新',
    delete: '刪除',
    login: '登入',
    logout: '登出',
  }
  return map[action] || action
}

function getActionTag(action: string): string {
  const map: Record<string, string> = {
    create: 'success',
    update: 'warning',
    delete: 'danger',
    login: 'info',
    logout: 'info',
  }
  return map[action] || 'info'
}

onMounted(() => {
  fetchLogs()
})
</script>

<style scoped>
.audit-logs { padding: 20px; }
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.page-header h1 { margin: 0; font-size: 24px; font-weight: 600; }
.header-actions { display: flex; gap: 10px; }
.pagination { display: flex; justify-content: flex-end; margin-top: 20px; }
pre {
  margin: 0;
  white-space: pre-wrap;
  font-family: monospace;
  font-size: 12px;
  background: #f5f7fa;
  padding: 10px;
  border-radius: 4px;
}
</style>
