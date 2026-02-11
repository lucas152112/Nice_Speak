<template>
  <div class="customer-detail">
    <div class="page-header">
      <el-page-header @back="router.back()">
        <template #content>
          <span class="page-title">客戶詳情</span>
        </template>
      </el-page-header>
    </div>

    <div class="detail-grid">
      <!-- 基本資訊 -->
      <el-card shadow="never">
        <template #header>
          <span>基本資訊</span>
        </template>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="客戶 ID">{{ customer.id }}</el-descriptions-item>
          <el-descriptions-item label="Email">
            <a :href="'mailto:' + customer.email">{{ customer.email }}</a>
          </el-descriptions-item>
          <el-descriptions-item label="名稱">{{ customer.name }}</el-descriptions-item>
          <el-descriptions-item label="電話">{{ customer.phone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="註冊時間">{{ customer.created_at }}</el-descriptions-item>
          <el-descriptions-item label="最後登入">{{ customer.last_login_at || '-' }}</el-descriptions-item>
          <el-descriptions-item label="狀態">
            <el-tag :type="customer.status === 'active' ? 'success' : 'danger'" size="small">
              {{ customer.status === 'active' ? '正常' : '已封禁' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="訂閱狀態">
            <el-tag :type="customer.subscription_status === 'active' ? 'success' : 'info'" size="small">
              {{ customer.subscription_status === 'active' ? '已訂閱' : '未訂閱' }}
            </el-tag>
          </el-descriptions-item>
        </el-descriptions>
      </el-card>

      <!-- 訂閱資訊 -->
      <el-card shadow="never">
        <template #header>
          <span>訂閱資訊</span>
        </template>
        <el-descriptions :column="1" border>
          <el-descriptions-item label="訂閱方案">
            <el-tag :type="getPlanTag(customer.subscription_plan)" size="small">
              {{ getPlanName(customer.subscription_plan) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="訂閱開始">
            {{ customer.subscription_start_at || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="訂閱到期">
            {{ customer.subscription_end_at || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="剩餘天數">
            {{ customer.subscription_days_remaining ?? '-' }} 天
          </el-descriptions-item>
        </el-descriptions>
      </el-card>

      <!-- 等級與統計 -->
      <el-card shadow="never">
        <template #header>
          <span>等級與統計</span>
        </template>
        <div class="level-section">
          <div class="level-badge">
            <span class="level-number">Lv.{{ customer.level }}</span>
            <span class="level-name">{{ getLevelName(customer.level) }}</span>
          </div>
          <el-progress 
            :percentage="customer.level_progress" 
            :stroke-width="10"
            :format="() => `${customer.level_progress}%`"
          />
          <p class="level-hint">距離下一級還需 {{ customer.xp_to_next_level }} XP</p>
        </div>
        <el-divider />
        <div class="stats-row">
          <div class="stat-item">
            <div class="stat-value">{{ customer.total_practices }}</div>
            <div class="stat-label">總練習次數</div>
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ customer.avg_score }}</div>
            <div class="stat-label">平均分數</div>
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ customer.current_streak }}</div>
            <div class="stat-label">連續練習天數</div>
          </div>
        </div>
      </el-card>

      <!-- 操作區域 -->
      <el-card shadow="never">
        <template #header>
          <span>管理操作</span>
        </template>
        <div class="actions-section">
          <el-button 
            v-if="customer.status === 'active'"
            type="danger" 
            @click="banCustomer"
          >
            封禁客戶
          </el-button>
          <el-button 
            v-else
            type="success" 
            @click="unbanCustomer"
          >
            解除封禁
          </el-button>
          <el-button @click="resetPassword">
            重置密碼
          </el-button>
          <el-button @click="extendSubscription">
            延長訂閱
          </el-button>
          <el-button @click="viewDevices">
            查看設備
          </el-button>
        </div>
      </el-card>
    </div>

    <!-- 標籤頁 -->
    <el-card shadow="never" class="tabs-card">
      <el-tabs v-model="activeTab">
        <el-tab-pane label="練習記錄" name="practices">
          <el-table :data="practices" stripe>
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="scenario_title" label="情境" min-width="200" />
            <el-table-column prop="score" label="分數" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="getScoreTag(row.score)" size="small">
                  {{ row.score }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="created_at" label="練習時間" width="180" />
            <el-table-column label="操作" width="100" align="center">
              <el-button type="primary" link size="small">詳情</el-button>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <el-tab-pane label="訂閱歷史" name="subscriptions">
          <el-table :data="subscriptionHistory" stripe>
            <el-table-column prop="plan_name" label="方案" width="150" />
            <el-table-column prop="amount" label="金額" width="100" align="right">
              <template #default="{ row }">
                ${{ row.amount }}
              </template>
            </el-table-column>
            <el-table-column prop="status" label="狀態" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="row.status === 'active' ? 'success' : 'info'" size="small">
                  {{ row.status === 'active' ? '已啟用' : '已過期' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="start_at" label="開始時間" width="180" />
            <el-table-column prop="end_at" label="到期時間" width="180" />
            <el-table-column prop="created_at" label="購買時間" width="180" />
          </el-table>
        </el-tab-pane>

        <el-tab-pane label="設備記錄" name="devices">
          <el-table :data="devices" stripe>
            <el-table-column prop="device_id" label="設備 ID" width="200" />
            <el-table-column prop="platform" label="平台" width="100" />
            <el-table-column prop="browser" label="瀏覽器" width="150" />
            <el-table-column prop="last_active_at" label="最後活躍" width="180" />
            <el-table-column prop="status" label="狀態" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="row.status === 'active' ? 'success' : 'info'" size="small">
                  {{ row.status === 'active' ? '活躍' : '閒置' }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

const route = useRoute()
const router = useRouter()
const customerId = route.params.id as string

const activeTab = ref('practices')
const customer = reactive({
  id: customerId,
  email: 'user@example.com',
  name: '張小明',
  phone: '+886912345678',
  status: 'active',
  subscription_plan: 'premium',
  subscription_status: 'active',
  subscription_start_at: '2024-01-01 00:00:00',
  subscription_end_at: '2025-01-01 00:00:00',
  subscription_days_remaining: 17,
  level: 5,
  level_progress: 65,
  xp_to_next_level: 350,
  total_practices: 156,
  avg_score: 82.5,
  current_streak: 7,
  created_at: '2023-06-15 10:30:00',
  last_login_at: '2024-01-15 10:30:00',
})

const practices = ref([
  { id: 'prac-001', scenario_title: '機場入境', score: 85, created_at: '2024-01-15 09:30:00' },
  { id: 'prac-002', scenario_title: '餐廳點餐', score: 78, created_at: '2024-01-14 14:20:00' },
])

const subscriptionHistory = ref([
  { plan_name: '進階版', amount: 599, status: 'active', start_at: '2024-01-01', end_at: '2025-01-01', created_at: '2024-01-01 00:00:00' },
])

const devices = ref([
  { device_id: 'dev-001', platform: 'iOS', browser: '-', last_active_at: '2024-01-15 10:30:00', status: 'active' },
])

function getPlanTag(plan: string): string {
  const map: Record<string, string> = { free: 'info', basic: 'success', premium: 'warning', enterprise: 'danger' }
  return map[plan] || 'info'
}

function getPlanName(plan: string): string {
  const map: Record<string, string> = { free: '免費版', basic: '基礎版', premium: '進階版', enterprise: '企業版' }
  return map[plan] || plan
}

function getLevelName(level: number): string {
  if (level <= 2) return '初學者'
  if (level <= 5) return '基礎'
  if (level <= 8) return '進階'
  return '精通'
}

function getScoreTag(score: number): string {
  if (score >= 80) return 'success'
  if (score >= 60) return 'warning'
  return 'danger'
}

function banCustomer() {
  ElMessageBox.confirm('確定要封禁此客戶嗎？', '確認封禁', { type: 'warning' })
    .then(() => { ElMessage.success('已封禁客戶') })
}

function unbanCustomer() {
  ElMessage.success('已解除封禁')
}

function resetPassword() {
  ElMessage.info('密碼重置郵件已發送')
}

function extendSubscription() {
  ElMessage.info('延長訂閱功能開發中')
}

function viewDevices() {
  activeTab.value = 'devices'
}

onMounted(() => {
  // TODO: Fetch customer data
})
</script>

<style scoped>
.customer-detail { padding: 20px; }
.page-header { margin-bottom: 20px; }
.detail-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}
.level-section { text-align: center; }
.level-badge { margin-bottom: 16px; }
.level-number { font-size: 36px; font-weight: 700; color: #e6a23c; }
.level-name { display: block; color: #909399; font-size: 14px; }
.level-hint { font-size: 12px; color: #909399; margin-top: 8px; }
.stats-row { display: flex; justify-content: space-around; }
.stat-item { text-align: center; }
.stat-value { font-size: 24px; font-weight: 600; color: #303133; }
.stat-label { font-size: 12px; color: #909399; }
.actions-section { display: flex; flex-wrap: wrap; gap: 10px; }
.tabs-card { margin-bottom: 20px; }
</style>
