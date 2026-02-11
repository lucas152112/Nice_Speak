<template>
  <div class="admin-layout">
    <!-- 側邊欄 -->
    <aside class="sidebar" :collapsed="sidebarCollapsed">
      <div class="logo">
        <img src="/logo.png" alt="Logo" />
        <span v-if="!sidebarCollapsed" class="title">Nice Speak</span>
      </div>
      
      <el-menu
        :default-active="currentRoute"
        :collapse="sidebarCollapsed"
        router
        class="sidebar-menu"
      >
        <el-menu-item index="/dashboard">
          <el-icon><Odometer /></el-icon>
          <span>儀表板</span>
        </el-menu-item>
        
        <el-sub-menu index="customers">
          <template #title>
            <el-icon><User /></el-icon>
            <span>客戶管理</span>
          </template>
          <el-menu-item index="/customers">客戶列表</el-menu-item>
        </el-sub-menu>
        
        <el-sub-menu index="scenarios">
          <template #title>
            <el-icon><Document /></el-icon>
            <span>情境模板</span>
          </template>
          <el-menu-item index="/scenarios">模板列表</el-menu-item>
          <el-menu-item index="/scenarios/create">新增模板</el-menu-item>
        </el-sub-menu>
        
        <el-sub-menu index="subscriptions">
          <template #title>
            <el-icon><Money /></el-icon>
            <span>收費管理</span>
          </template>
          <el-menu-item index="/subscriptions/plans">方案管理</el-menu-item>
          <el-menu-item index="/subscriptions/orders">訂閱列表</el-menu-item>
        </el-sub-menu>
        
        <el-sub-menu index="analytics">
          <template #title>
            <el-icon><DataAnalysis /></el-icon>
            <span>數據分析</span>
          </template>
          <el-menu-item index="/analytics/overview">總覽</el-menu-item>
          <el-menu-item index="/analytics/revenue">收入報表</el-menu-item>
        </el-sub-menu>
        
        <el-sub-menu 
          v-if="hasAdminPermission" 
          index="settings"
        >
          <template #title>
            <el-icon><Setting /></el-icon>
            <span>系統設定</span>
          </template>
          <el-menu-item index="/settings/roles">角色管理</el-menu-item>
          <el-menu-item index="/settings/menus">選單管理</el-menu-item>
          <el-menu-item index="/settings/permissions">權限管理</el-menu-item>
        </el-sub-menu>
        
        <el-sub-menu v-if="hasAdminPermission" index="audit">
          <template #title>
            <el-icon><Histogram /></el-icon>
            <span>審計日誌</span>
          </template>
          <el-menu-item index="/audit/logs">操作日誌</el-menu-item>
          <el-menu-item index="/audit/login-logs">登入日誌</el-menu-item>
        </el-sub-menu>
      </el-menu>
      
      <!-- 收起按鈕 -->
      <div class="sidebar-footer">
        <el-button 
          :icon="sidebarCollapsed ? 'Expand' : 'Fold'" 
          @click="sidebarCollapsed = !sidebarCollapsed"
          text
        >
          <el-icon><component :is="sidebarCollapsed ? 'Expand' : 'Fold'" /></el-icon>
        </el-button>
      </div>
    </aside>
    
    <!-- 主內容區 -->
    <div class="main-container">
      <!-- 頂部導航 -->
      <header class="topbar">
        <div class="breadcrumb">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item>首頁</el-breadcrumb-item>
            <el-breadcrumb-item>{{ currentPageTitle }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        
        <div class="topbar-right">
          <el-dropdown trigger="click" @command="handleCommand">
            <div class="user-info">
              <el-avatar :size="32" :src="user?.avatar">
                {{ user?.name?.charAt(0) }}
              </el-avatar>
              <span class="user-name">{{ user?.name }}</span>
              <el-icon><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon>個人資料
                </el-dropdown-item>
                <el-dropdown-item command="password">
                  <el-icon><Lock /></el-icon>修改密碼
                </el-dropdown-item>
                <el-dropdown-item divided command="logout">
                  <el-icon><SwitchButton /></el-icon>登出
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>
      
      <!-- 頁面內容 -->
      <main class="content">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '~/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

// 狀態
const sidebarCollapsed = ref(false)

// 用戶資訊
const user = computed(() => authStore.user)
const hasAdminPermission = computed(() => {
  return authStore.isSuperAdmin || 
    authStore.hasPermission('manage:roles') ||
    authStore.hasPermission('manage:menus')
})

// 當前路由
const currentRoute = computed(() => route.path)

// 當前頁面標題
const currentPageTitle = computed(() => {
  const titles: Record<string, string> = {
    '/dashboard': '儀表板',
    '/customers': '客戶列表',
    '/scenarios': '模板列表',
    '/scenarios/create': '新增模板',
    '/subscriptions/plans': '方案管理',
    '/subscriptions/orders': '訂閱列表',
    '/analytics/overview': '總覽',
    '/analytics/revenue': '收入報表',
    '/settings/roles': '角色管理',
    '/settings/menus': '選單管理',
    '/settings/permissions': '權限管理',
    '/audit/logs': '操作日誌',
    '/audit/login-logs': '登入日誌',
  }
  return titles[route.path] || ''
})

// 下拉選單命令
function handleCommand(command: string) {
  switch (command) {
    case 'profile':
      router.push('/profile')
      break
    case 'password':
      router.push('/password')
      break
    case 'logout':
      authStore.logout()
      break
  }
}

// 初始化認證
onMounted(() => {
  authStore.initAuth()
})
</script>

<style scoped>
.admin-layout {
  display: flex;
  min-height: 100vh;
}

/* 側邊欄 */
.sidebar {
  width: 220px;
  background: #304156;
  display: flex;
  flex-direction: column;
  transition: width 0.3s;
}

.sidebar.collapsed {
  width: 64px;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 0 16px;
  overflow: hidden;
}

.logo img {
  width: 32px;
  height: 32px;
}

.logo .title {
  color: #fff;
  font-size: 18px;
  font-weight: 600;
  white-space: nowrap;
}

.sidebar-menu {
  flex: 1;
  border-right: none;
  background: transparent;
}

.sidebar-menu:not(.el-menu--collapse) {
  width: 220px;
}

.sidebar-menu .el-menu-item,
.sidebar-menu .el-sub-menu__title {
  color: #bfcbd9;
}

.sidebar-menu .el-menu-item:hover,
.sidebar-menu .el-sub-menu__title:hover {
  background: #263445;
}

.sidebar-menu .el-menu-item.is-active {
  background: #409eff;
  color: #fff;
}

.sidebar-footer {
  padding: 10px;
  border-top: 1px solid #1f2d3d;
  display: flex;
  justify-content: center;
}

.sidebar-footer .el-button {
  color: #bfcbd9;
}

/* 主內容區 */
.main-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #f5f7fa;
}

/* 頂部導航 */
.topbar {
  height: 60px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.breadcrumb {
  display: flex;
  align-items: center;
}

.topbar-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.user-name {
  color: #606266;
}

.content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}
</style>
