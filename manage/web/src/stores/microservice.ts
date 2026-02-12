import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import type { Microservice } from '@/models/Microservice';

export const useMicroserviceStore = defineStore('microservice', () => {
  // State
  const microservices = ref<Microservice[]>([]);
  const selectedService = ref<Microservice | null>(null);
  const isLoading = ref(false);
  const error = ref<string | null>(null);
  
  // Getters
  const runningServices = computed(() => 
    microservices.value.filter(s => s.status === 'running')
  );
  
  const stoppedServices = computed(() => 
    microservices.value.filter(s => s.status === 'stopped')
  );
  
  const errorServices = computed(() => 
    microservices.value.filter(s => s.status === 'error')
  );
  
  // Actions
  async function fetchMicroservices() {
    isLoading.value = true;
    error.value = null;
    
    try {
      // TODO: API call
      await new Promise(resolve => setTimeout(resolve, 500));
      // Simulated response
      microservices.value = [
        {
          id: '1',
          name: 'User Service',
          description: '用戶管理服務',
          directoryPath: '/services/user-service',
          serviceType: 'api',
          port: 3001,
          status: 'running',
          autoRestart: true,
          healthCheckUrl: '/health',
          lastDeployAt: new Date('2026-02-10'),
          lastStatusChangeAt: new Date('2026-02-10'),
          createdAt: new Date('2026-01-01'),
          updatedAt: new Date('2026-02-10'),
        },
        {
          id: '2',
          name: 'Scenario Service',
          description: '情境管理服務',
          directoryPath: '/services/scenario-service',
          serviceType: 'api',
          port: 3002,
          status: 'stopped',
          autoRestart: false,
          healthCheckUrl: '/health',
          lastDeployAt: new Date('2026-02-08'),
          lastStatusChangeAt: new Date('2026-02-08'),
          createdAt: new Date('2026-01-15'),
          updatedAt: new Date('2026-02-08'),
        },
      ];
    } catch (e) {
      error.value = 'Failed to fetch microservices';
      console.error(e);
    } finally {
      isLoading.value = false;
    }
  }
  
  async function startService(id: string) {
    const service = microservices.value.find(s => s.id === id);
    if (!service) return;
    
    // TODO: API call
    service.status = 'running';
    service.lastStatusChangeAt = new Date();
  }
  
  async function stopService(id: string) {
    const service = microservices.value.find(s => s.id === id);
    if (!service) return;
    
    // TODO: API call
    service.status = 'stopped';
    service.lastStatusChangeAt = new Date();
  }
  
  async function restartService(id: string) {
    const service = microservices.value.find(s => s.id === id);
    if (!service) return;
    
    service.status = 'stopped';
    await new Promise(resolve => setTimeout(resolve, 1000));
    service.status = 'running';
    service.lastStatusChangeAt = new Date();
  }
  
  function selectService(service: Microservice | null) {
    selectedService.value = service;
  }
  
  return {
    // State
    microservices,
    selectedService,
    isLoading,
    error,
    // Getters
    runningServices,
    stoppedServices,
    errorServices,
    // Actions
    fetchMicroservices,
    startService,
    stopService,
    restartService,
    selectService,
  };
});
