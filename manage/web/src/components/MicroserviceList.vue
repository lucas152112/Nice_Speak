<template>
  <div class="microservice-list">
    <!-- Header -->
    <div class="header">
      <h2>微服務管理</h2>
      <button class="btn btn-primary" @click="refreshServices">
        <i class="icon-refresh"></i> 重新整理
      </button>
    </div>
    
    <!-- Status Summary -->
    <div class="status-summary">
      <div class="status-card running">
        <span class="count">{{ store.runningServices.length }}</span>
        <span class="label">運行中</span>
      </div>
      <div class="status-card stopped">
        <span class="count">{{ store.stoppedServices.length }}</span>
        <span class="label">已停止</span>
      </div>
      <div class="status-card error">
        <span class="count">{{ store.errorServices.length }}</span>
        <span class="label">錯誤</span>
      </div>
    </div>
    
    <!-- Services Table -->
    <div class="table-container">
      <table class="services-table">
        <thead>
          <tr>
            <th>狀態</th>
            <th>服務名稱</th>
            <th>類型</th>
            <th>端口</th>
            <th>最後部署</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="service in store.microsroservices" 
            :key="service.id"
            :class="{ selected: store.selectedService?.id === service.id }"
            @click="selectService(service)"
          >
            <td>
              <span :class="['status-badge', service.status]">
                {{ statusText(service.status) }}
              </span>
            </td>
            <td>
              <div class="service-info">
                <strong>{{ service.name }}</strong>
                <small>{{ service.description }}</small>
              </div>
            </td>
            <td>{{ service.serviceType }}</td>
            <td>{{ service.port || '-' }}</td>
            <td>{{ formatDate(service.lastDeployAt) }}</td>
            <td>
              <div class="actions">
                <button 
                  v-if="service.status === 'stopped'"
                  class="btn btn-success btn-sm"
                  @click.stop="startService(service.id)"
                >
                  啟動
                </button>
                <button 
                  v-if="service.status === 'running'"
                  class="btn btn-warning btn-sm"
                  @click.stop="stopService(service.id)"
                >
                  停止
                </button>
                <button 
                  class="btn btn-secondary btn-sm"
                  @click.stop="restartService(service.id)"
                >
                  重啟
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <!-- Loading -->
    <div v-if="store.isLoading" class="loading-overlay">
      <div class="spinner"></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';
import { useMicroserviceStore } from '@/stores/microservice';
import type { Microservice } from '@/models/Microservice';

const store = useMicroserviceStore();

onMounted(() => {
  store.fetchMicroservices();
});

function refreshServices() {
  store.fetchMicroservices();
}

function selectService(service: Microservice) {
  store.selectService(service);
}

async function startService(id: string) {
  await store.startService(id);
}

async function stopService(id: string) {
  await store.stopService(id);
}

async function restartService(id: string) {
  await store.restartService(id);
}

function statusText(status: string) {
  const texts: Record<string, string> = {
    running: '運行中',
    stopped: '已停止',
    error: '錯誤',
  };
  return texts[status] || status;
}

function formatDate(date: Date | null | undefined) {
  if (!date) return '-';
  return new Date(date).toLocaleDateString('zh-TW');
}
</script>

<style scoped>
.microservice-list {
  padding: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.status-summary {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
}

.status-card {
  flex: 1;
  padding: 20px;
  border-radius: 12px;
  text-align: center;
}

.status-card.running {
  background: linear-gradient(135deg, #4CAF50, #8BC34A);
  color: white;
}

.status-card.stopped {
  background: linear-gradient(135deg, #9E9E9E, #BDBDBD);
  color: white;
}

.status-card.error {
  background: linear-gradient(135deg, #F44336, #E91E63);
  color: white;
}

.status-card .count {
  display: block;
  font-size: 36px;
  font-weight: bold;
}

.status-card .label {
  font-size: 14px;
  opacity: 0.9;
}

.table-container {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}

.services-table {
  width: 100%;
  border-collapse: collapse;
}

.services-table th,
.services-table td {
  padding: 16px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.services-table th {
  background: #f8f9fa;
  font-weight: 600;
}

.services-table tr:hover {
  background: #f8f9fa;
}

.services-table tr.selected {
  background: #e3f2fd;
}

.status-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}

.status-badge.running {
  background: #e8f5e9;
  color: #2e7d32;
}

.status-badge.stopped {
  background: #f5f5f5;
  color: #616161;
}

.status-badge.error {
  background: #ffebee;
  color: #c62828;
}

.service-info strong {
  display: block;
}

.service-info small {
  color: #666;
}

.actions {
  display: flex;
  gap: 8px;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
}

.btn-primary {
  background: #2196F3;
  color: white;
}

.btn-success {
  background: #4CAF50;
  color: white;
}

.btn-warning {
  background: #FF9800;
  color: white;
}

.btn-secondary {
  background: #9E9E9E;
  color: white;
}

.btn-sm {
  padding: 6px 12px;
  font-size: 12px;
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255,255,255,0.8);
  display: flex;
  align-items: center;
  justify-content: center;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #2196F3;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>
