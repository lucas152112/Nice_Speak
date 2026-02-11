// manage/backend/src/permissions/mod.rs

use axum::{Json, response::IntoResponse};
use serde::{Deserialize, Serialize};

// 權限列表回應
#[derive(Serialize)]
pub struct PermissionListResponse {
    pub permissions: Vec<Permission>,
    pub grouped: Vec<PermissionGroup>,
}

#[derive(Serialize)]
pub struct Permission {
    pub id: String,
    pub code: String,
    pub name: String,
    pub module: String,
    pub type_: String,
    pub description: Option<String>,
}

#[derive(Serialize)]
pub struct PermissionGroup {
    pub module: String,
    pub permissions: Vec<Permission>,
}

// 取得權限列表
pub async fn list() -> impl IntoResponse {
    Json(PermissionListResponse {
        permissions: vec![
            Permission {
                id: "perm-001".to_string(),
                code: "read:users".to_string(),
                name: "讀取用戶".to_string(),
                module: "users".to_string(),
                type_: "read".to_string(),
                description: None,
            },
            Permission {
                id: "perm-002".to_string(),
                code: "write:users".to_string(),
                name: "新增用戶".to_string(),
                module: "users".to_string(),
                type_: "write".to_string(),
                description: None,
            },
            Permission {
                id: "perm-003".to_string(),
                code: "delete:users".to_string(),
                name: "刪除用戶".to_string(),
                module: "users".to_string(),
                type_: "delete".to_string(),
                description: None,
            },
            Permission {
                id: "perm-004".to_string(),
                code: "read:customers".to_string(),
                name: "讀取客戶".to_string(),
                module: "customers".to_string(),
                type_: "read".to_string(),
                description: None,
            },
            Permission {
                id: "perm-005".to_string(),
                code: "manage:scenarios".to_string(),
                name: "情境管理".to_string(),
                module: "scenarios".to_string(),
                type_: "write".to_string(),
                description: Some("全部情境操作".to_string()),
            },
            Permission {
                id: "perm-006".to_string(),
                code: "manage:subscriptions".to_string(),
                name: "訂閱管理".to_string(),
                module: "subscriptions".to_string(),
                type_: "write".to_string(),
                description: Some("全部訂閱操作".to_string()),
            },
            Permission {
                id: "perm-007".to_string(),
                code: "read:analytics".to_string(),
                name: "讀取分析".to_string(),
                module: "analytics".to_string(),
                type_: "read".to_string(),
                description: None,
            },
            Permission {
                id: "perm-008".to_string(),
                code: "export:analytics".to_string(),
                name: "匯出數據".to_string(),
                module: "analytics".to_string(),
                type_: "action".to_string(),
                description: None,
            },
            Permission {
                id: "perm-009".to_string(),
                code: "manage:roles".to_string(),
                name: "角色管理".to_string(),
                module: "roles".to_string(),
                type_: "write".to_string(),
                description: None,
            },
            Permission {
                id: "perm-010".to_string(),
                code: "manage:menus".to_string(),
                name: "選單管理".to_string(),
                module: "menus".to_string(),
                type_: "write".to_string(),
                description: None,
            },
        ],
        grouped: vec![
            PermissionGroup {
                module: "用戶管理".to_string(),
                permissions: vec![
                    Permission {
                        id: "perm-001".to_string(),
                        code: "read:users".to_string(),
                        name: "讀取用戶".to_string(),
                        module: "users".to_string(),
                        type_: "read".to_string(),
                        description: None,
                    },
                ],
            },
            PermissionGroup {
                module: "客戶管理".to_string(),
                permissions: vec![
                    Permission {
                        id: "perm-004".to_string(),
                        code: "read:customers".to_string(),
                        name: "讀取客戶".to_string(),
                        module: "customers".to_string(),
                        type_: "read".to_string(),
                        description: None,
                    },
                ],
            },
            PermissionGroup {
                module: "情境管理".to_string(),
                permissions: vec![
                    Permission {
                        id: "perm-005".to_string(),
                        code: "manage:scenarios".to_string(),
                        name: "情境管理".to_string(),
                        module: "scenarios".to_string(),
                        type_: "write".to_string(),
                        description: None,
                    },
                ],
            },
            PermissionGroup {
                module: "訂閱管理".to_string(),
                permissions: vec![
                    Permission {
                        id: "perm-006".to_string(),
                        code: "manage:subscriptions".to_string(),
                        name: "訂閱管理".to_string(),
                        module: "subscriptions".to_string(),
                        type_: "write".to_string(),
                        description: None,
                    },
                ],
            },
            PermissionGroup {
                module: "數據分析".to_string(),
                permissions: vec![
                    Permission {
                        id: "perm-007".to_string(),
                        code: "read:analytics".to_string(),
                        name: "讀取分析".to_string(),
                        module: "analytics".to_string(),
                        type_: "read".to_string(),
                        description: None,
                    },
                    Permission {
                        id: "perm-008".to_string(),
                        code: "export:analytics".to_string(),
                        name: "匯出數據".to_string(),
                        module: "analytics".to_string(),
                        type_: "action".to_string(),
                        description: None,
                    },
                ],
            },
            PermissionGroup {
                module: "系統管理".to_string(),
                permissions: vec![
                    Permission {
                        id: "perm-009".to_string(),
                        code: "manage:roles".to_string(),
                        name: "角色管理".to_string(),
                        module: "roles".to_string(),
                        type_: "write".to_string(),
                        description: None,
                    },
                    Permission {
                        id: "perm-010".to_string(),
                        code: "manage:menus".to_string(),
                        name: "選單管理".to_string(),
                        module: "menus".to_string(),
                        type_: "write".to_string(),
                        description: None,
                    },
                ],
            },
        ],
    })
}
