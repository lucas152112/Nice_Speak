// manage/backend/src/roles/mod.rs

use axum::{Json, response::IntoResponse, extract::Path};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use sqlx::MySqlPool;

// ==================== TYPES ====================

#[derive(Serialize)]
pub struct Role {
    pub id: String,
    pub code: String,
    pub name: String,
    pub description: Option<String>,
    pub is_system: bool,
    pub level: i32,
    pub status: bool,
    pub created_at: String,
    pub updated_at: String,
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
    pub total: i32,
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

#[derive(Serialize)]
pub struct Permission {
    pub id: String,
    pub code: String,
    pub name: String,
    pub module: String,
    pub type_: String,
}

// ==================== HANDLERS ====================

// 取得角色列表
pub async fn list(
    Json(query): Json<Option<RoleQuery>>,
) -> impl IntoResponse {
    let query = query.unwrap_or_else(|| RoleQuery {
        page: 1,
        limit: 20,
        keyword: None,
    });

    // TODO: 從資料庫查詢
    Json(RoleListResponse {
        roles: vec![
            Role {
                id: "role-001".to_string(),
                code: "super_admin".to_string(),
                name: "超級管理員".to_string(),
                description: Some("擁有全部權限".to_string()),
                is_system: true,
                level: 100,
                status: true,
                created_at: "2024-01-01T00:00:00Z".to_string(),
                updated_at: "2024-01-01T00:00:00Z".to_string(),
            },
            Role {
                id: "role-002".to_string(),
                code: "system_admin".to_string(),
                name: "系統管理員".to_string(),
                description: Some("除用戶刪除外全部權限".to_string()),
                is_system: true,
                level: 80,
                status: true,
                created_at: "2024-01-01T00:00:00Z".to_string(),
                updated_at: "2024-01-01T00:00:00Z".to_string(),
            },
        ],
        pagination: Pagination {
            page: query.page,
            limit: query.limit,
            total: 7,
            total_pages: 1,
        },
    })
}

#[derive(Deserialize)]
pub struct RoleQuery {
    pub page: i32,
    pub limit: i32,
    pub keyword: Option<String>,
}

// 取得角色詳情
pub async fn get(Path(id): Path<String>) -> impl IntoResponse {
    // TODO: 從資料庫查詢
    Json(RoleDetailResponse {
        role: Role {
            id: id.clone(),
            code: "super_admin".to_string(),
            name: "超級管理員".to_string(),
            description: Some("擁有全部權限".to_string()),
            is_system: true,
            level: 100,
            status: true,
            created_at: "2024-01-01T00:00:00Z".to_string(),
            updated_at: "2024-01-01T00:00:00Z".to_string(),
        },
        permissions: vec![
            Permission {
                id: "perm-001".to_string(),
                code: "read:users".to_string(),
                name: "讀取用戶".to_string(),
                module: "users".to_string(),
                type_: "read".to_string(),
            },
        ],
    })
}

// 建立角色
pub async fn create(
    Json(payload): Json<CreateRoleRequest>,
) -> impl IntoResponse {
    // TODO: 寫入資料庫
    Json(serde_json::json!({
        "success": true,
        "role": {
            "id": "new-role-id",
            "code": payload.code,
            "name": payload.name,
        }
    }))
}

// 更新角色
pub async fn update(
    Path(id): Path<String>,
    Json(payload): Json<UpdateRoleRequest>,
) -> impl IntoResponse {
    // TODO: 更新資料庫
    Json(serde_json::json!({
        "success": true,
        "message": "Role updated successfully"
    }))
}

// 刪除角色
pub async fn delete(Path(id): Path<String>) -> impl IntoResponse {
    // TODO: 刪除資料庫
    Json(serde_json::json!({
        "success": true,
        "message": "Role deleted successfully"
    }))
}

// 取得角色權限
pub async fn permissions(Path(id): Path<String>) -> impl IntoResponse {
    // TODO: 查詢角色權限
    Json(serde_json::json!({
        "permissions": [
            {"id": "perm-001", "code": "read:users", "name": "讀取用戶"},
            {"id": "perm-002", "code": "write:users", "name": "新增用戶"},
        ]
    }))
}

// 更新角色權限
pub async fn update_permissions(
    Path(id): Path<String>,
    Json(payload): Json<UpdatePermissionsRequest>,
) -> impl IntoResponse {
    // TODO: 更新資料庫
    Json(serde_json::json!({
        "success": true,
        "message": "Permissions updated successfully"
    }))
}

#[derive(Deserialize)]
pub struct UpdatePermissionsRequest {
    pub permissions: Vec<String>,
}
