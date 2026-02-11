<template>
  <div class="dashboard">
    <div class="stats-grid">
      <el-card shadow="hover" v-for="stat in stats" :key="stat.label">
        <div class="stat-content">
          <div class="stat-icon" :style="{ background: stat.color }">
            <el-icon><component :is="stat.icon" /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stat.value }}</div>
            <div class="stat-label">{{ stat.label }}</div>
          </div>
        </div>
      </el-card>
    </div>

    <div class="dashboard-grid">
      <!-- 最近活動 -->
      <el-card shadow="never">
        <template #header>
          <div class="card-header">
            <span>最近活動</span>
            <el-button type="primary" link>查看更多</el-button>
          </div>
        </template>
        <el-timeline>
          <el-timeline-item
            v-for="activity in recentActivities"
            :key="activity.id"
            :timestamp="activity.time"
            placement="top"
          >
            <p>{{ activity.content }}</p>
          </el-timeline-item>
        </el-timeline>
      </el-card>

      <!-- 快速操作 -->
      <el-card shadow="never">
        <template #header>
          <span>快速操作</span>
        </template>
        <div class="quick-actions">
          <el-button 
            v-for="action in quickActions" 
            :key="action.label"
            :type="action.type"
            @click="handleAction(action)"
          >
            <el-icon><component :is="action.icon" /></el-icon>
            {{ action.label }}
          </el-button>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const stats = ref([
  { label: '總用戶數', value: '1,234', icon: 'User', color: '#409eff' },
  { label: '今日活躍', value: '567', icon: 'TrendCharts', color: '#67c23a' },
  { label: '訂閱用戶', value: '890', icon: 'Medal', color: '#e6a23c' },
  { label: '本月收入', value: '$12,345', icon: 'Money', color: '#f56c6c' },
])

const recentActivities = ref([
  { id: 1, content: '新用戶註冊: user@example.com', time: '10分鐘前' },
  { id: 2, content: '用戶升級訂閱: 基礎版 → 進階版', time: '30分鐘前' },
  { id: 3, content: '新情境模板已發布: 機場入境', time: '1小時前' },
  { id: 4, content: '系統完成每日備份', time: '2小時前' },
])

const quickActions = [
  { label: '新增用戶', icon: 'Plus', type: 'primary', route: '/users/create' },
  { label: '新增情境', icon: 'Document', type: 'success', route: '/scenarios/create' },
  { label: '發布公告', icon: 'Bell', type: 'warning', route: '/announcements/create' },
  { label: '系統設定', icon: 'Setting', type: 'info', route: '/settings' },
])

function handleAction(action: any) {
  router.push(action.route)
}
</script>

<style scoped>
.dashboard {
  padding: 0;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 24px;
}

.stat-value {
  font-size: 28px;
  font-weight: 600;
  color: #303133;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.quick-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.quick-actions .el-button {
  width: 100%;
}
</style>
