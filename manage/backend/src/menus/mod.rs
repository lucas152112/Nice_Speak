// manage/backend/src/menus/mod.rs

use axum::{Json, response::IntoResponse, extract::{Query, Path}};
use serde::{Deserialize, Serialize};
use sqlx::MySqlPool;

// ==================== TYPES ====================

#[derive(Serialize, sqlx::FromRow)]
pub struct MenuItem {
    pub id: String,
    pub name: String,
    pub icon: Option<String>,
    pub path: Option<String>,
    pub parent_id: Option<String>,
    pub order: i32,
    pub status: bool,
    pub created_at: chrono::DateTime<chrono::Utc>,
    pub updated_at: chrono::DateTime<chrono::Utc>,
}

#[derive(Serialize)]
pub struct MenuTreeResponse {
    pub menus: Vec<MenuNode>,
}

#[derive(Serialize)]
pub struct MenuNode {
    pub id: String,
    pub name: String,
    pub icon: Option<String>,
    pub path: Option<String>,
    pub order: i32,
    pub status: bool,
    pub children: Vec<MenuNode>,
}

#[derive(Serialize)]
pub struct MenuListResponse {
    pub menus: Vec<MenuItem>,
    pub total: i64,
}

#[derive(Deserialize)]
pub struct CreateMenuRequest {
    pub name: String,
    pub icon: Option<String>,
    pub path: Option<String>,
    pub parent_id: Option<String>,
    pub order: i32,
}

#[derive(Deserialize)]
pub struct UpdateMenuRequest {
    pub name: String,
    pub icon: Option<String>,
    pub path: Option<String>,
    pub parent_id: Option<String>,
    pub order: i32,
}

#[derive(Deserialize)]
pub struct ReorderRequest {
    pub orders: Vec<MenuOrderItem>,
}

#[derive(Deserialize)]
pub struct MenuOrderItem {
    pub id: String,
    pub order: i32,
}

// ==================== HANDLERS ====================

// 取得菜單列表 (樹狀結構)
pub async fn tree(
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    // 取得所有頂級菜單
    let root_menus: Vec<MenuItem> = sqlx::query_as!(
        MenuItem,
        r#"
        SELECT id, name, icon, path, parent_id, order, status, created_at, updated_at
        FROM menus
        WHERE parent_id IS NULL AND status = 1
        ORDER BY `order`
        "#
    )
    .fetch_all(&pool)
    .await
    .unwrap_or_default();

    // 遞迴取得子菜單
    let mut menu_nodes: Vec<MenuNode> = Vec::new();
    for menu in root_menus {
        let children = get_children(&pool, &menu.id).await;
        menu_nodes.push(MenuNode {
            id: menu.id,
            name: menu.name,
            icon: menu.icon,
            path: menu.path,
            order: menu.order,
            status: menu.status,
            children,
        });
    }

    Json(MenuTreeResponse { menus: menu_nodes })
}

// 取得菜單列表 (扁平)
pub async fn list(
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    let menus: Vec<MenuItem> = sqlx::query_as!(
        MenuItem,
        r#"
        SELECT id, name, icon, path, parent_id, order, status, created_at, updated_at
        FROM menus
        ORDER BY `order`
        "#
    )
    .fetch_all(&pool)
    .await
    .unwrap_or_default();

    Json(MenuListResponse {
        menus,
        total: menus.len() as i64,
    })
}

// 取得菜單詳情
pub async fn get(
    Path(id): Path<String>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    let menu: Option<MenuItem> = sqlx::query_as!(
        MenuItem,
        r#"
        SELECT id, name, icon, path, parent_id, order, status, created_at, updated_at
        FROM menus WHERE id = ?
        "#,
        id
    )
    .fetch_optional(&pool)
    .await
    .unwrap_or(None);

    match menu {
        Some(menu) => Json(menu),
        None => Json(serde_json::json!({
            "error": "菜單不存在",
            "code": "MENU_NOT_FOUND"
        })),
    }
}

// 建立菜單
pub async fn create(
    Json(payload): Json<CreateMenuRequest>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    let menu_id = uuid::Uuid::new_v4().to_string();
    
    // 檢查父級是否存在
    if let Some(parent_id) = &payload.parent_id {
        let exists: Option<String> = sqlx::query_scalar!(
            "SELECT id FROM menus WHERE id = ?",
            parent_id
        )
        .fetch_optional(&pool)
        .await
        .unwrap_or(None);

        if exists.is_none() {
            return Json(serde_json::json!({
                "error": "父級菜單不存在",
                "code": "PARENT_NOT_FOUND"
            }));
        }
    }

    let _ = sqlx::query!(
        r#"
        INSERT INTO menus (id, name, icon, path, parent_id, order, status)
        VALUES (?, ?, ?, ?, ?, ?, 1)
        "#,
        menu_id, payload.name, payload.icon, payload.path, payload.parent_id, payload.order
    )
    .execute(&pool)
    .await;

    Json(serde_json::json!({
        "success": true,
        "menu": {
            "id": menu_id,
            "name": payload.name,
            "path": payload.path,
            "order": payload.order,
        }
    }))
}

// 更新菜單
pub async fn update(
    Path(id): Path<String>,
    Json(payload): Json<UpdateMenuRequest>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    // 檢查菜單是否存在
    let exists: Option<String> = sqlx::query_scalar!(
        "SELECT id FROM menus WHERE id = ?",
        id
    )
    .fetch_optional(&pool)
    .await
    .unwrap_or(None);

    if exists.is_none() {
        return Json(serde_json::json!({
            "error": "菜單不存在",
            "code": "MENU_NOT_FOUND"
        }));
    }

    // 檢查父級是否存在 (避免循環引用)
    if let Some(parent_id) = &payload.parent_id {
        if parent_id == &id {
            return Json(serde_json::json!({
                "error": "不能將菜單設為自己的子菜單",
                "code": "CIRCULAR_REFERENCE"
            }));
        }

        let exists: Option<String> = sqlx::query_scalar!(
            "SELECT id FROM menus WHERE id = ?",
            parent_id
        )
        .fetch_optional(&pool)
        .await
        .unwrap_or(None);

        if exists.is_none() {
            return Json(serde_json::json!({
                "error": "父級菜單不存在",
                "code": "PARENT_NOT_FOUND"
            }));
        }
    }

    let _ = sqlx::query!(
        r#"
        UPDATE menus 
        SET name = ?, icon = ?, path = ?, parent_id = ?, `order` = ?, updated_at = NOW()
        WHERE id = ?
        "#,
        payload.name, payload.icon, payload.path, payload.parent_id, payload.order, id
    )
    .execute(&pool)
    .await;

    Json(serde_json::json!({
        "success": true,
        "message": "菜單更新成功"
    }))
}

// 刪除菜單
pub async fn delete(
    Path(id): Path<String>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    // 檢查是否有子菜單
    let children_count: i64 = sqlx::query_scalar!(
        "SELECT COUNT(*) FROM menus WHERE parent_id = ?",
        id
    )
    .fetch_one(&pool)
    .await
    .unwrap_or(Some(0))
    .unwrap_or(0);

    if children_count > 0 {
        return Json(serde_json::json!({
            "error": "請先刪除子菜單",
            "code": "HAS_CHILDREN",
            "children_count": children_count
        }));
    }

    let _ = sqlx::query!("DELETE FROM menus WHERE id = ?", id)
        .execute(&pool)
        .await;

    Json(serde_json::json!({
        "success": true,
        "message": "菜單刪除成功"
    }))
}

// 調整順序
pub async fn reorder(
    Json(payload): Json<ReorderRequest>,
    pool: axum::extract::State<sqlx::MySqlPool>,
) -> impl IntoResponse {
    for item in payload.orders {
        let _ = sqlx::query!(
            "UPDATE menus SET `order` = ?, updated_at = NOW() WHERE id = ?",
            item.order, item.id
        )
        .execute(&pool)
        .await;
    }

    Json(serde_json::json!({
        "success": true,
        "message": "菜單順序更新成功"
    }))
}

// ==================== HELPER FUNCTIONS ====================

async fn get_children(pool: &sqlx::MySqlPool, parent_id: &str) -> Vec<MenuNode> {
    let children: Vec<MenuItem> = sqlx::query_as!(
        MenuItem,
        r#"
        SELECT id, name, icon, path, parent_id, order, status, created_at, updated_at
        FROM menus
        WHERE parent_id = ? AND status = 1
        ORDER BY `order`
        "#
        parent_id
    )
    .fetch_all(pool)
    .await
    .unwrap_or_default();

    let mut nodes: Vec<MenuNode> = Vec::new();
    for child in children {
        let grandchildren = get_children(pool, &child.id).await;
        nodes.push(MenuNode {
            id: child.id,
            name: child.name,
            icon: child.icon,
            path: child.path,
            order: child.order,
            status: child.status,
            children: grandchildren,
        });
    }

    nodes
}
