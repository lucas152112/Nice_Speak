// manage/backend/src/roles/mod.rs

use axum::{Json, response::IntoResponse, extract::{Path, Query}};
use serde::{Deserialize, Serialize};
use sqlx::MySqlPool;

// ==================== TYPES ====================

#[derive(Serialize, sqlx::FromRow)]
pub struct Role {
    pub id: String,
    pub code: String,
    pub name: String,
    pub description: Option<String>,
    pub is_system: bool,
    pub level: i32,
    pub status: bool,
    pub created_at: chrono::DateTime<chrono::Utc>,
    pub updated_at: chrono::DateTime<chrono::Utc>,
}

#[derive(Serialize)]
pub struct RoleListResponse {
    pub roles: Vec<Role>,
    pub pagination: Pagination,
}

#[derive(Serialize)]
pub struct Pagination {
    pub page: i32,
    pub limit: i32,
    pub total: i64,
    pub total_pages: i32,
}

#[derive(Deserialize)]
pub struct CreateRoleRequest {
    pub code: String,
    pub name: String,
    pub description: Option<String>,
    pub level: i32,
    pub permissions: Option<Vec<String>>,
}

#[derive(Deserialize)]
pub struct UpdateRoleRequest {
    pub name: String,
    pub description: Option<String>,
    pub level: i32,
    pub permissions: Option<Vec<String>>,
}

#[derive(Serialize)]
pub struct RoleDetailResponse {
    pub role: Role,
    pub permissions: Vec<Permission>,
}

#[derive(Serialize, sqlx::FromRow)]
pub struct Permission {
    pub id: String,
    pub code: String,
    pub name: String,
    pub module: String,
    pub type_: String,
    pub description: Option<String>,
}

#[derive(Serialize)]
pub struct RoleMenusResponse {
    pub menus: Vec<MenuItem>,
}

#[derive(Serialize, sqlx::FromRow)]
pub struct MenuItem {
    pub id: String,
    pub name: String,
    pub icon: Option<String>,
    pub path: Option<String>,
    pub parent_id: Option<String>,
    pub order: i32,
}

// ==================== HANDLERS ====================

// 取得角色列表
pub async fn list(
    Query(query): Query<RoleQuery>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    let page = query.page.max(1);
    let limit = query.limit.min(100).max(1);
    let offset = (page - 1) * limit;

    // 查詢角色列表
    let roles: Vec<Role> = sqlx::query_as!(
        Role,
        r#"
        SELECT 
            id, code, name, description, is_system, level, status,
            created_at, updated_at
        FROM roles
        WHERE ($1 IS NULL OR name LIKE CONCAT('%', $1, '%') OR code LIKE CONCAT('%', $1, '%'))
        ORDER BY level DESC, created_at ASC
        LIMIT ? OFFSET ?
        "#,
        query.keyword, limit as u64, offset as u64
    )
    .fetch_all(&pool)
    .await
    .unwrap_or_default();

    // 查詢總數
    let total: i64 = sqlx::query_scalar!(
        r#"SELECT COUNT(*) FROM roles WHERE ($1 IS NULL OR name LIKE CONCAT('%', $1, '%') OR code LIKE CONCAT('%', $1, '%'))"#,
        query.keyword
    )
    .fetch_one(&pool)
    .await
    .unwrap_or(Some(0))
    .unwrap_or(0);

    let total_pages = (total as f64 / limit as f64).ceil() as i32;

    Json(RoleListResponse {
        roles,
        pagination: Pagination {
            page,
            limit,
            total,
            total_pages,
        },
    })
}

#[derive(Deserialize)]
pub struct RoleQuery {
    pub page: Option<i32>,
    pub limit: Option<i32>,
    pub keyword: Option<String>,
}

// 取得角色詳情
pub async fn get(
    Path(id): Path<String>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    let role: Option<Role> = sqlx::query_as!(
        Role,
        r#"
        SELECT id, code, name, description, is_system, level, status, created_at, updated_at
        FROM roles WHERE id = ?
        "#,
        id
    )
    .fetch_optional(&pool)
    .await
    .unwrap_or(None);

    match role {
        Some(role) => {
            // 取得角色權限
            let permissions: Vec<Permission> = sqlx::query_as!(
                Permission,
                r#"
                SELECT p.id, p.code, p.name, p.module, p.type as type_, p.description
                FROM permissions p
                INNER JOIN role_permissions rp ON p.id = rp.permission_id
                WHERE rp.role_id = ?
                ORDER BY p.module, p.type_
                "#,
                id
            )
            .fetch_all(&pool)
            .await
            .unwrap_or_default();

            Json(RoleDetailResponse { role, permissions })
        }
        None => {
            Json(serde_json::json!({
                "error": "角色不存在",
                "code": "ROLE_NOT_FOUND"
            }))
        }
    }
}

// 建立角色
pub async fn create(
    Json(payload): Json<CreateRoleRequest>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    // 檢查角色代碼是否已存在
    let exists: Option<String> = sqlx::query_scalar!(
        "SELECT id FROM roles WHERE code = ?",
        payload.code
    )
    .fetch_optional(&pool)
    .await
    .unwrap_or(None);

    if exists.is_some() {
        return Json(serde_json::json!({
            "error": "角色代碼已存在",
            "code": "CODE_EXISTS"
        }));
    }

    // 建立角色
    let role_id = uuid::Uuid::new_v4().to_string();
    let _ = sqlx::query!(
        r#"
        INSERT INTO roles (id, code, name, description, level, is_system, status)
        VALUES (?, ?, ?, ?, ?, 0, 1)
        "#,
        role_id, payload.code, payload.name, payload.description, payload.level
    )
    .execute(&pool)
    .await;

    // 建立角色-權限關聯
    if let Some(permissions) = payload.permissions {
        for perm_id in permissions {
            let _ = sqlx::query!(
                "INSERT INTO role_permissions (id, role_id, permission_id) VALUES (?, ?, ?)",
                uuid::Uuid::new_v4().to_string(),
                role_id,
                perm_id
            )
            .execute(&pool)
            .await;
        }
    }

    Json(serde_json::json!({
        "success": true,
        "role": {
            "id": role_id,
            "code": payload.code,
            "name": payload.name,
        }
    }))
}

// 更新角色
pub async fn update(
    Path(id): Path<String>,
    Json(payload): Json<UpdateRoleRequest>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    // 檢查角色是否存在
    let exists: Option<String> = sqlx::query_scalar!("SELECT id FROM roles WHERE id = ?", id)
        .fetch_optional(&pool)
        .await
        .unwrap_or(None);

    if exists.is_none() {
        return Json(serde_json::json!({
            "error": "角色不存在",
            "code": "ROLE_NOT_FOUND"
        }));
    }

    // 更新角色資料
    let _ = sqlx::query!(
        r#"
        UPDATE roles SET name = ?, description = ?, level = ?, updated_at = NOW()
        WHERE id = ?
        "#,
        payload.name, payload.description, payload.level, id
    )
    .execute(&pool)
    .await;

    // 更新權限關聯
    if let Some(permissions) = payload.permissions {
        // 刪除現有權限
        let _ = sqlx::query!("DELETE FROM role_permissions WHERE role_id = ?", id)
            .execute(&pool)
            .await;

        // 建立新權限關聯
        for perm_id in permissions {
            let _ = sqlx::query!(
                "INSERT INTO role_permissions (id, role_id, permission_id) VALUES (?, ?, ?)",
                uuid::Uuid::new_v4().to_string(),
                id,
                perm_id
            )
            .execute(&pool)
            .await;
        }
    }

    Json(serde_json::json!({
        "success": true,
        "message": "角色更新成功"
    }))
}

// 刪除角色
pub async fn delete(
    Path(id): Path<String>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    // 檢查是否為系統內建角色
    let is_system: Option<bool> = sqlx::query_scalar!("SELECT is_system FROM roles WHERE id = ?", id)
        .fetch_optional(&pool)
        .await
        .unwrap_or(None);

    if is_system == Some(true) {
        return Json(serde_json::json!({
            "error": "系統內建角色無法刪除",
            "code": "SYSTEM_ROLE"
        }));
    }

    // 刪除角色 (CASCADE 會刪除關聯資料)
    let _ = sqlx::query!("DELETE FROM roles WHERE id = ?", id)
        .execute(&pool)
        .await;

    Json(serde_json::json!({
        "success": true,
        "message": "角色刪除成功"
    }))
}

// 取得角色權限
pub async fn permissions(
    Path(id): Path<String>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    let permissions: Vec<Permission> = sqlx::query_as!(
        Permission,
        r#"
        SELECT p.id, p.code, p.name, p.module, p.type as type_, p.description
        FROM permissions p
        INNER JOIN role_permissions rp ON p.id = rp.permission_id
        WHERE rp.role_id = ?
        ORDER BY p.module, p.type_
        "#,
        id
    )
    .fetch_all(&pool)
    .await
    .unwrap_or_default();

    Json(serde_json::json!({
        "permissions": permissions,
        "total": permissions.len()
    }))
}

// 更新角色權限
pub async fn update_permissions(
    Path(id): Path<String>,
    Json(payload): Json<UpdatePermissionsRequest>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    // 檢查角色是否存在
    let exists: Option<String> = sqlx::query_scalar!("SELECT id FROM roles WHERE id = ?", id)
        .fetch_optional(&pool)
        .await
        .unwrap_or(None);

    if exists.is_none() {
        return Json(serde_json::json!({
            "error": "角色不存在",
            "code": "ROLE_NOT_FOUND"
        }));
    }

    // 刪除現有權限
    let _ = sqlx::query!("DELETE FROM role_permissions WHERE role_id = ?", id)
        .execute(&pool)
        .await;

    // 建立新權限關聯
    for perm_id in payload.permissions {
        let _ = sqlx::query!(
            "INSERT INTO role_permissions (id, role_id, permission_id) VALUES (?, ?, ?)",
            uuid::Uuid::new_v4().to_string(),
            id,
            perm_id
        )
        .execute(&pool)
        .await;
    }

    Json(serde_json::json!({
        "success": true,
        "message": "權限更新成功"
    }))
}

#[derive(Deserialize)]
pub struct UpdatePermissionsRequest {
    pub permissions: Vec<String>,
}

// 取得角色菜單
pub async fn menus(
    Path(id): Path<String>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    let menus: Vec<MenuItem> = sqlx::query_as!(
        MenuItem,
        r#"
        SELECT m.id, m.name, m.icon, m.path, m.parent_id, m.order
        FROM menus m
        INNER JOIN role_menus rm ON m.id = rm.menu_id
        WHERE rm.role_id = ? AND m.status = 1
        ORDER BY m.order
        "#,
        id
    )
    .fetch_all(&pool)
    .await
    .unwrap_or_default();

    Json(RoleMenusResponse { menus })
}

// 更新角色菜單
pub async fn update_menus(
    Path(id): Path<String>,
    Json(payload): Json<UpdateMenusRequest>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    // 檢查角色是否存在
    let exists: Option<String> = sqlx::query_scalar!("SELECT id FROM roles WHERE id = ?", id)
        .fetch_optional(&pool)
        .await
        .unwrap_or(None);

    if exists.is_none() {
        return Json(serde_json::json!({
            "error": "角色不存在",
            "code": "ROLE_NOT_FOUND"
        }));
    }

    // 刪除現有菜單
    let _ = sqlx::query!("DELETE FROM role_menus WHERE role_id = ?", id)
        .execute(&pool)
        .await;

    // 建立新菜單關聯
    for menu_id in payload.menus {
        let _ = sqlx::query!(
            "INSERT INTO role_menus (id, role_id, menu_id) VALUES (?, ?, ?)",
            uuid::Uuid::new_v4().to_string(),
            id,
            menu_id
        )
        .execute(&pool)
        .await;
    }

    Json(serde_json::json!({
        "success": true,
        "message": "菜單更新成功"
    }))
}

#[derive(Deserialize)]
pub struct UpdateMenusRequest {
    pub menus: Vec<String>,
}
