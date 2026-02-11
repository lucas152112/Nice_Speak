# Nice Speak 管理後台 API 文檔

## 概述

- Base URL: `/api/admin`
- 認證: Bearer Token (Header: `Authorization: Bearer <token>`)
- 響應格式: JSON

---

## 認證 (Auth)

### 登入
```
POST /api/admin/auth/login
Content-Type: application/json

Request:
{
  "email": "admin@example.com",
  "password": "password123"
}

Response (200):
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "uuid",
    "email": "admin@example.com",
    "name": "Admin",
    "role_code": "super_admin",
    "permissions": ["read:users", "write:users", ...]
  }
}
```

### 取得當前用戶
```
GET /api/admin/auth/me
Authorization: Bearer <token>

Response (200):
{
  "id": "uuid",
  "email": "admin@example.com",
  "name": "Admin",
  "role_code": "super_admin",
  "permissions": [...]
}
```

---

## 角色管理 (Roles)

### 角色列表
```
GET /api/admin/roles
Query Parameters:
  - page: number (default: 1)
  - limit: number (default: 20)
  - keyword: string (optional)

Response (200):
{
  "roles": [
    {
      "id": "uuid",
      "code": "super_admin",
      "name": "超級管理員",
      "description": "擁有全部權限",
      "is_system": true,
      "level": 100,
      "status": true,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 7,
    "total_pages": 1
  }
}
```

### 建立角色
```
POST /api/admin/roles
Authorization: Bearer <token>
Content-Type: application/json

Request:
{
  "code": "custom_role",
  "name": "自定義角色",
  "description": "角色說明",
  "level": 50,
  "permissions": ["perm-001", "perm-002"]
}

Response (201):
{
  "success": true,
  "role": {
    "id": "uuid",
    "code": "custom_role",
    "name": "自定義角色"
  }
}
```

### 更新角色
```
PUT /api/admin/roles/:id
Authorization: Bearer <token>
Content-Type: application/json

Request:
{
  "name": "更新後的角色名稱",
  "description": "更新後的說明",
  "level": 60,
  "permissions": ["perm-001", "perm-002", "perm-003"]
}

Response (200):
{
  "success": true,
  "message": "角色更新成功"
}
```

### 刪除角色
```
DELETE /api/admin/roles/:id
Authorization: Bearer <token>

Response (200):
{
  "success": true,
  "message": "角色刪除成功"
}
```

### 取得角色權限
```
GET /api/admin/roles/:id/permissions
Authorization: Bearer <token>

Response (200):
{
  "permissions": [
    {
      "id": "perm-001",
      "code": "read:users",
      "name": "讀取用戶",
      "module": "users",
      "type": "read"
    }
  ],
  "total": 22
}
```

### 更新角色權限
```
PUT /api/admin/roles/:id/permissions
Authorization: Bearer <token>
Content-Type: application/json

Request:
{
  "permissions": ["perm-001", "perm-002", "perm-003"]
}

Response (200):
{
  "success": true,
  "message": "權限更新成功"
}
```

---

## 權限管理 (Permissions)

### 權限列表
```
GET /api/admin/permissions
Query Parameters:
  - module: string (optional)
  - type: string (optional)
  - keyword: string (optional)

Response (200):
{
  "permissions": [...],
  "total": 22
}
```

### 分組權限
```
GET /api/admin/permissions/grouped
Authorization: Bearer <token>

Response (200):
{
  "groups": [
    {
      "module": "users",
      "display_name": "用戶管理",
      "permissions": [...]
    }
  ],
  "total": 22
}
```

---

## 菜單管理 (Menus)

### 樹狀菜單
```
GET /api/admin/menus/tree
Authorization: Bearer <token>

Response (200):
{
  "menus": [
    {
      "id": "menu-001",
      "name": "儀表板",
      "icon": "DashboardOutlined",
      "path": "/dashboard",
      "order": 1,
      "status": true,
      "children": [...]
    }
  ]
}
```

### 建立菜單
```
POST /api/admin/menus
Authorization: Bearer <token>
Content-Type: application/json

Request:
{
  "name": "新菜單",
  "icon": "SettingOutlined",
  "path": "/new-page",
  "parent_id": "menu-001",
  "order": 5
}

Response (201):
{
  "success": true,
  "menu": {
    "id": "uuid",
    "name": "新菜單",
    "path": "/new-page",
    "order": 5
  }
}
```

---

## 錯誤響應

所有 API 錯誤響應格式:

```json
{
  "error": "錯誤訊息",
  "code": "ERROR_CODE",
  "details": {}
}
```

### 常見錯誤碼

| 錯誤碼 | 說明 |
|--------|------|
| `ROLE_NOT_FOUND` | 角色不存在 |
| `PERMISSION_NOT_FOUND` | 權限不存在 |
| `MENU_NOT_FOUND` | 菜單不存在 |
| `CODE_EXISTS` | 代碼已存在 |
| `SYSTEM_ROLE` | 系統內建角色無法刪除 |
| `HAS_CHILDREN` | 菜單有子項目無法刪除 |
| `CIRCULAR_REFERENCE` | 循環引用 |

---

## 速率限制

- 預設限制: 100 requests/minute
- 認證後限制: 1000 requests/minute

---

**最後更新**: 2025-02-11
