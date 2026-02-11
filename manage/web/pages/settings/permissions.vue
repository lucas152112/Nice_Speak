<template>
  <div class="permission-management">
    <div class="page-header">
      <h1>權限管理</h1>
    </div>

    <!-- 分組顯示 -->
    <div class="permission-groups" v-loading="loading">
      <el-collapse v-model="activeGroups">
        <el-collapse-item
          v-for="group in permissionGroups"
          :key="group.module"
          :title="group.display_name"
          :name="group.module"
        >
          <el-table :data="group.permissions" stripe size="small">
            <el-table-column prop="code" label="權限代碼" width="200">
              <template #default="{ row }">
                <code>{{ row.code }}</code>
              </template>
            </el-table-column>
            <el-table-column prop="name" label="權限名稱" width="150" />
            <el-table-column prop="type" label="類型" width="100">
              <template #default="{ row }">
                <el-tag size="small" :type="getTypeTag(row.type)">
                  {{ getTypeName(row.type) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="description" label="說明" min-width="200" />
            <el-table-column prop="status" label="狀態" width="80" align="center">
              <template #default="{ row }">
                <el-tag :type="row.status ? 'success' : 'danger'" size="small">
                  {{ row.status ? '啟用' : '停用' }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-collapse-item>
      </el-collapse>
    </div>

    <!-- 權限統計 -->
    <div class="permission-stats">
      <el-card shadow="never">
        <el-statistic title="總權限數" :value="totalPermissions" />
      </el-card>
      <el-card shadow="never" v-for="stat in typeStats" :key="stat.type">
        <el-statistic :title="stat.name" :value="stat.count" />
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import type { PermissionGroup } from '~/types/auth'
import { getPermissionsGrouped } from '~/services/permission'

const loading = ref(false)
const permissionGroups = ref<PermissionGroup[]>([])
const activeGroups = ref<string[]>([])

// 總權限數
const totalPermissions = computed(() => {
  return permissionGroups.value.reduce((sum, group) => sum + group.permissions.length, 0)
})

// 類型統計
const typeStats = computed(() => [
  { type: 'read', name: '讀取', count: countByType('read') },
  { type: 'write', name: '寫入', count: countByType('write') },
  { type: 'delete', name: '刪除', count: countByType('delete') },
  { type: 'action', name: '操作', count: countByType('action') },
])

function countByType(type: string): number {
  return permissionGroups.value.reduce(
    (sum, group) => sum + group.permissions.filter((p) => p.type === type).length,
    0
  )
}

// 取得分組權限
async function fetchPermissions() {
  loading.value = true
  try {
    const { groups } = await getPermissionsGrouped()
    permissionGroups.value = groups
    // 展開所有分組
    activeGroups.value = groups.map((g) => g.module)
  } catch (error: any) {
    console.error('取得權限列表失敗:', error)
  } finally {
    loading.value = false
  }
}

// 類型標籤
function getTypeTag(type: string): string {
  const map: Record<string, string> = {
    read: 'success',
    write: 'warning',
    delete: 'danger',
    action: 'info',
  }
  return map[type] || 'info'
}

// 類型名稱
function getTypeName(type: string): string {
  const map: Record<string, string> = {
    read: '讀取',
    write: '寫入',
    delete: '刪除',
    action: '操作',
  }
  return map[type] || type
}

// 初始化
onMounted(() => {
  fetchPermissions()
})
</script>

<style scoped>
.permission-management {
  padding: 20px;
}

.page-header {
  margin-bottom: 20px;
}

.page-header h1 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
}

.permission-groups {
  margin-bottom: 20px;
}

.permission-stats {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
}

.permission-stats .el-card {
  width: 150px;
}

code {
  background: #f5f7fa;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 12px;
  color: #409eff;
}
</style>
