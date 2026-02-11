<template>
  <div class="role-management">
    <div class="page-header">
      <h1>角色管理</h1>
      <el-button type="primary" @click="showCreateDialog = true">
        新增角色
      </el-button>
    </div>

    <!-- 搜尋列 -->
    <div class="search-bar">
      <el-input
        v-model="searchKeyword"
        placeholder="搜尋角色名稱或代碼"
        clearable
        style="width: 300px"
        @clear="fetchRoles"
        @keyup.enter="fetchRoles"
      />
      <el-button type="primary" @click="fetchRoles">搜尋</el-button>
    </div>

    <!-- 角色列表 -->
    <el-table :data="roles" v-loading="loading" stripe>
      <el-table-column prop="code" label="角色代碼" width="150" />
      <el-table-column prop="name" label="角色名稱" width="150" />
      <el-table-column prop="description" label="說明" min-width="200" />
      <el-table-column prop="level" label="等級" width="80" align="center">
        <template #default="{ row }">
          <el-tag size="small">{{ row.level }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="is_system" label="系統角色" width="100" align="center">
        <template #default="{ row }">
          <el-tag v-if="row.is_system" type="warning" size="small">是</el-tag>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="狀態" width="80" align="center">
        <template #default="{ row }">
          <el-tag :type="row.status ? 'success' : 'danger'" size="small">
            {{ row.status ? '啟用' : '停用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200" align="center" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="viewRole(row)">
            詳情
          </el-button>
          <el-button 
            type="primary" 
            link 
            size="small" 
            @click="editRole(row)"
            :disabled="row.is_system"
          >
            編輯
          </el-button>
          <el-button 
            type="danger" 
            link 
            size="small" 
            @click="deleteRole(row)"
            :disabled="row.is_system"
          >
            刪除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分頁 -->
    <div class="pagination">
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.limit"
        :page-sizes="[10, 20, 50, 100]"
        :total="pagination.total"
        layout="total, sizes, prev, pager, next"
        @size-change="fetchRoles"
        @current-change="fetchRoles"
      />
    </div>

    <!-- 新增/編輯角色 Dialog -->
    <el-dialog
      v-model="showCreateDialog"
      :title="isEditing ? '編輯角色' : '新增角色'"
      width="600px"
      @close="closeDialog"
    >
      <el-form :model="roleForm" :rules="formRules" ref="formRef" label-width="120px">
        <el-form-item label="角色代碼" prop="code" v-if="!isEditing">
          <el-input v-model="roleForm.code" placeholder="如: super_admin" />
        </el-form-item>
        <el-form-item label="角色名稱" prop="name">
          <el-input v-model="roleForm.name" placeholder="如: 超級管理員" />
        </el-form-item>
        <el-form-item label="說明">
          <el-input v-model="roleForm.description" type="textarea" rows="2" />
        </el-form-item>
        <el-form-item label="權限等級" prop="level">
          <el-input-number v-model="roleForm.level" :min="1" :max="100" />
        </el-form-item>
        <el-form-item label="權限配置">
          <div class="permission-select">
            <div
              v-for="group in permissionGroups"
              :key="group.module"
              class="permission-group"
            >
              <div class="group-title">{{ group.display_name }}</div>
              <el-checkbox-group v-model="selectedPermissions">
                <el-checkbox
                  v-for="perm in group.permissions"
                  :key="perm.id"
                  :label="perm.id"
                  :value="perm.id"
                >
                  {{ perm.name }}
                </el-checkbox>
              </el-checkbox-group>
            </div>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="closeDialog">取消</el-button>
        <el-button type="primary" @click="submitRole" :loading="submitLoading">
          確定
        </el-button>
      </template>
    </el-dialog>

    <!-- 角色詳情 Dialog -->
    <el-dialog v-model="showDetailDialog" title="角色詳情" width="500px">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="角色代碼">{{ currentRole?.code }}</el-descriptions-item>
        <el-descriptions-item label="角色名稱">{{ currentRole?.name }}</el-descriptions-item>
        <el-descriptions-item label="說明">{{ currentRole?.description || '-' }}</el-descriptions-item>
        <el-descriptions-item label="權限等級">
          <el-tag>{{ currentRole?.level }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="系統角色">
          <el-tag :type="currentRole?.is_system ? 'warning' : 'info'">
            {{ currentRole?.is_system ? '是' : '否' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="狀態">
          <el-tag :type="currentRole?.status ? 'success' : 'danger'">
            {{ currentRole?.status ? '啟用' : '停用' }}
          </el-tag>
        </el-descriptions-item>
      </el-descriptions>
      
      <div class="role-permissions" v-if="currentRolePermissions.length">
        <h4>已配置權限</h4>
        <el-tag 
          v-for="perm in currentRolePermissions" 
          :key="perm.id"
          class="permission-tag"
        >
          {{ perm.name }}
        </el-tag>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import type { Role, PermissionGroup } from '~/types/auth'
import { getRoles, getRole, createRole, updateRole, deleteRole } from '~/services/role'
import { getPermissionsGrouped } from '~/services/permission'
import { ElMessage, ElMessageBox } from 'element-plus'

// 狀態
const loading = ref(false)
const submitLoading = ref(false)
const showCreateDialog = ref(false)
const showDetailDialog = ref(false)
const isEditing = ref(false)
const searchKeyword = ref('')
const roles = ref<Role[]>([])
const permissionGroups = ref<PermissionGroup[]>([])
const currentRole = ref<Role | null>(null)
const currentRolePermissions = ref<any[]>([])
const selectedPermissions = ref<string[]>([])

// 表單
const formRef = ref()
const roleForm = reactive({
  id: '',
  code: '',
  name: '',
  description: '',
  level: 1,
})

// 分頁
const pagination = reactive({
  page: 1,
  limit: 20,
  total: 0,
})

// 表單驗證規則
const formRules = {
  code: [
    { required: true, message: '請輸入角色代碼', trigger: 'blur' },
    { pattern: /^[a-z_]+$/, message: '角色代碼只能包含小寫字母和底線', trigger: 'blur' },
  ],
  name: [
    { required: true, message: '請輸入角色名稱', trigger: 'blur' },
  ],
  level: [
    { required: true, message: '請輸入權限等級', trigger: 'blur' },
  ],
}

// 取得角色列表
async function fetchRoles() {
  loading.value = true
  try {
    const { roles: data, pagination: pager } = await getRoles({
      page: pagination.page,
      limit: pagination.limit,
      keyword: searchKeyword.value,
    })
    roles.value = data
    Object.assign(pagination, pager)
  } catch (error: any) {
    ElMessage.error(error.message || '取得角色列表失敗')
  } finally {
    loading.value = false
  }
}

// 取得分組權限
async function fetchPermissions() {
  try {
    const { groups } = await getPermissionsGrouped()
    permissionGroups.value = groups
  } catch (error: any) {
    console.error('取得權限列表失敗:', error)
  }
}

// 查看角色詳情
async function viewRole(role: Role) {
  currentRole.value = role
  try {
    const detail = await getRole(role.id)
    currentRolePermissions.value = detail.permissions || []
    showDetailDialog.value = true
  } catch (error: any) {
    ElMessage.error(error.message || '取得角色詳情失敗')
  }
}

// 編輯角色
async function editRole(role: Role) {
  isEditing.value = true
  Object.assign(roleForm, {
    id: role.id,
    code: role.code,
    name: role.name,
    description: role.description || '',
    level: role.level,
  })
  
  try {
    const detail = await getRole(role.id)
    selectedPermissions.value = (detail.permissions || []).map((p: any) => p.id)
    showCreateDialog.value = true
  } catch (error: any) {
    ElMessage.error(error.message || '取得角色資料失敗')
  }
}

// 提交角色
async function submitRole() {
  try {
    await formRef.value.validate()
    submitLoading.value = true
    
    if (isEditing.value) {
      await updateRole(roleForm.id, {
        name: roleForm.name,
        description: roleForm.description,
        level: roleForm.level,
        permissions: selectedPermissions.value,
      })
      ElMessage.success('角色更新成功')
    } else {
      await createRole({
        code: roleForm.code,
        name: roleForm.name,
        description: roleForm.description,
        level: roleForm.level,
        permissions: selectedPermissions.value,
      })
      ElMessage.success('角色建立成功')
    }
    
    closeDialog()
    fetchRoles()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '操作失敗')
    }
  } finally {
    submitLoading.value = false
  }
}

// 刪除角色
async function deleteRole(role: Role) {
  try {
    await ElMessageBox.confirm(
      `確定要刪除角色「${role.name」嗎？此操作不可復原。`,
      '確認刪除',
      { type: 'warning' }
    )
    
    await deleteRole(role.id)
    ElMessage.success('角色刪除成功')
    fetchRoles()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '刪除失敗')
    }
  }
}

// 關閉 Dialog
function closeDialog() {
  showCreateDialog.value = false
  isEditing.value = false
  selectedPermissions.value = []
  Object.assign(roleForm, {
    id: '',
    code: '',
    name: '',
    description: '',
    level: 1,
  })
}

// 初始化
onMounted(() => {
  fetchRoles()
  fetchPermissions()
})
</script>

<style scoped>
.role-management {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h1 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
}

.search-bar {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.permission-select {
  max-height: 300px;
  overflow-y: auto;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  padding: 10px;
}

.permission-group {
  margin-bottom: 15px;
}

.permission-group:last-child {
  margin-bottom: 0;
}

.group-title {
  font-weight: 600;
  margin-bottom: 8px;
  padding-bottom: 5px;
  border-bottom: 1px solid #ebeef5;
}

.el-checkbox-group {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.role-permissions {
  margin-top: 20px;
}

.role-permissions h4 {
  margin-bottom: 10px;
}

.permission-tag {
  margin: 0 8px 8px 0;
}

.el-descriptions {
  margin-bottom: 20px;
}
</style>
