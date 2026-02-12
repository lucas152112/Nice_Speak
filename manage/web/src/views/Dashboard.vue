<template>
  <div class="dashboard">
    <aside class="sidebar">
      <div class="logo">
        <h1>管理平台</h1>
      </div>
      <nav class="menu">
        <router-link to="/dashboard" class="menu-item">
          <i class="icon-dashboard"></i> 儀表板
        </router-link>
        <router-link to="/microservices" class="menu-item">
          <i class="icon-services"></i> 微服務
        </router-link>
        <router-link to="/users" class="menu-item">
          <i class="icon-users"></i> 用戶管理
        </router-link>
        <router-link to="/roles" class="menu-item">
          <i class="icon-roles"></i> 角色管理
        </router-link>
        <router-link to="/permissions" class="menu-item">
          <i class="icon-permissions"></i> 權限管理
        </router-link>
        <router-link to="/menus" class="menu-item">
          <i class="icon-menus"></i> 選單管理
        </router-link>
        <router-link to="/logs" class="menu-item">
          <i class="icon-logs"></i> 系統日誌
        </router-link>
      </nav>
    </aside>
    
    <main class="main-content">
      <header class="topbar">
        <div class="breadcrumb">首頁 / 微服務管理</div>
        <div class="user-info">
          <span>管理員</span>
          <img src="@/assets/avatar.png" alt="Avatar" />
        </div>
      </header>
      
      <div class="content">
        <router-view />
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
</script>

<style scoped>
.dashboard {
  display: flex;
  min-height: 100vh;
}

.sidebar {
  width: 240px;
  background: linear-gradient(180deg, #1a237e 0%, #283593 100%);
  color: white;
  padding: 20px 0;
}

.logo {
  padding: 0 20px 30px;
  border-bottom: 1px solid rgba(255,255,255,0.1);
  margin-bottom: 20px;
}

.logo h1 {
  font-size: 20px;
  font-weight: 600;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 14px 20px;
  color: rgba(255,255,255,0.7);
  text-decoration: none;
  transition: all 0.2s;
}

.menu-item:hover,
.menu-item.router-link-active {
  background: rgba(255,255,255,0.1);
  color: white;
  border-left: 3px solid #64B5F6;
}

.menu-item i {
  margin-right: 12px;
  width: 20px;
}

.main-content {
  flex: 1;
  background: #f5f5f5;
}

.topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  background: white;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.breadcrumb {
  color: #666;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-info img {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #e0e0e0;
}

.content {
  padding: 24px;
}
</style>
