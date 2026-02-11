# 權限管理系統 (RBAC)

## 系統架構

```
┌─────────────────────────────────────────────────────────────────────┐
│                       權限管理系統 (RBAC)                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐               │
│  │   Users    │  │   Roles    │  │Permissions │               │
│  │   (用戶)   │  │   (角色)    │  │   (權限)    │               │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘               │
│         │                 │                 │                        │
│         └────────┬────────┴────────┬────────┘                        │
│                  │                  │                                 │
│                  ▼                  ▼                                 │
│         ┌─────────────┐  ┌─────────────┐                            │
│         │   User     │  │   Menu     │                            │
│         │   Roles    │  │   (動態選單) │                            │
│         └─────────────┘  └─────────────┘                            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 1. 角色定義 (Roles)

### 預設角色

| # | 角色代碼 | 角色名稱 | 說明 | 權限等級 |
|---|----------|----------|------|----------|
| 1 | `super_admin` | 超級管理員 | 全部權限 | 100 |
| 2 | `system_admin` | 系統管理員 | 除用戶刪除外全部 | 80 |
| 3 | `customer_service` | 客服人員 | 客戶管理、訂閱管理 | 60 |
| 4 | `content_admin` | 內容管理員 | 情境模板管理 | 50 |
| 5 | `analyst` | 分析人員 | 數據分析唯讀 | 40 |
| 6 | `finance` | 財務人員 | 收費管理、收入統計 | 60 |
| 7 | `support` | 支援人員 | 唯讀客戶數據 | 20 |

---

## 2. 權限定義 (Permissions)

### 權限類型

| 類型 | 前綴 | 說明 |
|------|------|------|
| 讀取 | `read:*` | 列表、詳情 |
| 寫入 | `write:*` | 新增、修改 |
| 刪除 | `delete:*` | 刪除 |
| 操作 | `action:*` | 特定操作 |

### 詳細權限

| # | 權限代碼 | 權限名稱 | 所屬模組 |
|---|----------|----------|----------|
| 1 | `read:users` | 讀取用戶列表 | 用戶 |
| 2 | `write:users` | 新增用戶 | 用戶 |
| 3 | `update:users` | 更新用戶 | 用戶 |
| 4 | `delete:users` | 刪除用戶 | 用戶 |
| 5 | `read:customers` | 讀取客戶 | 客戶 |
| 6 | `write:customers` | 更新客戶 | 客戶 |
| 7 | `ban:customers` | 封禁客戶 | 客戶 |
| 8 | `read:scenarios` | 讀取情境 | 情境 |
| 9 | `write:scenarios` | 新增情境 | 情境 |
| 10 | `publish:scenarios` | 發布情境 | 情境 |
| 11 | `delete:scenarios` | 刪除情境 | 情境 |
| 12 | `read:subscriptions` | 讀取訂閱 | 訂閱 |
| 13 | `write:subscriptions` | 管理訂閱 | 訂閱 |
| 14 | `refund:subscriptions` | 退款處理 | 訂閱 |
| 15 | `read:analytics` | 讀取分析 | 分析 |
| 16 | `export:analytics` | 匯出數據 | 分析 |
| 17 | `read:settings` | 讀取設定 | 設定 |
| 18 | `write:settings` | 修改設定 | 設定 |
| 19 | `read:audit` | 讀取日誌 | 審計 |
| 20 | `manage:roles` | 管理角色 | 角色 |
| 21 | `manage:permissions` | 管理權限 | 權限 |
| 22 | `manage:menus` | 管理選單 | 選單 |

---

## 3. 菜單定義 (Menus)

### 菜單結構

```typescript
interface MenuItem {
  id: string
  name: string
  icon: string
  path: string
  parent_id?: string
  order: number
  roles: string[]  // 可訪問的角色
  permissions: string[]  // 需要的權限
  children?: MenuItem[]
}
```

### 預設菜單

| # | 菜單名稱 | 路徑 | 圖標 | 父級 | 角色 |
|---|----------|------|------|------|------|
| 1 | 儀表板 | /dashboard | DashboardOutlined | - | 全部 |
| 2 | 客戶管理 | /customers | UserOutlined | - | 3,4,5,6,7 |
| 2.1 | 客戶列表 | /customers | TeamOutlined | 2 | 3,4,5,6,7 |
| 2.2 | 客戶詳情 | /customers/:id | - | 2 | 3,4,5,6,7 |
| 3 | 情境模板 | /scenarios | FileTextOutlined | - | 1,2,4 |
| 3.1 | 模板列表 | /scenarios | UnorderedListOutlined | 3 | 1,2,4 |
| 3.2 | 新增模板 | /scenarios/create | PlusOutlined | 3 | 1,2,4 |
| 3.3 | 模板編輯 | /scenarios/:id/edit | EditOutlined | 3 | 1,2,4 |
| 4 | 收費管理 | /subscriptions | DollarOutlined | - | 1,2,3,6 |
| 4.1 | 方案管理 | /subscriptions/plans | TagsOutlined | 4 | 1,2,3,6 |
| 4.2 | 訂閱列表 | /subscriptions/orders | OrderedListOutlined | 4 | 1,2,3,6 |
| 4.3 | 支付記錄 | /subscriptions/payments | CreditCardOutlined | 4 | 1,2,3,6 |
| 5 | 數據分析 | /analytics | BarChartOutlined | - | 1,2,5 |
| 5.1 | 總覽 | /analytics/overview | PieChartOutlined | 5 | 1,2,5 |
| 5.2 | 收入報表 | /analytics/revenue | RiseOutlined | 5 | 1,2,6 |
| 5.3 | 用戶分析 | /analytics/users | UserOutlined | 5 | 1,2,5 |
| 6 | 系統設定 | /settings | SettingOutlined | - | 1,2 |
| 6.1 | 角色管理 | /settings/roles | TeamOutlined | 6 | 1 |
| 6.2 | 選單管理 | /settings/menus | MenuOutlined | 6 | 1 |
| 6.3 | 系統參數 | /settings/parameters | SlidersOutlined | 6 | 1,2 |
| 7 | 審計日誌 | /audit | AuditOutlined | - | 1,2 |
| 7.1 | 操作日誌 | /audit/logs | FileSearchOutlined | 7 | 1,2 |
| 7.2 | 登入日誌 | /audit/logins | LoginOutlined | 7 | 1,2 |

---

## 4. 角色-權限對照表

| 角色 | 客戶 | 情境 | 收費 | 分析 | 設定 | 審計 |
|------|------|------|------|------|------|------|
| **超級管理員** | 全部 | 全部 | 全部 | 全部 | 全部 | 全部 |
| **系統管理員** | 全部 | 全部 | 全部 | 全部 | 讀取 | 讀取 |
| **客服人員** | 讀取/封禁 | - | 讀取 | - | - | - |
| **內容管理員** | - | 全部 | - | - | - | - |
| **分析人員** | - | - | 讀取 | 讀取/匯出 | - | - |
| **財務人員** | - | - | 全部 | 讀取 | - | - |
| **支援人員** | 讀取 | - | - | - | - | - |

---

## 5. 資料庫設計

### 5.1 roles 表

```sql
CREATE TABLE `roles` (
    `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    `code` VARCHAR(50) NOT NULL UNIQUE COMMENT '角色代碼',
    `name` VARCHAR(100) NOT NULL COMMENT '角色名稱',
    `description` VARCHAR(255) NULL COMMENT '說明',
    `is_system` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '系統內建',
    `level` INT NOT NULL DEFAULT 0 COMMENT '權限等級',
    `status` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '狀態',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_roles_code` (`code`),
    INDEX `idx_roles_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 5.2 permissions 表

```sql
CREATE TABLE `permissions` (
    `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    `code` VARCHAR(100) NOT NULL UNIQUE COMMENT '權限代碼',
    `name` VARCHAR(100) NOT NULL COMMENT '權限名稱',
    `module` VARCHAR(50) NOT NULL COMMENT '所屬模組',
    `type` VARCHAR(20) NOT NULL COMMENT '類型: read/write/delete/action',
    `description` VARCHAR(255) NULL COMMENT '說明',
    `status` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '狀態',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_permissions_module` (`module`),
    INDEX `idx_permissions_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 5.3 role_permissions 表

```sql
CREATE TABLE `role_permissions` (
    `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    `role_id` CHAR(36) NOT NULL COMMENT '角色ID',
    `permission_id` CHAR(36) NOT NULL COMMENT '權限ID',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_role_permission` (`role_id`, `permission_id`),
    INDEX `idx_role_permissions_role_id` (`role_id`),
    FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`permission_id`) REFERENCES `permissions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 5.4 menus 表

```sql
CREATE TABLE `menus` (
    `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    `name` VARCHAR(100) NOT NULL COMMENT '菜單名稱',
    `icon` VARCHAR(50) NULL COMMENT '圖標',
    `path` VARCHAR(255) NULL COMMENT '路徑',
    `parent_id` CHAR(36) NULL COMMENT '父級ID',
    `order` INT NOT NULL DEFAULT 0 COMMENT '排序',
    `status` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '狀態',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_menus_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 5.5 role_menus 表

```sql
CREATE TABLE `role_menus` (
    `id` CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    `role_id` CHAR(36) NOT NULL COMMENT '角色ID',
    `menu_id` CHAR(36) NOT NULL COMMENT '菜單ID',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_role_menu` (`role_id`, `menu_id`),
    INDEX `idx_role_menus_role_id` (`role_id`),
    FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`menu_id`) REFERENCES `menus`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4_unicode_ci;
```

### 5.6 admin_users 表 (新增欄位)

```sql
ALTER TABLE `admin_users` ADD COLUMN `role_id` CHAR(36) NULL COMMENT '角色ID' AFTER `password`;
ALTER TABLE `admin_users` ADD COLUMN `status` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '狀態' AFTER `role_id`;

CREATE INDEX `idx_admin_users_role_id` ON `admin_users`(`role_id`);
```

---

## 6. API 端點

### 6.1 角色管理

| # | Method | Endpoint | 說明 | 權限 |
|---|--------|----------|------|------|
| 1 | GET | /api/admin/roles | 角色列表 | manage:roles |
| 2 | POST | /api/admin/roles | 新增角色 | manage:roles |
| 3 | GET | /api/admin/roles/:id | 角色詳情 | manage:roles |
| 4 | PUT | /api/admin/roles/:id | 更新角色 | manage:roles |
| 5 | DELETE | /api/admin/roles/:id | 刪除角色 | manage:roles |
| 6 | GET | /api/admin/roles/:id/permissions | 角色權限 | manage:roles |
| 7 | PUT | /api/admin/roles/:id/permissions | 更新權限 | manage:roles |
| 8 | GET | /api/admin/roles/:id/menus | 角色菜單 | manage:roles |
| 9 | PUT | /api/admin/roles/:id/menus | 更新菜單 | manage:roles |

### 6.2 權限管理

| # | Method | Endpoint | 說明 | 權限 |
|---|--------|----------|------|------|
| 1 | GET | /api/admin/permissions | 權限列表 | manage:permissions |
| 2 | GET | /api/admin/permissions/grouped | 分組權限 | manage:permissions |

### 6.3 菜單管理

| # | Method | Endpoint | 說明 | 權限 |
|---|--------|----------|------|------|
| 1 | GET | /api/admin/menus | 菜單列表 | manage:menus |
| 2 | POST | /api/admin/menus | 新增菜單 | manage:menus |
| 3 | GET | /api/admin/menus/:id | 菜單詳情 | manage:menus |
| 4 | PUT | /api/admin/menus/:id | 更新菜單 | manage:menus |
| 5 | DELETE | /api/admin/menus/:id | 刪除菜單 | manage:menus |
| 6 | PUT | /api/admin/menus/reorder | 調整順序 | manage:menus |
| 7 | GET | /api/admin/menus/tree | 樹狀結構 | - |

### 6.4 我的權限

| # | Method | Endpoint | 說明 |
|---|--------|----------|------|
| 1 | GET | /api/admin/my/permissions | 我的權限 |
| 2 | GET | /api/admin/my/menus | 我的菜單 |

---

## 7. 預設資料 SQL

```sql
-- 插入權限
INSERT INTO `permissions` (`id`, `code`, `name`, `module`, `type`) VALUES
('perm-001', 'read:users', '讀取用戶', 'users', 'read'),
('perm-002', 'write:users', '新增用戶', 'users', 'write'),
('perm-003', 'update:users', '更新用戶', 'users', 'write'),
('perm-004', 'delete:users', '刪除用戶', 'users', 'delete'),
('perm-005', 'read:customers', '讀取客戶', 'customers', 'read'),
('perm-006', 'write:customers', '更新客戶', 'customers', 'write'),
('perm-007', 'ban:customers', '封禁客戶', 'customers', 'action'),
('perm-008', 'read:scenarios', '讀取情境', 'scenarios', 'read'),
('perm-009', 'write:scenarios', '新增情境', 'scenarios', 'write'),
('perm-010', 'publish:scenarios', '發布情境', 'scenarios', 'action'),
('perm-011', 'delete:scenarios', '刪除情境', 'scenarios', 'delete'),
('perm-012', 'read:subscriptions', '讀取訂閱', 'subscriptions', 'read'),
('perm-013', 'write:subscriptions', '管理訂閱', 'subscriptions', 'write'),
('perm-014', 'refund:subscriptions', '退款處理', 'subscriptions', 'action'),
('perm-015', 'read:analytics', '讀取分析', 'analytics', 'read'),
('perm-016', 'export:analytics', '匯出數據', 'analytics', 'action'),
('perm-017', 'read:settings', '讀取設定', 'settings', 'read'),
('perm-018', 'write:settings', '修改設定', 'settings', 'write'),
('perm-019', 'read:audit', '讀取日誌', 'audit', 'read'),
('perm-020', 'manage:roles', '管理角色', 'roles', 'write'),
('perm-021', 'manage:permissions', '管理權限', 'permissions', 'write'),
('perm-022', 'manage:menus', '管理選單', 'menus', 'write');

-- 插入角色
INSERT INTO `roles` (`id`, `code`, `name`, `description`, `is_system`, `level`) VALUES
('role-001', 'super_admin', '超級管理員', '擁有全部權限', 1, 100),
('role-002', 'system_admin', '系統管理員', '除用戶刪除外全部權限', 1, 80),
('role-003', 'customer_service', '客服人員', '客戶管理、訂閱管理', 1, 60),
('role-004', 'content_admin', '內容管理員', '情境模板管理', 1, 50),
('role-005', 'analyst', '分析人員', '數據分析唯讀', 1, 40),
('role-006', 'finance', '財務人員', '收費管理、收入統計', 1, 60),
('role-007', 'support', '支援人員', '唯讀客戶數據', 1, 20);

-- 超級管理員擁有全部權限
INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 'role-001', `id` FROM `permissions`;

-- 系統管理員 (除 delete:users 外全部)
INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 'role-002', `id` FROM `permissions` WHERE `code` != 'delete:users';

-- 客服人員
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
('role-003', 'perm-005'),
('role-003', 'perm-006'),
('role-003', 'perm-007'),
('role-003', 'perm-012');

-- 內容管理員
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
('role-004', 'perm-008'),
('role-004', 'perm-009'),
('role-004', 'perm-010'),
('role-004', 'perm-011');

-- 分析人員
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
('role-005', 'perm-015'),
('role-005', 'perm-016');

-- 財務人員
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
('role-006', 'perm-012'),
('role-006', 'perm-013'),
('role-006', 'perm-014'),
('role-006', 'perm-015');

-- 支援人員
INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
('role-007', 'perm-005');
```

---

**版本**: v1.0.0  
**建立日期**: 2024-XX-XX
