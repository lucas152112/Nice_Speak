<template>
  <div class="revenue-report">
    <div class="page-header">
      <h1>收入報表</h1>
      <div class="header-actions">
        <el-date-picker
          v-model="dateRange"
          type="monthrange"
          range-separator="至"
          start-placeholder="開始月份"
          end-placeholder="結束月份"
          @change="fetchRevenue"
        />
        <el-button @click="exportReport">匯出報表</el-button>
      </div>
    </div>

    <!-- 收入統計 -->
    <div class="stats-grid">
      <el-card shadow="hover">
        <template #header>本月收入</template>
        <div class="stat-value">${{ stats.this_month.toLocaleString() }}</div>
        <div class="stat-change up">
          <el-icon><ArrowUp /></el-icon> {{ stats.this_month_growth }}%
        </div>
      </el-card>
      <el-card shadow="hover">
        <template #header>上月收入</template>
        <div class="stat-value">${{ stats.last_month.toLocaleString() }}</div>
      </el-card>
      <el-card shadow="hover">
        <template #header>本年累計</template>
        <div class="stat-value">${{ stats.this_year.toLocaleString() }}</div>
      </el-card>
      <el-card shadow="hover">
        <template #header>總收入</template>
        <div class="stat-value">${{ stats.total.toLocaleString() }}</div>
      </el-card>
    </div>

    <!-- 收入趨勢圖 -->
    <el-card shadow="never" class="chart-card">
      <template #header>月度收入趨勢</template>
      <div class="chart-placeholder">
        [月度收入趨勢圖表]
      </div>
    </el-card>

    <!-- 方案收入分布 -->
    <div class="charts-grid">
      <el-card shadow="never">
        <template #header>方案收入分布</template>
        <div class="chart-placeholder">
          [圓餅圖 - 方案收入]
        </div>
      </el-card>
      <el-card shadow="never">
        <template #header>付款方式分布</template>
        <div class="chart-placeholder">
          [圓餅圖 - 付款方式]
        </div>
      </el-card>
    </div>

    <!-- 收入明細表 -->
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>收入明細</span>
        </div>
      </template>
      <el-table :data="revenueDetails" stripe>
        <el-table-column prop="date" label="月份" width="100" />
        <el-table-column prop="basic_count" label="基礎版訂閱" width="120" align="right">
          <template #default="{ row }">
            ${{ row.basic_amount.toLocaleString() }} ({{ row.basic_count }})
          </template>
        </el-table-column>
        <el-table-column prop="premium_count" label="進階版訂閱" width="120" align="right">
          <template #default="{ row }">
            ${{ row.premium_amount.toLocaleString() }} ({{ row.premium_count }})
          </template>
        </el-table-column>
        <el-table-column prop="enterprise_count" label="企業版訂閱" width="120" align="right">
          <template #default="{ row }">
            ${{ row.enterprise_amount.toLocaleString() }} ({{ row.enterprise_count }})
          </template>
        </el-table-column>
        <el-table-column prop="refund_amount" label="退款金額" width="100" align="right">
          <template #default="{ row }">
            <span class="refund">-${{ row.refund_amount.toLocaleString() }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="total" label="淨收入" width="120" align="right">
          <template #default="{ row }">
            <strong>${{ row.net_amount.toLocaleString() }}</strong>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'

const dateRange = ref<[Date, Date] | null>(null)
const stats = reactive({
  this_month: 125678,
  this_month_growth: 15.8,
  last_month: 108456,
  this_year: 987654,
  total: 2345678,
})

const revenueDetails = ref([
  { date: '2024-01', basic_count: 45, basic_amount: 13455, premium_count: 120, premium_amount: 71880, enterprise_count: 5, enterprise_amount: 14950, refund_amount: 299, net_amount: 89986 },
  { date: '2023-12', basic_count: 42, basic_amount: 12558, premium_count: 115, premium_amount: 68885, enterprise_count: 4, enterprise_amount: 11960, refund_amount: 0, net_amount: 93403 },
  { date: '2023-11', basic_count: 40, basic_amount: 11960, premium_count: 108, premium_amount: 64692, enterprise_count: 4, enterprise_amount: 11960, refund_amount: 599, net_amount: 88013 },
])

function fetchRevenue() {
  console.log('Fetch revenue:', dateRange.value)
}

function exportReport() {
  console.log('Export report')
}
</script>

<style scoped>
.revenue-report { padding: 20px; }
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}
.page-header h1 { margin: 0; font-size: 24px; font-weight: 600; }
.header-actions { display: flex; gap: 10px; }

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}
.stat-value {
  font-size: 28px;
  font-weight: 600;
  color: #303133;
}
.stat-change {
  font-size: 14px;
  margin-top: 8px;
}
.stat-change.up { color: #67c23a; }
.stat-change.down { color: #f56c6c; }

.chart-card { margin-bottom: 20px; }
.chart-placeholder {
  height: 300px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f7fa;
  border-radius: 4px;
  color: #909399;
}

.charts-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.card-header { display: flex; justify-content: space-between; align-items: center; }
.refund { color: #f56c6c; }
</style>
