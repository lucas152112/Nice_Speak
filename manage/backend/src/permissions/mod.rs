// manage/backend/src/permissions/mod.rs

use axum::{Json, response::IntoResponse, extract::{Query, Path}};
use serde::{Deserialize, Serialize};
use sqlx::MySqlPool;

// ==================== TYPES ====================

#[derive(Serialize, sqlx::FromRow)]
pub struct Permission {
    pub id: String,
    pub code: String,
    pub name: String,
    pub module: String,
    pub type_: String,
    pub description: Option<String>,
    pub status: bool,
}

#[derive(Serialize)]
pub struct PermissionListResponse {
    pub permissions: Vec<Permission>,
    pub total: i64,
}

#[derive(Serialize)]
pub struct PermissionGroup {
    pub module: String,
    pub display_name: String,
    pub permissions: Vec<Permission>,
}

#[derive(Serialize)]
pub struct PermissionGroupedResponse {
    pub groups: Vec<PermissionGroup>,
    pub total: i64,
}

#[derive(Deserialize)]
pub struct PermissionQuery {
    pub module: Option<String>,
    pub type_: Option<String>,
    pub keyword: Option<String>,
}

// 模組顯示名稱對照
const MODULE_NAMES: &[(&str, &str)] = &[
    ("users", "用戶管理"),
    ("customers", "客戶管理"),
    ("scenarios", "情境管理"),
    ("subscriptions", "訂閱管理"),
    ("analytics", "數據分析"),
    ("settings", "系統設定"),
    ("audit", "審計日誌"),
    ("roles", "角色管理"),
    ("permissions", "權限管理"),
    ("menus", "選單管理"),
];

// 類型顯示名稱對照
const TYPE_NAMES: &[(&str, &str)] = &[
    ("read", "讀取"),
    ("write", "寫入"),
    ("delete", "刪除"),
    ("action", "操作"),
];

// ==================== HANDLERS ====================

// 取得權限列表
pub async fn list(
    Query(query): Query<PermissionQuery>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    let conditions = build_conditions(&query);
    
    let sql = format!(
        r#"
        SELECT id, code, name, module, type as type_, description, status
        FROM permissions
        WHERE {}
        ORDER BY module, type_, name
        "#,
        conditions
    );

    let permissions: Vec<Permission> = sqlx::query_as(&sql)
        .fetch_all(&pool)
        .await
        .unwrap_or_default();

    Json(PermissionListResponse {
        permissions,
        total: permissions.len() as i64,
    })
}

// 取得分組權限
pub async fn grouped(
    Query(_query): Query<PermissionQuery>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    let permissions: Vec<Permission> = sqlx::query_as!(
        Permission,
        r#"
        SELECT id, code, name, module, type as type_, description, status
        FROM permissions
        ORDER BY module, type_, name
        "#
    )
    .fetch_all(&pool)
    .await
    .unwrap_or_default();

    // 按模組分組
    let mut groups: Vec<PermissionGroup> = Vec::new();
    let mut current_module = String::new();
    let mut current_group: Option<PermissionGroup> = None;

    for perm in permissions {
        if perm.module != current_module {
            if let Some(group) = current_group.take() {
                groups.push(group);
            }
            current_module = perm.module.clone();
            current_group = Some(PermissionGroup {
                module: perm.module.clone(),
                display_name: get_module_name(&perm.module),
                permissions: Vec::new(),
            });
        }
        if let Some(group) = current_group.as_mut() {
            group.permissions.push(perm);
        }
    }

    // 加入最後一個群組
    if let Some(group) = current_group {
        groups.push(group);
    }

    Json(PermissionGroupedResponse {
        groups,
        total: permissions.len() as i64,
    })
}

// 取得權限詳情
pub async fn get(
    Path(id): Path<String>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    let permission: Option<Permission> = sqlx::query_as!(
        Permission,
        r#"
        SELECT id, code, name, module, type as type_, description, status
        FROM permissions WHERE id = ?
        "#,
        id
    )
    .fetch_optional(&pool)
    .await
    .unwrap_or(None);

    match permission {
        Some(perm) => Json(perm),
        None => Json(serde_json::json!({
            "error": "權限不存在",
            "code": "PERMISSION_NOT_FOUND"
        })),
    }
}

// 建立權限
pub async fn create(
    Json(payload): Json<CreatePermissionRequest>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    // 檢查權限代碼是否已存在
    let exists: Option<String> = sqlx::query_scalar!(
        "SELECT id FROM permissions WHERE code = ?",
        payload.code
    )
    .fetch_optional(&pool)
    .await
    .unwrap_or(None);

    if exists.is_some() {
        return Json(serde_json::json!({
            "error": "權限代碼已存在",
            "code": "CODE_EXISTS"
        }));
    }

    let perm_id = uuid::Uuid::new_v4().to_string();
    let _ = sqlx::query!(
        r#"
        INSERT INTO permissions (id, code, name, module, type, description, status)
        VALUES (?, ?, ?, ?, ?, ?, 1)
        "#,
        perm_id, payload.code, payload.name, payload.module, payload.type, payload.description
    )
    .execute(&pool)
    .await;

    Json(serde_json::json!({
        "success": true,
        "permission": {
            "id": perm_id,
            "code": payload.code,
            "name": payload.name,
        }
    }))
}

// 更新權限
pub async fn update(
    Path(id): Path<String>,
    Json(payload): Json<UpdatePermissionRequest>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    let _ = sqlx::query!(
        r#"
        UPDATE permissions 
        SET name = ?, module = ?, type = ?, description = ?, updated_at = NOW()
        WHERE id = ?
        "#,
        payload.name, payload.module, payload.type, payload.description, id
    )
    .execute(&pool)
    .await;

    Json(serde_json::json!({
        "success": true,
        "message": "權限更新成功"
    }))
}

// 刪除權限
pub async fn delete(
    Path(id): Path<String>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    let _ = sqlx::query!("DELETE FROM permissions WHERE id = ?", id)
        .execute(&pool)
        .await;

    Json(serde_json::json!({
        "success": true,
        "message": "權限刪除成功"
    }))
}

// ==================== HELPER FUNCTIONS ====================

fn build_conditions(query: &PermissionQuery) -> String {
    let mut conditions = vec!["1=1".to_string()];
    
    if let Some(module) = &query.module {
        conditions.push(format!("module = '{}'", module));
    }
    if let Some(type_) = &query.type_ {
        conditions.push(format!("type = '{}'", type_));
    }
    if let Some(keyword) = &query.keyword {
        conditions.push(format!(
            "(name LIKE CONCAT('%', '{}', '%') OR code LIKE CONCAT('%', '{}', '%'))",
            keyword, keyword
        ));
    }
    
    conditions.join(" AND ")
}

fn get_module_name(module: &str) -> String {
    MODULE_NAMES.iter()
        .find(|(m, _)| *m == module)
        .map(|(_, name)| *name)
        .unwrap_or(module)
        .to_string()
}

// ==================== REQUEST TYPES ====================

#[derive(Deserialize)]
pub struct CreatePermissionRequest {
    pub code: String,
    pub name: String,
    pub module: String,
    pub type_: String,
    pub description: Option<String>,
}

#[derive(Deserialize)]
pub struct UpdatePermissionRequest {
    pub name: String,
    pub module: String,
    pub type_: String,
    pub description: Option<String>,
}
