<template>
  <div class="customer-list">
    <div class="page-header">
      <h1>客戶列表</h1>
      <div class="header-actions">
        <el-input
          v-model="searchKeyword"
          placeholder="搜尋客戶"
          style="width: 300px"
          clearable
          @keyup.enter="fetchCustomers"
        />
        <el-button type="primary" @click="fetchCustomers">搜尋</el-button>
        <el-button @click="exportCustomers">匯出</el-button>
      </div>
    </div>

    <el-table :data="customers" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="100" />
      <el-table-column prop="email" label="Email" min-width="200" />
      <el-table-column prop="name" label="名稱" width="150" />
      <el-table-column prop="subscription_plan" label="訂閱方案" width="120">
        <template #default="{ row }">
          <el-tag :type="getPlanTag(row.subscription_plan)" size="small">
            {{ getPlanName(row.subscription_plan) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="subscription_status" label="狀態" width="100">
        <template #default="{ row }">
          <el-tag :type="row.subscription_status === 'active' ? 'success' : 'info'" size="small">
            {{ row.subscription_status === 'active' ? '已訂閱' : '未訂閱' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="practice_count" label="練習次數" width="100" align="center" />
      <el-table-column prop="avg_score" label: "平均分數" width="100" align="center" />
      <el-table-column prop="level" label="等級" width="80" align="center">
        <template #default="{ row }">
          <el-tag type="warning" size="small">Lv.{{ row.level }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="created_at" label="註冊時間" width="180" />
      <el-table-column label="操作" width="150" align="center" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="viewCustomer(row)">
            詳情
          </el-button>
          <el-button 
            v-if="row.status === 'active'"
            type="danger" 
            link 
            size="small" 
            @click="banCustomer(row)"
          >
            封禁
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="pagination">
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.limit"
        :page-sizes="[10, 20, 50, 100]"
        :total="pagination.total"
        layout="total, sizes, prev, pager, next"
        @size-change="fetchCustomers"
        @current-change="fetchCustomers"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const searchKeyword = ref('')
const customers = ref<any[]>([])
const pagination = reactive({ page: 1, limit: 20, total: 0 })

async function fetchCustomers() {
  loading.value = true
  try {
    // TODO: API call
    customers.value = [
      {
        id: 'cust-001',
        email: 'user1@example.com',
        name: '張小明',
        subscription_plan: 'premium',
        subscription_status: 'active',
        practice_count: 45,
        avg_score: 85.5,
        level: 5,
        status: 'active',
        created_at: '2024-01-15 10:30:00',
      },
    ]
    pagination.total = 1
  } catch (error: any) {
    ElMessage.error(error.message || '取得客戶列表失敗')
  } finally {
    loading.value = false
  }
}

function viewCustomer(row: any) {
  navigateTo(`/customers/${row.id}`)
}

function banCustomer(row: any) {
  ElMessageBox.confirm(`確定要封禁用戶 ${row.email} 嗎？`, '確認封禁', { type: 'warning' })
    .then(() => {
      ElMessage.success('已封禁用戶')
    })
    .catch(() => {})
}

function exportCustomers() {
  ElMessage.info('匯出功能開發中')
}

function getPlanTag(plan: string): string {
  const map: Record<string, string> = {
    free: 'info',
    basic: 'success',
    premium: 'warning',
    enterprise: 'danger',
  }
  return map[plan] || 'info'
}

function getPlanName(plan: string): string {
  const map: Record<string, string> = {
    free: '免費版',
    basic: '基礎版',
    premium: '進階版',
    enterprise: '企業版',
  }
  return map[plan] || plan
}

onMounted(() => {
  fetchCustomers()
})
</script>

<style scoped>
.customer-list { padding: 20px; }
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.page-header h1 { margin: 0; font-size: 24px; font-weight: 600; }
.header-actions { display: flex; gap: 10px; }
.pagination { display: flex; justify-content: flex-end; margin-top: 20px; }
</style>
