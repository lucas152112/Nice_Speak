// manage/backend/src/menus/mod.rs

use axum::{Json, response::IntoResponse, extract::Path};
use serde::{Deserialize, Serialize};

// 菜單項目
#[derive(Serialize, Deserialize)]
pub struct MenuItem {
    pub id: String,
    pub name: String,
    pub icon: Option<String>,
    pub path: Option<String>,
    pub parent_id: Option<String>,
    pub order: i32,
    pub status: bool,
    pub children: Option<Vec<MenuItem>>,
}

// 樹狀結構回應
#[derive(Serialize)]
pub struct MenuTreeResponse {
    pub menus: Vec<MenuItem>,
}

// 創建菜單請求
#[derive(Deserialize)]
pub struct CreateMenuRequest {
    pub name: String,
    pub icon: Option<String>,
    pub path: Option<String>,
    pub parent_id: Option<String>,
    pub order: i32,
}

// 更新菜單請求
#[derive(Deserialize)]
pub struct UpdateMenuRequest {
    pub name: String,
    pub icon: Option<String>,
    pub path: Option<String>,
    pub parent_id: Option<String>,
    pub order: i32,
}

// 調整順序請求
#[derive(Deserialize)]
pub struct ReorderRequest {
    pub orders: Vec<MenuOrderItem>,
}

#[derive(Deserialize)]
pub struct MenuOrderItem {
    pub id: String,
    pub order: i32,
}

// 取得菜單列表
pub async fn list() -> impl IntoResponse {
    Json(MenuTreeResponse {
        menus: vec![
            MenuItem {
                id: "menu-001".to_string(),
                name: "儀表板".to_string(),
                icon: Some("DashboardOutlined".to_string()),
                path: Some("/dashboard".to_string()),
                parent_id: None,
                order: 1,
                status: true,
                children: None,
            },
            MenuItem {
                id: "menu-002".to_string(),
                name: "客戶管理".to_string(),
                icon: Some("UserOutlined".to_string()),
                path: Some("/customers".to_string()),
                parent_id: None,
                order: 2,
                status: true,
                children: Some(vec![
                    MenuItem {
                        id: "menu-002-1".to_string(),
                        name: "客戶列表".to_string(),
                        icon: Some("TeamOutlined".to_string()),
                        path: Some("/customers".to_string()),
                        parent_id: Some("menu-002".to_string()),
                        order: 1,
                        status: true,
                        children: None,
                    },
                ]),
            },
            MenuItem {
                id: "menu-003".to_string(),
                name: "情境模板".to_string(),
                icon: Some("FileTextOutlined".to_string()),
                path: Some("/scenarios".to_string()),
                parent_id: None,
                order: 3,
                status: true,
                children: Some(vec![
                    MenuItem {
                        id: "menu-003-1".to_string(),
                        name: "模板列表".to_string(),
                        icon: Some("UnorderedListOutlined".to_string()),
                        path: Some("/scenarios".to_string()),
                        parent_id: Some("menu-003".to_string()),
                        order: 1,
                        status: true,
                        children: None,
                    },
                    MenuItem {
                        id: "menu-003-2".to_string(),
                        name: "新增模板".to_string(),
                        icon: Some("PlusOutlined".to_string()),
                        path: Some("/scenarios/create".to_string()),
                        parent_id: Some("menu-003".to_string()),
                        order: 2,
                        status: true,
                        children: None,
                    },
                ]),
            },
            MenuItem {
                id: "menu-004".to_string(),
                name: "收費管理".to_string(),
                icon: Some("DollarOutlined".to_string()),
                path: Some("/subscriptions".to_string()),
                parent_id: None,
                order: 4,
                status: true,
                children: Some(vec![
                    MenuItem {
                        id: "menu-004-1".to_string(),
                        name: "方案管理".to_string(),
                        icon: Some("TagsOutlined".to_string()),
                        path: Some("/subscriptions/plans".to_string()),
                        parent_id: Some("menu-004".to_string()),
                        order: 1,
                        status: true,
                        children: None,
                    },
                    MenuItem {
                        id: "menu-004-2".to_string(),
                        name: "訂閱列表".to_string(),
                        icon: Some("OrderedListOutlined".to_string()),
                        path: Some("/subscriptions/orders".to_string()),
                        parent_id: Some("menu-004".to_string()),
                        order: 2,
                        status: true,
                        children: None,
                    },
                ]),
            },
            MenuItem {
                id: "menu-005".to_string(),
                name: "數據分析".to_string(),
                icon: Some("BarChartOutlined".to_string()),
                path: Some("/analytics".to_string()),
                parent_id: None,
                order: 5,
                status: true,
                children: Some(vec![
                    MenuItem {
                        id: "menu-005-1".to_string(),
                        name: "總覽".to_string(),
                        icon: Some("PieChartOutlined".to_string()),
                        path: Some("/analytics/overview".to_string()),
                        parent_id: Some("menu-005".to_string()),
                        order: 1,
                        status: true,
                        children: None,
                    },
                    MenuItem {
                        id: "menu-005-2".to_string(),
                        name: "收入報表".to_string(),
                        icon: Some("RiseOutlined".to_string()),
                        path: Some("/analytics/revenue".to_string()),
                        parent_id: Some("menu-005".to_string()),
                        order: 2,
                        status: true,
                        children: None,
                    },
                ]),
            },
            MenuItem {
                id: "menu-006".to_string(),
                name: "系統設定".to_string(),
                icon: Some("SettingOutlined".to_string()),
                path: Some("/settings".to_string()),
                parent_id: None,
                order: 6,
                status: true,
                children: Some(vec![
                    MenuItem {
                        id: "menu-006-1".to_string(),
                        name: "角色管理".to_string(),
                        icon: Some("TeamOutlined".to_string()),
                        path: Some("/settings/roles".to_string()),
                        parent_id: Some("menu-006".to_string()),
                        order: 1,
                        status: true,
                        children: None,
                    },
                    MenuItem {
                        id: "menu-006-2".to_string(),
                        name: "選單管理".to_string(),
                        icon: Some("MenuOutlined".to_string()),
                        path: Some("/settings/menus".to_string()),
                        parent_id: Some("menu-006".to_string()),
                        order: 2,
                        status: true,
                        children: None,
                    },
                    MenuItem {
                        id: "menu-006-3".to_string(),
                        name: "系統參數".to_string(),
                        icon: Some("SlidersOutlined".to_string()),
                        path: Some("/settings/parameters".to_string()),
                        parent_id: Some("menu-006".to_string()),
                        order: 3,
                        status: true,
                        children: None,
                    },
                ]),
            },
            MenuItem {
                id: "menu-007".to_string(),
                name: "審計日誌".to_string(),
                icon: Some("AuditOutlined".to_string()),
                path: Some("/audit".to_string()),
                parent_id: None,
                order: 7,
                status: true,
                children: Some(vec![
                    MenuItem {
                        id: "menu-007-1".to_string(),
                        name: "操作日誌".to_string(),
                        icon: Some("FileSearchOutlined".to_string()),
                        path: Some("/audit/logs".to_string()),
                        parent_id: Some("menu-007".to_string()),
                        order: 1,
                        status: true,
                        children: None,
                    },
                    MenuItem {
                        id: "menu-007-2".to_string(),
                        name: "登入日誌".to_string(),
                        icon: Some("LoginOutlined".to_string()),
                        path: Some("/audit/logins".to_string()),
                        parent_id: Some("menu-007".to_string()),
                        order: 2,
                        status: true,
                        children: None,
                    },
                ]),
            },
        ],
    })
}

// 取得樹狀結構
pub async fn tree() -> impl IntoResponse {
    list().await
}

// 創建菜單
pub async fn create(Json(payload): Json<CreateMenuRequest>) -> impl IntoResponse {
    Json(serde_json::json!({
        "success": true,
        "menu": {
            "id": "new-menu-id",
            "name": payload.name,
            "path": payload.path,
            "order": payload.order,
        }
    }))
}

// 更新菜單
pub async fn update(Path(id): Path<String>, Json(payload): Json<UpdateMenuRequest>) -> impl IntoResponse {
    Json(serde_json::json!({
        "success": true,
        "message": "Menu updated successfully"
    }))
}

// 刪除菜單
pub async fn delete(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({
        "success": true,
        "message": "Menu deleted successfully"
    }))
}

// 調整順序
pub async fn reorder(Json(_payload): Json<ReorderRequest>) -> impl IntoResponse {
    Json(serde_json::json!({
        "success": true,
        "message": "Menus reordered successfully"
    }))
}
