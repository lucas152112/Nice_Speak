# Nice Speak Mobile App

## 專案資訊

| 項目 | 內容 |
|------|------|
| **App 名稱** | Nice Speak |
| **版本** | v1.0.0 |
| **Framework** | Flutter 3.x |
| **Platform** | iOS / Android |

---

## 系統架構

```
┌─────────────────────────────────────────────────┐
│              Nice Speak Mobile App              │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────┐  ┌─────────┐  ┌─────────────┐    │
│  │  Auth   │  │ Scenarios│  │  Practice   │    │
│  │  (認證) │  │ (情境)   │  │   (練習)    │    │
│  └─────────┘  └─────────┘  └─────────────┘    │
│         │            │              │            │
│         └────────────┼──────────────┘            │
│                      │                           │
│              ┌───────┴───────┐                   │
│              │   Services   │                   │
│              │   (API 服務)  │                   │
│              └───────────────┘                   │
│                      │                           │
│         ┌────────────┼────────────┐             │
│         ▼            ▼            ▼             │
│    ┌────────┐  ┌────────┐  ┌────────┐        │
│    │  iOS   │  │Android │  │ Web    │        │
│    └────────┘  └────────┘  └────────┘        │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 環境需求

| 軟體 | 版本需求 |
|------|----------|
| Flutter SDK | 3.0+ |
| Dart SDK | 3.0+ |
| Xcode | 14+ (iOS) |
| Android Studio | 2022+ (Android) |
| CocoaPods | 1.12+ (iOS) |

---

## 快速開始

### 1. 安裝 Flutter

```bash
# macOS
brew install flutter

# Windows/Linux
# 下載 SDK: https://docs.flutter.dev/get-started/install
```

### 2. 克隆專案

```bash
git clone https://github.com/lucas152112/Nice_Speak.git
cd Nice_Speak/mobile
```

### 3. 安裝依賴

```bash
flutter pub get
```

### 4. 執行

```bash
# 開發模式
flutter run

# 釋出版本
flutter build apk --release      # Android
flutter build ipa --release     # iOS
flutter build web --release     # Web
```

---

## 專案結構

```
mobile/
├── lib/
│   ├── main.dart              # 入口文件
│   ├── app.dart               # App 配置
│   │
│   ├── core/                  # 核心功能
│   │   ├── config.dart       # 配置
│   │   ├── constants.dart    # 常量
│   │   └── theme.dart        # 主題
│   │
│   ├── services/              # API 服務
│   │   ├── api_service.dart  # API 客戶端
│   │   ├── auth_service.dart  # 認證服務
│   │   ├── scenario_service.dart
│   │   ├── practice_service.dart
│   │   └── subscription_service.dart
│   │
│   ├── models/                # 數據模型
│   │   ├── user_model.dart
│   │   ├── scenario_model.dart
│   │   ├── dialogue_model.dart
│   │   └── practice_result_model.dart
│   │
│   ├── providers/             # 狀態管理
│   │   ├── auth_provider.dart
│   │   ├── subscription_provider.dart
│   │   └── scenario_provider.dart
│   │
│   ├── screens/               # 頁面
│   │   ├── splash/
│   │   ├── login/
│   │   ├── home/
│   │   ├── scenarios/
│   │   ├── practice/
│   │   ├── profile/
│   │   └── subscription/
│   │
│   ├── widgets/               # 共用元件
│   │   ├── scenario_card.dart
│   │   ├── dialogue_bubble.dart
│   │   └── progress_ring.dart
│   │
│   └── utils/                 # 工具
│       ├── extensions.dart
│       └── helpers.dart
│
├── assets/
│   ├── images/               # 圖片資源
│   ├── icons/                # 圖標資源
│   └── l10n/                 # 國際化
│       ├── app_en.arb
│       └── app_zh_TW.arb
│
├── ios/                      # iOS 配置
├── android/                  # Android 配置
├── web/                      # Web 配置
├── test/                     # 測試
└── pubspec.yaml              # 依賴配置
```

---

## 依賴配置 (pubspec.yaml)

```yaml
name: nice_speak
description: Nice Speak - AI 英語會話練習 App

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # 狀態管理
  provider: ^6.1.1
  
  # 網路請求
  dio: ^5.3.3
  http: ^1.1.0
  
  # 本地存儲
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # 語音
  record: ^5.0.3
  just_audio: ^0.9.36
  audioplayers: ^5.2.1
  
  # 圖片
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  
  # UI 元件
  flutter_animate: ^4.2.0
  confetti: ^0.7.0
  
  # 導航
  go_router: ^12.1.1
  
  # 國際化
  intl: ^0.18.1
  
  # 工具
  url_launcher: ^6.2.1
  package_info_plus: ^5.0.1
  device_info_plus: ^9.1.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.6

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/l10n/
```

---

## 主要功能

### 1. 認證系統
- [ ] 手機號碼登入
- [ ] Email 登入
- [ ] 忘記密碼
- [ ] 裝置綁定

### 2. 情境練習
- [ ] 情境列表瀏覽
- [ ] 情境詳情
- [ ] AI 對話練習
- [ ] 發音評估

### 3. 練習記錄
- [ ] 練習歷史
- [ ] 分數統計
- [ ] 等級進度

### 4. 訂閱管理
- [ ] 訂閱方案
- [ ] 試用期體驗
- [ ] 購買記錄

---

## API 端點

| # | Endpoint | 說明 |
|---|----------|------|
| 1 | POST /api/auth/login | 登入 |
| 2 | GET /api/scenarios | 情境列表 |
| 3 | GET /api/scenarios/:id | 情境詳情 |
| 4 | POST /api/practice/start | 開始練習 |
| 5 | POST /api/practice/submit | 提交練習 |
| 6 | GET /api/users/me | 個人資料 |
| 7 | GET /api/users/me/subscription | 訂閱狀態 |

---

## 打包命令

### Android

```bash
# APK
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release

# 輸出位置: build/app/outputs/flutter-apk/
```

### iOS

```bash
# IPA
flutter build ipa --release

# 輸出位置: build/ios/ipa/
```

### Web

```bash
flutter build web --release

# 輸出位置: build/web/
```

---

## 版本號規則

版本格式: `major.minor.patch+build`

| 部分 | 說明 | 範例 |
|------|------|------|
| major | 主版本 (重大變更) | 1 |
| minor | 次版本 (新功能) | 0 |
| patch | 修訂版本 (Bug 修復) | 0 |
| build | 建置號碼 | 1 |

---

## 建置編號

```bash
# Android
# 修改 android/local.properties
flutter.buildNumber=1

# iOS
# 修改 ios/Runner/Info.plist
CFBundleVersion = 1
CFBundleShortVersionString = 1.0.0
```

---

## 疑難排解

### Flutter 安裝問題
```bash
flutter doctor
flutter upgrade
```

### 依賴問題
```bash
flutter clean
flutter pub get
flutter pub cache repair
```

### iOS 建置問題
```bash
cd ios
pod install
pod update
flutter clean
flutter pub get
```

---

**版本**: v1.0.0  
**最後更新**: 2025-02-12
