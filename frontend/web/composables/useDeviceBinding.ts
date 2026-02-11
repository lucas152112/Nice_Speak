// composables/useDeviceBinding.ts
import { ref } from 'vue'

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
  firstUsedAt?: string
  trialExpiredAt?: string
  registeredAt?: string
  lastUsedAt?: string
}

// 免費試用檢查結果
interface FreeTrialResult {
  canUse: boolean
  reason: FreeTrialReason
  daysRemaining: number
  firstUsedAt?: Date
  trialExpiredAt?: Date
}

// 免費試用原因
type FreeTrialReason = 
  | 'first_time'      // 初次使用
  | 'active'         // 試用中
  | 'already_used'   // 已使用過
  | 'expired'        // 已過期
  | 'banned'         // 被封禁

// 設備綁定服務
export function useDeviceBinding() {
  const deviceInfo = ref<DeviceInfo | null>(null)
  const isInitialized = ref(false)
  const isLoading = ref(false)
  const FREE_TRIAL_DAYS = 3  // 免費試用天數

  // 產生設備指紋
  function generateFingerprint(): string {
    const info = getBrowserInfo()
    const input = `${info.userAgent}:${info.screenResolution}:${info.language}:${info.timezone}`
    
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

  // 取得本地初次使用時間
  function getLocalFirstUseDate(): Date | null {
    const key = 'first_use_timestamp'
    const stored = localStorage.getItem(key)
    
    if (stored) {
      try {
        return new Date(parseInt(stored))
      } catch {
        return null
      }
    }
    return null
  }

  // 設定初次使用時間
  function setLocalFirstUseDate(): void {
    const key = 'first_use_timestamp'
    const now = Date.now().toString()
    localStorage.setItem(key, now)
  }

  // 檢查設備狀態 (後端 API)
  async function checkDeviceStatus(deviceId: string): Promise<DeviceStatus> {
    try {
      const response = await $fetch('/api/v1/devices/status', {
        method: 'POST',
        body: { device_id: deviceId }
      })

      return response as DeviceStatus
    } catch {
      // API 失敗時回傳預設值
      return {
        deviceId,
        hasUsedFreeTrial: false,
        isBanned: false
      }
    }
  }

  // 檢查免費試用狀態 (含時間邏輯)
  async function checkFreeTrialStatus(): Promise<FreeTrialResult> {
    const deviceId = getDeviceId()
    
    // 1. 檢查本地初次使用時間
    const localFirstUse = getLocalFirstUseDate()
    
    // 如果沒有初次使用時間，設定並允許使用
    if (!localFirstUse) {
      setLocalFirstUseDate()
      return {
        canUse: true,
        reason: 'first_time',
        daysRemaining: FREE_TRIAL_DAYS,
        firstUsedAt: new Date(),
        trialExpiredAt: new Date(Date.now() + FREE_TRIAL_DAYS * 24 * 60 * 60 * 1000)
      }
    }

    // 2. 檢查後端設備狀態
    const status = await checkDeviceStatus(deviceId)
    
    if (status.isBanned) {
      return {
        canUse: false,
        reason: 'banned',
        daysRemaining: 0
      }
    }

    if (status.hasUsedFreeTrial) {
      return {
        canUse: false,
        reason: 'already_used',
        daysRemaining: 0
      }
    }

    // 3. 計算試用是否過期
    const firstUsedAt = status.firstUsedAt 
      ? new Date(status.firstUsedAt) 
      : localFirstUse!
    
    const trialExpiredAt = status.trialExpiredAt 
      ? new Date(status.trialExpiredAt)
      : new Date(firstUsedAt.getTime() + FREE_TRIAL_DAYS * 24 * 60 * 60 * 1000)
    
    const now = new Date()
    const daysRemaining = Math.ceil(
      (trialExpiredAt.getTime() - now.getTime()) / (24 * 60 * 60 * 1000)
    )

    if (daysRemaining <= 0) {
      return {
        canUse: false,
        reason: 'expired',
        daysRemaining: 0,
        firstUsedAt,
        trialExpiredAt
      }
    }

    return {
      canUse: true,
      reason: 'active',
      daysRemaining,
      firstUsedAt,
      trialExpiredAt
    }
  }

  // 初始化設備綁定
  async function initialize(): Promise<FreeTrialResult> {
    if (isLoading.value || isInitialized.value) {
      return checkFreeTrialStatus()
    }

    isLoading.value = true

    try {
      deviceInfo.value = getBrowserInfo()
      const result = await checkFreeTrialStatus()
      isInitialized.value = true
      isLoading.value = false
      return result
    } catch (error) {
      isLoading.value = false
      throw error
    }
  }

  // 標記設備已使用免費試用
  async function markFreeTrialUsed(): Promise<boolean> {
    const deviceId = getDeviceId()
    
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

  return {
    deviceInfo,
    isInitialized,
    isLoading,
    FREE_TRIAL_DAYS,
    initialize,
    checkFreeTrialStatus,
    markFreeTrialUsed,
    getDeviceId,
    getLocalFirstUseDate,
    setLocalFirstUseDate
  }
}
