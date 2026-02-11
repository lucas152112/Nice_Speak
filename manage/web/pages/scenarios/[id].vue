<template>
  <div class="scenario-detail">
    <div class="page-header">
      <el-page-header @back="router.back()">
        <template #content>
          <span class="page-title">{{ scenario.title }}</span>
        </template>
        <template #extra>
          <el-button @click="router.push(`/scenarios/${scenario.id}/edit`)">編輯</el-button>
          <el-button 
            v-if="scenario.status === 'draft'"
            type="primary" 
            @click="publish"
          >
            發布
          </el-button>
        </template>
      </el-page-header>
    </div>

    <div class="detail-grid">
      <!-- 基本資訊 -->
      <el-card shadow="never">
        <template #header>基本資訊</template>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="情境名稱">{{ scenario.title }}</el-descriptions-item>
          <el-descriptions-item label="分類">
            <el-tag>{{ getCategoryName(scenario.category) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="難度">
            <el-tag :type="getLevelTag(scenario.level)">
              {{ getLevelName(scenario.level) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="狀態">
            <el-tag :type="getStatusTag(scenario.status)">
              {{ getStatusName(scenario.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="建立時間">{{ scenario.created_at }}</el-descriptions-item>
          <el-descriptions-item label="更新時間">{{ scenario.updated_at }}</el-descriptions-item>
          <el-descriptions-item label="練習次數">{{ scenario.practice_count }}</el-descriptions-item>
          <el-descriptions-item label="完成率">{{ scenario.completion_rate }}%</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <!-- 統計 -->
      <el-card shadow="never">
        <template #header>練習統計</template>
        <div class="stats-grid">
          <div class="stat-item">
            <div class="stat-value">{{ scenario.avg_score }}</div>
            <div class="stat-label">平均分數</div>
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ scenario.practice_count }}</div>
            <div class="stat-label">練習次數</div>
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ scenario.favorite_count }}</div>
            <div class="stat-label">收藏次數</div>
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ scenario.completion_rate }}%</div>
            <div class="stat-label">完成率</div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 對話內容 -->
    <el-card shadow="never" class="dialogues-card">
      <template #header>對話內容</template>
      <div v-for="(dialogue, index) in scenario.dialogues" :key="index" class="dialogue-section">
        <div class="dialogue-header">
          <h4>對話 {{ index + 1 }}</h4>
          <div class="roles">
            <el-tag size="small">{{ getRoleName(dialogue.role_a) }}</el-tag>
            <span> ↔ </span>
            <el-tag size="small">{{ getRoleName(dialogue.role_b) }}</el-tag>
          </div>
        </div>
        <div class="dialogue-lines">
          <div v-for="(line, lineIdx) in dialogue.lines" :key="lineIdx" class="line-item">
            <el-tag 
              :type="line.speaker === 'A' ? 'primary' : 'success'" 
              size="small"
            >
              {{ line.speaker === 'A' ? getRoleName(dialogue.role_a) : getRoleName(dialogue.role_b) }}
            </el-tag>
            <p class="line-text">{{ line.text }}</p>
          </div>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const scenario = reactive({
  id: route.params.id,
  title: '機場入境',
  description: '練習在機場入境時的對話情境',
  category: 'travel',
  level: 'beginner',
  status: 'published',
  practice_count: 1234,
  completion_rate: 78,
  avg_score: 82.5,
  favorite_count: 567,
  created_at: '2024-01-10 10:00:00',
  updated_at: '2024-01-12 14:30:00',
  dialogues: [
    {
      role_a: '海關人員',
      role_b: '旅客',
      lines: [
        { speaker: 'A', text: '您的護照，請給我。' },
        { speaker: 'B', text: '好的，這是我的護照。' },
        { speaker: 'A', text: '謝謝。您來台灣的目的是什麼？' },
        { speaker: 'B', text: '我來旅遊。' },
        { speaker: 'A', text: '您預計停留多久？' },
        { speaker: 'B', text: '兩個星期。' },
      ],
    },
  ],
})

function getCategoryName(cat: string): string {
  const map: Record<string, string> = { daily: '日常生活', travel: '旅遊', business: '商務', education: '教育' }
  return map[cat] || cat
}

function getLevelName(level: string): string {
  const map: Record<string, string> = { beginner: '入門', intermediate: '中級', advanced: '進階' }
  return map[level] || level
}

function getLevelTag(level: string): string {
  const map: Record<string, string> = { beginner: 'success', intermediate: 'warning', advanced: 'danger' }
  return map[level] || 'info'
}

function getStatusName(status: string): string {
  const map: Record<string, string> = { draft: '草稿', published: '已發布', archived: '已下架' }
  return map[status] || status
}

function getStatusTag(status: string): string {
  const map: Record<string, string> = { draft: 'info', published: 'success', archived: 'warning' }
  return map[status] || 'info'
}

function getRoleName(role: string): string {
  const map: Record<string, string> = { agent: '客服', customer: '顧客', banker: '銀行行員', 海關人員: '海關人員', 旅客: '旅客' }
  return map[role] || role
}

function publish() {
  console.log('Publish')
}
</script>

<style scoped>
.scenario-detail { padding: 20px; }
.page-header { margin-bottom: 20px; }
.page-title { font-size: 18px; font-weight: 600; }
.detail-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 20px; }
.stats-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; text-align: center; }
.stat-value { font-size: 24px; font-weight: 600; color: #303133; }
.stat-label { font-size: 12px; color: #909399; }
.dialogues-card { margin-bottom: 20px; }
.dialogue-section { border: 1px solid #e4e7ed; border-radius: 8px; padding: 16px; margin-bottom: 16px; }
.dialogue-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.dialogue-header h4 { margin: 0; }
.dialogue-lines { margin-left: 20px; }
.line-item { display: flex; align-items: flex-start; gap: 10px; margin-bottom: 12px; }
.line-text { margin: 0; flex: 1; }
</style>
