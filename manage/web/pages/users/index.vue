<template>
  <div class="users-management">
    <div class="page-header">
      <h1>管理員列表</h1>
      <el-button type="primary" @click="showCreateDialog = true">
        新增管理員
      </el-button>
    </div>

    <!-- 搜尋 -->
    <div class="search-bar">
      <el-input
        v-model="searchKeyword"
        placeholder="搜尋管理員"
        style="width: 300px"
        clearable
        @keyup.enter="fetchUsers"
      />
      <el-button type="primary" @click="fetchUsers">搜尋</el-button>
    </div>

    <!-- 用戶列表 -->
    <el-table :data="users" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="100" />
      <el-table-column prop="email" label="Email" min-width="200" />
      <el-table-column prop="name" label="名稱" width="150" />
      <el-table-column prop="role_name" label="角色" width="150">
        <template #default="{ row }">
          <el-tag size="small">{{ row.role_name }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="狀態" width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="row.status ? 'success' : 'danger'" size="small">
            {{ row.status ? '啟用' : '停用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="last_login_at" label="最後登入" width="180" />
      <el-table-column prop="created_at" label="建立時間" width="180" />
      <el-table-column label="操作" width="180" align="center" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="editUser(row)">
            編輯
          </el-button>
          <el-button 
            v-if="row.status"
            type="danger" 
            link 
            size="small" 
            @click="disableUser(row)"
          >
            停用
          </el-button>
          <el-button 
            v-else
            type="success" 
            link 
            size="small" 
            @click="enableUser(row)"
          >
            啟用
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
        @current-change="fetchUsers"
      />
    </div>

    <!-- 新增/編輯 Dialog -->
    <el-dialog
      v-model="showCreateDialog"
      :title="isEditing ? '編輯管理員' : '新增管理員'"
      width="500px"
    >
      <el-form :model="userForm" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item label="Email" prop="email">
          <el-input v-model="userForm.email" placeholder="admin@example.com" />
        </el-form-item>
        <el-form-item label="名稱" prop="name">
          <el-input v-model="userForm.name" placeholder="管理員名稱" />
        </el-form-item>
        <el-form-item label="角色" prop="role_id">
          <el-select v-model="userForm.role_id" placeholder="選擇角色">
            <el-option 
              v-for="role in roles" 
              :key="role.id" 
              :label="role.name" 
              :value="role.id" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="密碼" prop="password" v-if="!isEditing">
          <el-input v-model="userForm.password" type="password" show-password />
        </el-form-item>
        <el-form-item label="狀態">
          <el-switch v-model="userForm.status" active-text="啟用" inactive-text="停用" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="closeDialog">取消</el-button>
        <el-button type="primary" @click="submitUser" :loading="submitLoading">
          確定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const submitLoading = ref(false)
const showCreateDialog = ref(false)
const isEditing = ref(false)
const searchKeyword = ref('')
const users = ref<any[]>([])
const roles = ref<any[]>([])
const pagination = reactive({ page: 1, limit: 20, total: 0 })
const formRef = ref()

const userForm = reactive({
  id: '',
  email: '',
  name: '',
  role_id: '',
  password: '',
  status: true,
})

const formRules = {
  email: [
    { required: true, message: '請輸入 Email', trigger: 'blur' },
    { type: 'email', message: '請輸入有效的 Email', trigger: 'blur' }
  ],
  name: [{ required: true, message: '請輸入名稱', trigger: 'blur' }],
  role_id: [{ required: true, message: '請選擇角色', trigger: 'change' }],
  password: [
    { required: true, message: '請輸入密碼', trigger: 'blur' },
    { min: 6, message: '密碼至少6個字符', trigger: 'blur' }
  ],
}

async function fetchUsers() {
  loading.value = true
  try {
    users.value = [
      {
        id: 'admin-001',
        email: 'admin@nicespeak.app',
        name: '超級管理員',
        role_id: 'role-001',
        role_name: '超級管理員',
        status: true,
        last_login_at: '2024-01-15 10:30:00',
        created_at: '2023-06-01 00:00:00',
      },
    ]
    pagination.total = 1
    
    // Load roles
    roles.value = [
      { id: 'role-001', name: '超級管理員' },
      { id: 'role-002', name: '系統管理員' },
      { id: 'role-003', name: '客服人員' },
    ]
  } catch (error: any) {
    ElMessage.error(error.message)
  } finally {
    loading.value = false
  }
}

function editUser(user: any) {
  isEditing.value = true
  Object.assign(userForm, user)
  showCreateDialog.value = true
}

async function submitUser() {
  try {
    await formRef.value.validate()
    submitLoading.value = true
    ElMessage.success(isEditing.value ? '更新成功' : '新增成功')
    closeDialog()
    fetchUsers()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message)
    }
  } finally {
    submitLoading.value = false
  }
}

function closeDialog() {
  showCreateDialog.value = false
  isEditing.value = false
  Object.assign(userForm, {
    id: '',
    email: '',
    name: '',
    role_id: '',
    password: '',
    status: true,
  })
}

function disableUser(user: any) {
  ElMessageBox.confirm(`確定要停用管理員 ${user.name} 嗎？`, '確認', { type: 'warning' })
    .then(() => {
      ElMessage.success('已停用')
      fetchUsers()
    })
}

function enableUser(user: any) {
  ElMessage.success('已啟用')
  fetchUsers()
}

onMounted(() => {
  fetchUsers()
})
</script>

<style scoped>
.users-management { padding: 20px; }
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.page-header h1 { margin: 0; font-size: 24px; font-weight: 600; }
.search-bar { display: flex; gap: 10px; margin-bottom: 20px; }
.pagination { display: flex; justify-content: flex-end; margin-top: 20px; }
</style>
