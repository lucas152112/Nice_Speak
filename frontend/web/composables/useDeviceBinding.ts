// composables/useDeviceBinding.ts
import { ref, computed } from 'vue'

// 設備資訊類型
interface DeviceInfo {
  deviceId: string
  platform: string
  browser: string
  userAgent: string
  screenResolution: string
  language: string
  timezone: string
}

// 設備狀態類型
interface DeviceStatus {
  deviceId: string
  hasUsedFreeTrial: boolean
  isBanned: boolean
  registeredAt?: string
  lastUsedAt?: string
}

// 設備綁定結果類型
interface DeviceBindingResult {
  success: boolean
  deviceId?: string
  status?: DeviceStatus
  canUseFreeTrial?: boolean
  error?: string
}

// 設備綁定服務
export function useDeviceBinding() {
  const deviceInfo = ref<DeviceInfo | null>(null)
  const isInitialized = ref(false)
  const isLoading = ref(false)

  // 產生設備指紋
  function generateFingerprint(): string {
    const info = getBrowserInfo()
    const input = `${info.userAgent}:${info.screenResolution}:${info.language}:${info.timezone}`
    
    // 簡單的 hash 函數
    let hash = 0
    for (let i = 0; i < input.length; i++) {
      const char = input.charCodeAt(i)
      hash = ((hash << 5) - hash) + char
      hash = hash & hash
    }
    
    return Math.abs(hash).toString(16).padStart(8, '0') + 
           Date.now().toString(16).slice(-8)
  }

  // 取得瀏覽器資訊
  function getBrowserInfo(): DeviceInfo {
    const ua = navigator.userAgent
    const platform = navigator.platform
    const language = navigator.language
    const screenResolution = `${window.screen.width}x${window.screen.height}`
    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone
    
    // 偵測瀏覽器
    let browser = 'Unknown'
    if (ua.includes('Chrome')) browser = 'Chrome'
    else if (ua.includes('Firefox')) browser = 'Firefox'
    else if (ua.includes('Safari')) browser = 'Safari'
    else if (ua.includes('Edge')) browser = 'Edge'
    
    return {
      deviceId: generateFingerprint(),
      platform,
      browser,
      userAgent: ua,
      screenResolution,
      language,
      timezone
    }
  }

  // 初始化設備綁定
  async function initialize(): Promise<DeviceBindingResult> {
    if (isLoading.value || isInitialized.value) {
      return {
        success: true,
        deviceId: deviceInfo.value?.deviceId,
        canUseFreeTrial: true
      }
    }

    isLoading.value = true

    try {
      // 取得設備資訊
      deviceInfo.value = getBrowserInfo()
      
      // 檢查設備狀態
      const result = await checkDeviceStatus(deviceInfo.value.deviceId)
      
      isInitialized.value = true
      isLoading.value = false
      
      return result
    } catch (error) {
      isLoading.value = false
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      }
    }
  }

  // 檢查設備狀態
  async function checkDeviceStatus(deviceId: string): Promise<DeviceBindingResult> {
    try {
      // 呼叫後端 API
      const response = await $fetch('/api/v1/devices/status', {
        method: 'POST',
        body: {
          device_id: deviceId
        }
      })

      return {
        success: true,
        deviceId,
        status: response as DeviceStatus,
        canUseFreeTrial: !(response as DeviceStatus).hasUsedFreeTrial
      }
    } catch (error) {
      // 如果 API 失敗，檢查本地儲存
      const localStatus = checkLocalStorage(deviceId)
      
      return {
        success: true,
        deviceId,
        status: localStatus,
        canUseFreeTrial: !localStatus.hasUsedFreeTrial
      }
    }
  }

  // 檢查本地儲存
  function checkLocalStorage(deviceId: string): DeviceStatus {
    const key = `device_${deviceId}`
    const stored = localStorage.getItem(key)
    
    if (stored) {
      try {
        return JSON.parse(stored)
      } catch {
        // 解析失敗，回傳預設值
      }
    }
    
    return {
      deviceId,
      hasUsedFreeTrial: false,
      isBanned: false
    }
  }

  // 標記設備已使用免費試用
  async function markFreeTrialUsed(): Promise<boolean> {
    if (!deviceInfo.value) {
      await initialize()
    }
    
    const deviceId = deviceInfo.value?.deviceId
    if (!deviceId) return false

    try {
      // 儲存到本地
      const status: DeviceStatus = {
        deviceId,
        hasUsedFreeTrial: true,
        isBanned: false,
        registeredAt: new Date().toISOString(),
        lastUsedAt: new Date().toISOString()
      }
      
      localStorage.setItem(`device_${deviceId}`, JSON.stringify(status))
      
      // 通知後端
      await $fetch('/api/v1/devices/mark-trial-used', {
        method: 'POST',
        body: { device_id: deviceId }
      })
      
      return true
    } catch {
      return false
    }
  }

  // 取得設備 ID
  function getDeviceId(): string {
    if (!deviceInfo.value) {
      deviceInfo.value = getBrowserInfo()
    }
    return deviceInfo.value.deviceId
  }

  // 檢查是否可以使用免費試用
  async function canUseFreeTrial(): Promise<boolean> {
    const result = await initialize()
    return result.canUseFreeTrial ?? false
  }

  return {
    deviceInfo,
    isInitialized,
    isLoading,
    initialize,
    checkDeviceStatus,
    markFreeTrialUsed,
    getDeviceId,
    canUseFreeTrial
  }
}
