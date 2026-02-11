<template>
  <div class="menu-management">
    <div class="page-header">
      <h1>菜單管理</h1>
      <el-button type="primary" @click="showCreateDialog = true">
        新增菜單
      </el-button>
    </div>

    <!-- 樹狀菜單 -->
    <div class="menu-tree-container">
      <el-tree
        :data="menuTree"
        :props="treeProps"
        node-key="id"
        default-expand-all
        expand-on-click-node
        v-loading="loading"
      >
        <template #default="{ node, data }">
          <div class="menu-tree-node">
            <el-icon v-if="data.icon" class="menu-icon">
              <component :is="getIconComponent(data.icon)" />
            </el-icon>
            <span class="menu-name">{{ data.name }}</span>
            <el-tag 
              v-if="!data.status" 
              type="info" 
              size="small"
              class="status-tag"
            >
              停用
            </el-tag>
            <div class="menu-actions">
              <el-button 
                type="primary" 
                link 
                size="small" 
                @click="viewMenu(data)"
              >
                詳情
              </el-button>
              <el-button 
                type="primary" 
                link 
                size="small" 
                @click="addChild(data)"
                :disabled="data.children?.length > 0"
              >
                子菜單
              </el-button>
              <el-button 
                type="primary" 
                link 
                size="small" 
                @click="editMenu(data)"
              >
                編輯
              </el-button>
              <el-button 
                type="danger" 
                link 
                size="small" 
                @click="deleteMenu(data)"
                :disabled="!!data.children?.length"
              >
                刪除
              </el-button>
            </div>
          </div>
        </template>
      </el-tree>
    </div>

    <!-- 新增/編輯菜單 Dialog -->
    <el-dialog
      v-model="showCreateDialog"
      :title="isEditing ? '編輯菜單' : (isChild ? '新增子菜單' : '新增菜單')"
      width="500px"
      @close="closeDialog"
    >
      <el-form :model="menuForm" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item label="菜單名稱" prop="name">
          <el-input v-model="menuForm.name" placeholder="如: 客戶管理" />
        </el-form-item>
        <el-form-item label="菜單路徑" prop="path">
          <el-input v-model="menuForm.path" placeholder="如: /customers" />
        </el-form-item>
        <el-form-item label="菜單圖標">
          <el-input v-model="menuForm.icon" placeholder="如: UserOutlined" />
        </el-form-item>
        <el-form-item label="排序" prop="order">
          <el-input-number v-model="menuForm.order" :min="0" />
        </el-form-item>
        <el-form-item label="父級菜單" v-if="!isEditing">
          <el-tree-select
            v-model="menuForm.parent_id"
            :data="parentMenuOptions"
            :props="{ label: 'name', value: 'id' }"
            placeholder="選擇父級菜單 (留空為頂級)"
            clearable
            check-strictly
          />
        </el-form-item>
        <el-form-item label="狀態">
          <el-switch v-model="menuForm.status" active-text="啟用" inactive-text="停用" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="closeDialog">取消</el-button>
        <el-button type="primary" @click="submitMenu" :loading="submitLoading">
          確定
        </el-button>
      </template>
    </el-dialog>

    <!-- 菜單詳情 Dialog -->
    <el-dialog v-model="showDetailDialog" title="菜單詳情" width="400px">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="菜單名稱">{{ currentMenu?.name }}</el-descriptions-item>
        <el-descriptions-item label="菜單路徑">{{ currentMenu?.path || '-' }}</el-descriptions-item>
        <el-descriptions-item label="圖標">{{ currentMenu?.icon || '-' }}</el-descriptions-item>
        <el-descriptions-item label="排序">{{ currentMenu?.order }}</el-descriptions-item>
        <el-descriptions-item label="狀態">
          <el-tag :type="currentMenu?.status ? 'success' : 'danger'">
            {{ currentMenu?.status ? '啟用' : '停用' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="父級">
          {{ getParentName(currentMenu?.parent_id) || '-' }}
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import type { MenuNode, MenuItem } from '~/types/auth'
import { getMenusTree, getMenus, createMenu, updateMenu, deleteMenu } from '~/services/menu'
import { ElMessage, ElMessageBox } from 'element-plus'

// 狀態
const loading = ref(false)
const submitLoading = ref(false)
const showCreateDialog = ref(false)
const showDetailDialog = ref(false)
const isEditing = ref(false)
const isChild = ref(false)
const menuTree = ref<MenuNode[]>([])
const menuList = ref<MenuItem[]>([])
const currentMenu = ref<MenuNode | null>(null)

// 表單
const formRef = ref()
const menuForm = reactive({
  id: '',
  name: '',
  path: '',
  icon: '',
  parent_id: null as string | null,
  order: 0,
  status: true,
})

// Tree props
const treeProps = {
  label: 'name',
  children: 'children',
}

// 表單驗證規則
const formRules = {
  name: [
    { required: true, message: '請輸入菜單名稱', trigger: 'blur' },
  ],
  order: [
    { required: true, message: '請輸入排序', trigger: 'blur' },
  ],
}

// 父級菜單選項 (扁平化)
const parentMenuOptions = computed(() => {
  const options: any[] = []
  function flatten(menus: MenuNode[]) {
    for (const menu of menus) {
      options.push({ id: menu.id, name: menu.name })
      if (menu.children) {
        flatten(menu.children)
      }
    }
  }
  flatten(menuTree.value)
  return options
})

// 取得樹狀菜單
async function fetchMenusTree() {
  loading.value = true
  try {
    const { menus } = await getMenusTree()
    menuTree.value = menus
  } catch (error: any) {
    ElMessage.error(error.message || '取得菜單列表失敗')
  } finally {
    loading.value = false
  }
}

// 取得菜單列表 (扁平)
async function fetchMenus() {
  try {
    const { menus } = await getMenus()
    menuList.value = menus
  } catch (error: any) {
    console.error('取得菜單列表失敗:', error)
  }
}

// 取得父級名稱
function getParentName(parentId: string | null | undefined): string {
  if (!parentId) return ''
  const parent = menuList.value.find((m: any) => m.id === parentId)
  return parent?.name || ''
}

// 查看菜單詳情
function viewMenu(data: MenuNode) {
  currentMenu.value = data
  showDetailDialog.value = true
}

// 新增子菜單
function addChild(data: MenuNode) {
  isChild.value = true
  isEditing.value = false
  Object.assign(menuForm, {
    id: '',
    name: '',
    path: '',
    icon: '',
    parent_id: data.id,
    order: 0,
    status: true,
  })
  showCreateDialog.value = true
}

// 編輯菜單
function editMenu(data: MenuNode) {
  isEditing.value = true
  isChild.value = false
  Object.assign(menuForm, {
    id: data.id,
    name: data.name,
    path: data.path || '',
    icon: data.icon || '',
    parent_id: data.parent_id || null,
    order: data.order,
    status: data.status,
  })
  showCreateDialog.value = true
}

// 提交菜單
async function submitMenu() {
  try {
    await formRef.value.validate()
    submitLoading.value = true
    
    if (isEditing.value) {
      await updateMenu(menuForm.id, {
        name: menuForm.name,
        path: menuForm.path,
        icon: menuForm.icon,
        parent_id: menuForm.parent_id,
        order: menuForm.order,
      })
      ElMessage.success('菜單更新成功')
    } else {
      await createMenu({
        name: menuForm.name,
        path: menuForm.path,
        icon: menuForm.icon,
        parent_id: menuForm.parent_id || undefined,
        order: menuForm.order,
      })
      ElMessage.success('菜單建立成功')
    }
    
    closeDialog()
    fetchMenusTree()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '操作失敗')
    }
  } finally {
    submitLoading.value = false
  }
}

// 刪除菜單
async function deleteMenu(data: MenuNode) {
  try {
    await ElMessageBox.confirm(
      `確定要刪除菜單「${data.name}」嗎？`,
      '確認刪除',
      { type: 'warning' }
    )
    
    await deleteMenu(data.id)
    ElMessage.success('菜單刪除成功')
    fetchMenusTree()
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
  isChild.value = false
  Object.assign(menuForm, {
    id: '',
    name: '',
    path: '',
    icon: '',
    parent_id: null,
    order: 0,
    status: true,
  })
}

// 圖標組件映射 (Element Plus 圖標)
function getIconComponent(iconName: string | undefined): string {
  if (!iconName) return 'Menu'
  // 移除 Outlined 後綴
  const name = iconName.replace('Outlined', '')
  return name.charAt(0).toUpperCase() + name.slice(1)
}

// 初始化
onMounted(() => {
  fetchMenusTree()
  fetchMenus()
})
</script>

<style scoped>
.menu-management {
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

.menu-tree-container {
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  padding: 10px;
  min-height: 400px;
}

.menu-tree-node {
  display: flex;
  align-items: center;
  flex: 1;
  padding: 8px 0;
}

.menu-icon {
  margin-right: 8px;
  font-size: 18px;
  color: #409eff;
}

.menu-name {
  font-weight: 500;
  margin-right: 10px;
}

.status-tag {
  margin-right: 10px;
}

.menu-actions {
  margin-left: auto;
}

.el-descriptions {
  margin-bottom: 20px;
}
</style>
