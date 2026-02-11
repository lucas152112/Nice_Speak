# RBAC 權限管理系統 - 開發摘要

## 專案資訊

| 項目 | 內容 |
|------|------|
| **專案名稱** | Nice_Speak |
| **子專案** | 管理後台 (Manage Backend) |
| **版本** | v1.0.0 |
| **建立日期** | 2025-02-11 |

---

## 系統架構

```
┌─────────────────────────────────────────────────────────────┐
│                    管理後台系統架構                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│   │   Frontend │    │   Backend   │    │   Database  │   │
│   │   (Nuxt 3) │◄──►│   (Rust)    │◄──►│   (MySQL)   │   │
│   └─────────────┘    └─────────────┘    └─────────────┘   │
│          │                                          │      │
│          │         ┌─────────────┐                  │      │
│          └────────►│   RBAC      │                  │      │
│                    │   權限系統   │                  │      │
│                    └─────────────┘                  │      │
│                           │                          │      │
│              ┌────────────┼────────────┐            │      │
│              ▼            ▼            ▼            │      │
│        ┌──────────┐ ┌──────────┐ ┌──────────┐       │      │
│        │  Roles   │ │Permissions│ │  Menus  │       │      │
│        │  (7角色) │ │ (22權限) │ │  (7菜單) │       │      │
│        └──────────┘ └──────────┘ └──────────┘       │      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 已完成功能

### 1. 資料庫設計 (5 個資料表)

| # | 資料表 | 說明 |
|---|--------|------|
| 1 | `roles` | 角色定義 |
| 2 | `permissions` | 權限定義 |
| 3 | `role_permissions` | 角色-權限關聯 |
| 4 | `menus` | 菜單定義 |
| 5 | `role_menus` | 角色-菜單關聯 |

### 2. 角色定義 (7 種角色)

| # | 角色代碼 | 角色名稱 | 權限等級 |
|---|----------|----------|----------|
| 1 | super_admin | 超級管理員 | 100 |
| 2 | system_admin | 系統管理員 | 80 |
| 3 | customer_service | 客服人員 | 60 |
| 4 | content_admin | 內容管理員 | 50 |
| 5 | analyst | 分析人員 | 40 |
| 6 | finance | 財務人員 | 60 |
| 7 | support | 支援人員 | 20 |

### 3. 權限定義 (22 種權限)

| 模組 | 讀取 | 寫入 | 刪除 | 操作 |
|------|------|------|------|------|
| 用戶管理 | read:users | write:users | delete:users | - |
| 客戶管理 | read:customers | write:customers | - | ban:customers |
| 情境管理 | read:scenarios | write:scenarios | delete:scenarios | publish:scenarios |
| 訂閱管理 | read:subscriptions | write:subscriptions | - | refund:subscriptions |
| 數據分析 | read:analytics | - | - | export:analytics |
| 系統設定 | read:settings | write:settings | - | - |
| 審計日誌 | read:audit | - | - | - |
| 角色管理 | - | manage:roles | - | - |
| 權限管理 | - | manage:permissions | - | - |
| 選單管理 | - | manage:menus | - | - |

### 4. 菜單結構 (7 個主菜單)

```
儀表板 (/dashboard)
客戶管理 (/customers)
├── 客戶列表
情境模板 (/scenarios)
├── 模板列表
├── 新增模板
收費管理 (/subscriptions)
├── 方案管理
├── 訂閱列表
├── 支付記錄
數據分析 (/analytics)
├── 總覽
├── 收入報表
系統設定 (/settings)
├── 角色管理
├── 選單管理
└── 系統參數
審計日誌 (/audit)
├── 操作日誌
└── 登入日誌
```

---

## 技術堆疊

### 前端 (Frontend)
- **框架**: Nuxt 3 (Vue 3)
- **UI 套件**: Element Plus
- **狀態管理**: Pinia
- **API 客戶端**: useFetch

### 後端 (Backend)
- **框架**: Axum (Rust)
- **資料庫**: MySQL 8.0
- **ORM**: sqlx
- **認證**: JWT

---

## API 端點總覽

### 角色管理
| Method | Endpoint | 說明 |
|--------|----------|------|
| GET | /api/admin/roles | 角色列表 |
| POST | /api/admin/roles | 建立角色 |
| GET | /api/admin/roles/:id | 角色詳情 |
| PUT | /api/admin/roles/:id | 更新角色 |
| DELETE | /api/admin/roles/:id | 刪除角色 |
| GET | /api/admin/roles/:id/permissions | 角色權限 |
| PUT | /api/admin/roles/:id/permissions | 更新權限 |
| GET | /api/admin/roles/:id/menus | 角色菜單 |
| PUT | /api/admin/roles/:id/menus | 更新菜單 |

### 權限管理
| Method | Endpoint | 說明 |
|--------|----------|------|
| GET | /api/admin/permissions | 權限列表 |
| GET | /api/admin/permissions/grouped | 分組權限 |

### 菜單管理
| Method | Endpoint | 說明 |
|--------|----------|------|
| GET | /api/admin/menus/tree | 樹狀菜單 |
| GET | /api/admin/menus | 菜單列表 |
| POST | /api/admin/menus | 建立菜單 |
| PUT | /api/admin/menus/:id | 更新菜單 |
| DELETE | /api/admin/menus/:id | 刪除菜單 |
| PUT | /api/admin/menus/reorder | 調整順序 |

---

## 檔案結構

```
Nice_Speak/manage/
├── backend/
│   ├── migrations/
│   │   ├── 001_rbac_schema.sql       # 表結構
│   │   └── 002_rbac_seed_data.sql    # 初始資料
│   ├── src/
│   │   ├── roles/mod.rs              # 角色 API
│   │   ├── permissions/mod.rs        # 權限 API
│   │   └── menus/mod.rs              # 菜單 API
│   ├── API.md                         # API 文檔
│   └── RBAC.md                       # RBAC 設計文件
│
└── web/
    ├── layouts/
    │   └── default.vue                # 管理後台佈局
    ├── pages/
    │   ├── index.vue                  # 儀表板
    │   ├── login.vue                  # 登入頁面
    │   ├── customers/                 # 客戶管理
    │   ├── scenarios/                 # 情境管理
    │   ├── subscriptions/             # 訂閱管理
    │   ├── analytics/                 # 數據分析
    │   ├── settings/                  # 系統設定
    │   │   ├── roles.vue              # 角色管理
    │   │   ├── menus.vue              # 菜單管理
    │   │   ├── permissions.vue        # 權限管理
    │   │   └── parameters.vue         # 系統參數
    │   └── audit/                     # 審計日誌
    ├── services/
    │   ├── role.ts                    # 角色 API 服務
    │   ├── permission.ts              # 權限 API 服務
    │   └── menu.ts                    # 菜單 API 服務
    └── types/
        └── auth.ts                    # 類型定義
```

---

## 下一步

- [ ] 前後端整合測試
- [ ] 權限中間件實作
- [ ] 審計日誌實作
- [ ] Docker 部署腳本
- [ ] CI/CD 流程

---

**版本**: v1.0.0  
**最後更新**: 2025-02-11
