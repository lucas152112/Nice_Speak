<template>
  <div class="subscription-orders">
    <div class="page-header">
      <h1>訂閱列表</h1>
      <div class="header-actions">
        <el-select v-model="filters.status" placeholder="訂閱狀態" clearable style="width: 150px">
          <el-option label="待付款" value="pending" />
          <el-option label="已付款" value="paid" />
          <el-option label="已取消" value="cancelled" />
          <el-option label="已退款" value="refunded" />
        </el-select>
        <el-input
          v-model="filters.keyword"
          placeholder="搜尋訂單"
          style="width: 200px"
          clearable
        />
        <el-button type="primary" @click="fetchOrders">搜尋</el-button>
      </div>
    </div>

    <el-table :data="orders" v-loading="loading" stripe>
      <el-table-column prop="order_no" label="訂單編號" width="180" />
      <el-table-column prop="customer_email" label="客戶 Email" min-width="200" />
      <el-table-column prop="plan_name" label="訂閱方案" width="120">
        <template #default="{ row }">
          <el-tag :type="getPlanTag(row.plan_code)" size="small">
            {{ row.plan_name }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="amount" label="金額" width="100" align="right">
        <template #default="{ row }">
          ${{ row.amount.toFixed(2) }}
        </template>
      </el-table-column>
      <el-table-column prop="status" label="狀態" width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="getStatusTag(row.status)" size="small">
            {{ getStatusName(row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="payment_method" label="付款方式" width="120" />
      <el-table-column prop="created_at" label="建立時間" width="180" />
      <el-table-column prop="paid_at" label="付款時間" width="180" />
      <el-table-column label="操作" width="150" align="center">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="viewOrder(row)">
            詳情
          </el-button>
          <el-button
            v-if="row.status === 'paid'"
            type="warning"
            link
            size="small"
            @click="refundOrder(row)"
          >
            退款
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
        @current-change="fetchOrders"
      />
    </div>

    <!-- 訂單詳情 Dialog -->
    <el-dialog v-model="showDetailDialog" title="訂單詳情" width="600px">
      <el-descriptions :column="2" border v-if="currentOrder">
        <el-descriptions-item label="訂單編號" :span="2">
          {{ currentOrder.order_no }}
        </el-descriptions-item>
        <el-descriptions-item label="客戶 Email">
          {{ currentOrder.customer_email }}
        </el-descriptions-item>
        <el-descriptions-item label="訂閱方案">
          {{ currentOrder.plan_name }}
        </el-descriptions-item>
        <el-descriptions-item label="金額">
          ${{ currentOrder.amount.toFixed(2) }}
        </el-descriptions-item>
        <el-descriptions-item label="狀態">
          <el-tag :type="getStatusTag(currentOrder.status)">
            {{ getStatusName(currentOrder.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="付款方式">
          {{ currentOrder.payment_method }}
        </el-descriptions-item>
        <el-descriptions-item label="建立時間">
          {{ currentOrder.created_at }}
        </el-descriptions-item>
        <el-descriptions-item label="付款時間">
          {{ currentOrder.paid_at || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="交易編號" :span="2">
          {{ currentOrder.transaction_id || '-' }}
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const showDetailDialog = ref(false)
const currentOrder = ref<any>(null)
const orders = ref<any[]>([])
const pagination = reactive({ page: 1, limit: 20, total: 0 })
const filters = reactive({ status: '', keyword: '' })

async function fetchOrders() {
  loading.value = true
  try {
    orders.value = [
      {
        order_no: 'ORD-20240115-001',
        customer_email: 'user1@example.com',
        plan_name: '進階版',
        plan_code: 'premium',
        amount: 599.00,
        status: 'paid',
        payment_method: '信用卡',
        transaction_id: 'TXN-123456',
        created_at: '2024-01-15 10:30:00',
        paid_at: '2024-01-15 10:30:15',
      },
    ]
    pagination.total = 1
  } catch (error: any) {
    ElMessage.error(error.message)
  } finally {
    loading.value = false
  }
}

function viewOrder(order: any) {
  currentOrder.value = order
  showDetailDialog.value = true
}

function refundOrder(order: any) {
  ElMessageBox.confirm(
    `確定要退款訂單 ${order.order_no} 嗎？款項將退回客戶帳戶。`,
    '確認退款',
    { type: 'warning' }
  ).then(() => {
    ElMessage.success('退款處理中')
  })
}

function getPlanTag(code: string): string {
  const map: Record<string, string> = {
    free: 'info',
    basic: 'success',
    premium: 'warning',
  }
  return map[code] || 'info'
}

function getStatusTag(status: string): string {
  const map: Record<string, string> = {
    pending: 'warning',
    paid: 'success',
    cancelled: 'info',
    refunded: 'danger',
  }
  return map[status] || 'info'
}

function getStatusName(status: string): string {
  const map: Record<string, string> = {
    pending: '待付款',
    paid: '已付款',
    cancelled: '已取消',
    refunded: '已退款',
  }
  return map[status] || status
}

onMounted(() => {
  fetchOrders()
})
</script>

<style scoped>
.subscription-orders { padding: 20px; }
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
