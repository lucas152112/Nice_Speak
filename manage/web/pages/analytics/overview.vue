<template>
  <div class="analytics-overview">
    <div class="page-header">
      <h1>數據總覽</h1>
      <div class="date-range">
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="開始日期"
          end-placeholder="結束日期"
          @change="fetchAnalytics"
        />
      </div>
    </div>

    <!-- 統計卡片 -->
    <div class="stats-grid">
      <el-card shadow="hover">
        <template #header>總用戶數</template>
        <div class="stat-value">{{ stats.total_users }}</div>
        <div class="stat-change up">
          <el-icon><ArrowUp /></el-icon> 12.5%
        </div>
      </el-card>
      <el-card shadow="hover">
        <template #header>日活躍用戶</template>
        <div class="stat-value">{{ stats.dau }}</div>
        <div class="stat-change up">
          <el-icon><ArrowUp /></el-icon> 8.3%
        </div>
      </el-card>
      <el-card shadow="hover">
        <template #header>月活躍用戶</template>
        <div class="stat-value">{{ stats.mau }}</div>
        <div class="stat-change up">
          <el-icon><ArrowUp /></el-icon> 5.2%
        </div>
      </el-card>
      <el-card shadow="hover">
        <template #header>本月收入</template>
        <div class="stat-value">${{ stats.revenue }}</div>
        <div class="stat-change up">
          <el-icon><ArrowUp /></el-icon> 15.8%
        </div>
      </el-card>
    </div>

    <!-- 圖表區域 -->
    <div class="charts-grid">
      <el-card shadow="never">
        <template #header>用戶增長趨勢</template>
        <div class="chart-placeholder">
          [用戶增長趨勢圖表]
        </div>
      </el-card>
      <el-card shadow="never">
        <template #header>收入趨勢</template>
        <div class="chart-placeholder">
          [收入趨勢圖表]
        </div>
      </el-card>
    </div>

    <!-- 訂閱分布 -->
    <div class="charts-grid">
      <el-card shadow="never">
        <template #header>訂閱方案分布</template>
        <div class="chart-placeholder">
          [圓餅圖 - 訂閱分布]
        </div>
      </el-card>
      <el-card shadow="never">
        <template #header>練習完成率</template>
        <div class="chart-placeholder">
          [練習完成率圖表]
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'

const dateRange = ref<[Date, Date] | null>(null)
const stats = reactive({
  total_users: '12,345',
  dau: '3,456',
  mau: '8,234',
  revenue: '125,678',
})

function fetchAnalytics() {
  // TODO: API call
  console.log('Fetch analytics:', dateRange.value)
}

onMounted(() => {
  fetchAnalytics()
})
</script>

<style scoped>
.analytics-overview { padding: 20px; }
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}
.page-header h1 { margin: 0; font-size: 24px; font-weight: 600; }

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.stat-value {
  font-size: 32px;
  font-weight: 600;
  color: #303133;
}

.stat-change {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 14px;
  margin-top: 8px;
}
.stat-change.up { color: #67c23a; }
.stat-change.down { color: #f56c6c; }

.charts-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.chart-placeholder {
  height: 300px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f7fa;
  border-radius: 4px;
  color: #909399;
}
</style>
