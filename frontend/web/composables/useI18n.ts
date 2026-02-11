// composables/useI18n.ts
import { ref, computed } from 'vue'

// 語系定義
const translations: Record<string, Record<string, string>> = {
  'zh_TW': {
    'appName': 'Nice Speak',
    'welcome': '歡迎使用 Nice Speak',
    'login': '登入',
    'register': '註冊',
    'email': '電子郵件',
    'password': '密碼',
    'confirmPassword': '確認密碼',
    'name': '姓名',
    'submit': '送出',
    'cancel': '取消',
    'home': '首頁',
    'profile': '個人資料',
    'settings': '設定',
    'logout': '登出',
    'scenarios': '情境練習',
    'practice': '開始練習',
    'level': '等級',
    'score': '分數',
    'evaluation': '評估',
    'subscription': '訂閱',
    'freeTrial': '免費試用',
    'daysLeft': '剩餘 {count} 天',
    'upgradeNow': '立即升級',
    'loading': '載入中...',
    'error': '發生錯誤',
    'retry': '重試',
    'success': '成功',
    'noData': '暫無資料',
    'pronunciation': '發音',
    'grammar': '語法',
    'vocabulary': '用詞',
    'fluency': '流暢度',
    'totalScore': '總分',
    'congratulations': '恭喜！',
    'levelUp': '升級！',
    'keepPracticing': '繼續練習',
    'reviewErrors': '複習錯誤',
    'startPractice': '開始練習',
    'selectScenario': '選擇情境',
    'vocabularyPreview': '單字預習',
    'iAmReady': '我已準備好',
    'skip': '略過',
    'record': '錄音',
    'stop': '停止',
    'play': '播放',
    'next': '下一題',
    'finish': '完成',
    'welcomeTitle': '軟體開發英語口語學習',
    'welcomeSubtitle': '透過情境對話提升你的英語口說能力',
    'getStarted': '立即開始',
    'alreadyHaveAccount': '已有帳號？',
    'noAccount': '沒有帳號？',
    'rememberMe': '記住我',
    'forgotPassword': '忘記密碼？',
    'yourLevel': '你的等級',
    'totalPractices': '總練習次數',
    'averageScore': '平均分數',
    'keepItUp': '繼續保持！',
    'pricing': '方案選擇',
    'monthly': '月付',
    'yearly': '年付',
    'perMonth': '/月',
    'perYear': '/年',
    'subscribeNow': '立即訂閱',
    'manageSubscription': '管理訂閱',
    'cancelSubscription': '取消訂閱',
    'subscriptionActive': '訂閱中',
    'subscriptionExpired': '訂閱已過期',
    'validUntil': '有效期限'
  },
  'en': {
    'appName': 'Nice Speak',
    'welcome': 'Welcome to Nice Speak',
    'login': 'Login',
    'register': 'Register',
    'email': 'Email',
    'password': 'Password',
    'confirmPassword': 'Confirm Password',
    'name': 'Name',
    'submit': 'Submit',
    'cancel': 'Cancel',
    'home': 'Home',
    'profile': 'Profile',
    'settings': 'Settings',
    'logout': 'Logout',
    'scenarios': 'Scenarios',
    'practice': 'Practice',
    'level': 'Level',
    'score': 'Score',
    'evaluation': 'Evaluation',
    'subscription': 'Subscription',
    'freeTrial': 'Free Trial',
    'daysLeft': '{count} days left',
    'upgradeNow': 'Upgrade Now',
    'loading': 'Loading...',
    'error': 'An error occurred',
    'retry': 'Retry',
    'success': 'Success',
    'noData': 'No data available',
    'pronunciation': 'Pronunciation',
    'grammar': 'Grammar',
    'vocabulary': 'Vocabulary',
    'fluency': 'Fluency',
    'totalScore': 'Total Score',
    'congratulations': 'Congratulations!',
    'levelUp': 'Level Up!',
    'keepPracticing': 'Keep Practicing',
    'reviewErrors': 'Review Errors',
    'startPractice': 'Start Practice',
    'selectScenario': 'Select Scenario',
    'vocabularyPreview': 'Vocabulary Preview',
    'iAmReady': 'I am Ready',
    'skip': 'Skip',
    'record': 'Record',
    'stop': 'Stop',
    'play': 'Play',
    'next': 'Next',
    'finish': 'Finish',
    'welcomeTitle': 'Software Development English Learning',
    'welcomeSubtitle': 'Improve your English speaking skills through scenario-based dialogues',
    'getStarted': 'Get Started',
    'alreadyHaveAccount': 'Already have an account?',
    'noAccount': "Don't have an account?",
    'rememberMe': 'Remember me',
    'forgotPassword': 'Forgot password?',
    'yourLevel': 'Your Level',
    'totalPractices': 'Total Practices',
    'averageScore': 'Average Score',
    'keepItUp': 'Keep it up!',
    'pricing': 'Pricing',
    'monthly': 'Monthly',
    'yearly': 'Yearly',
    'perMonth': '/month',
    'perYear': '/year',
    'subscribeNow': 'Subscribe Now',
    'manageSubscription': 'Manage Subscription',
    'cancelSubscription': 'Cancel Subscription',
    'subscriptionActive': 'Active',
    'subscriptionExpired': 'Expired',
    'validUntil': 'Valid until'
  }
}

// 當前語系
const currentLocale = ref('zh_TW')

export function useI18n() {
  // 取得翻譯
  function t(key: string): string {
    const locale = translations[currentLocale.value]
    if (locale && locale[key]) {
      return locale[key]
    }
    // 如果找不到，回退到英文
    const en = translations['en']
    return en[key] || key
  }
  
  // 取得翻譯（支援插值）
  function tInterpolate(key: string, params: Record<string, string | number> = {}): string {
    let text = t(key)
    for (const [key, value] of Object.entries(params)) {
      text = text.replace(`{${key}}`, String(value))
    }
    return text
  }
  
  // 取得目前語系
  function getLocale(): string {
    return currentLocale.value
  }
  
  // 設定語系
  function setLocale(locale: string) {
    if (translations[locale]) {
      currentLocale.value = locale
      // 儲存到 localStorage
      if (typeof localStorage !== 'undefined') {
        localStorage.setItem('locale', locale)
      }
    }
  }
  
  // 初始化（從 localStorage 讀取）
  function initLocale() {
    if (typeof localStorage !== 'undefined') {
      const saved = localStorage.getItem('locale')
      if (saved && translations[saved]) {
        currentLocale.value = saved
      }
    }
  }
  
  // 可用的語系列表
  function availableLocales(): string[] {
    return Object.keys(translations)
  }
  
  return {
    t,
    tInterpolate,
    getLocale,
    setLocale,
    initLocale,
    availableLocales,
    currentLocale
  }
}
