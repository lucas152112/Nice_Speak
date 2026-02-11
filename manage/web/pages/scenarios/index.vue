<template>
  <div class="scenario-list">
    <div class="page-header">
      <h1>情境模板</h1>
      <el-button type="primary" @click="createScenario">
        新增模板
      </el-button>
    </div>

    <!-- 篩選器 -->
    <div class="filters">
      <el-select v-model="filters.category" placeholder="分類" clearable style="width: 150px">
        <el-option label="日常生活" value="daily" />
        <el-option label="旅遊" value="travel" />
        <el-option label="商務" value="business" />
        <el-option label="教育" value="education" />
      </el-select>
      <el-select v-model="filters.level" placeholder="難度" clearable style="width: 150px">
        <el-option label="入門" value="beginner" />
        <el-option label="中級" value="intermediate" />
        <el-option label="進階" value="advanced" />
      </el-select>
      <el-select v-model="filters.status" placeholder="狀態" clearable style="width: 150px">
        <el-option label="草稿" value="draft" />
        <el-option label="已發布" value="published" />
        <el-option label="已下架" value="archived" />
      </el-select>
      <el-input
        v-model="filters.keyword"
        placeholder="搜尋情境名稱"
        style="width: 200px"
        clearable
      />
      <el-button type="primary" @click="fetchScenarios">搜尋</el-button>
    </div>

    <!-- 情境列表 -->
    <el-table :data="scenarios" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="title" label="情境名稱" min-width="200" />
      <el-table-column prop="category" label="分類" width="120">
        <template #default="{ row }">
          <el-tag size="small">{{ getCategoryName(row.category) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="level" label="難度" width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="getLevelTag(row.level)" size="small">
            {{ getLevelName(row.level) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="dialogue_count" label="對話數" width="80" align="center" />
      <el-table-column prop="practice_count" label="練習次數" width="100" align="center" />
      <el-table-column prop="status" label="狀態" width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="getStatusTag(row.status)" size="small">
            {{ getStatusName(row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="created_at" label="建立時間" width="180" />
      <el-table-column label="操作" width="180" align="center" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="viewScenario(row)">
            詳情
          </el-button>
          <el-button type="primary" link size="small" @click="editScenario(row)">
            編輯
          </el-button>
          <el-button
            v-if="row.status === 'draft'"
            type="success"
            link
            size="small"
            @click="publishScenario(row)"
          >
            發布
          </el-button>
          <el-button
            v-if="row.status === 'published'"
            type="warning"
            link
            size="small"
            @click="archiveScenario(row)"
          >
            下架
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
        @current-change="fetchScenarios"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const scenarios = ref<any[]>([])
const pagination = reactive({ page: 1, limit: 20, total: 0 })
const filters = reactive({
  category: '',
  level: '',
  status: '',
  keyword: '',
})

async function fetchScenarios() {
  loading.value = true
  try {
    scenarios.value = [
      {
        id: 'scn-001',
        title: '機場入境',
        category: 'travel',
        level: 'beginner',
        dialogue_count: 15,
        practice_count: 1234,
        status: 'published',
        created_at: '2024-01-10 10:00:00',
      },
      {
        id: 'scn-002',
        title: '餐廳點餐',
        category: 'daily',
        level: 'intermediate',
        dialogue_count: 20,
        practice_count: 2345,
        status: 'published',
        created_at: '2024-01-08 14:00:00',
      },
      {
        id: 'scn-003',
        title: '商務會議',
        category: 'business',
        level: 'advanced',
        dialogue_count: 25,
        practice_count: 567,
        status: 'draft',
        created_at: '2024-01-15 09:00:00',
      },
    ]
    pagination.total = 3
  } catch (error: any) {
    ElMessage.error(error.message)
  } finally {
    loading.value = false
  }
}

function createScenario() {
  navigateTo('/scenarios/create')
}

function viewScenario(row: any) {
  navigateTo(`/scenarios/${row.id}`)
}

function editScenario(row: any) {
  navigateTo(`/scenarios/${row.id}/edit`)
}

function publishScenario(row: any) {
  ElMessage.success(`已發布情境: ${row.title}`)
  fetchScenarios()
}

function archiveScenario(row: any) {
  ElMessage.success(`已下架情境: ${row.title}`)
  fetchScenarios()
}

function getCategoryName(category: string): string {
  const map: Record<string, string> = {
    daily: '日常生活',
    travel: '旅遊',
    business: '商務',
    education: '教育',
  }
  return map[category] || category
}

function getLevelName(level: string): string {
  const map: Record<string, string> = {
    beginner: '入門',
    intermediate: '中級',
    advanced: '進階',
  }
  return map[level] || level
}

function getLevelTag(level: string): string {
  const map: Record<string, string> = {
    beginner: 'success',
    intermediate: 'warning',
    advanced: 'danger',
  }
  return map[level] || 'info'
}

function getStatusName(status: string): string {
  const map: Record<string, string> = {
    draft: '草稿',
    published: '已發布',
    archived: '已下架',
  }
  return map[status] || status
}

function getStatusTag(status: string): string {
  const map: Record<string, string> = {
    draft: 'info',
    published: 'success',
    archived: 'warning',
  }
  return map[status] || 'info'
}

onMounted(() => {
  fetchScenarios()
})
</script>

<style scoped>
.scenario-list { padding: 20px; }
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.page-header h1 { margin: 0; font-size: 24px; font-weight: 600; }
.filters {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}
.pagination { display: flex; justify-content: flex-end; margin-top: 20px; }
</style>
