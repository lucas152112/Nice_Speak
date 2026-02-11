// manage/backend/src/users/mod.rs

use axum::{Json, response::IntoResponse, extract::Path};
use serde::{Deserialize, Serialize};

#[derive(Serialize)]
pub struct UserListResponse {
    pub users: Vec<UserItem>,
    pub pagination: Pagination,
}

#[derive(Serialize)]
pub struct UserItem {
    pub id: String,
    pub email: String,
    pub name: String,
    pub role: String,
    pub last_login_at: Option<String>,
}

#[derive(Serialize)]
pub struct Pagination {
    pub page: i32,
    pub limit: i32,
    pub total: i32,
    pub total_pages: i32,
}

#[derive(Deserialize)]
pub struct CreateUserRequest {
    pub email: String,
    pub password: String,
    pub name: String,
    pub role: String,
}

#[derive(Deserialize)]
pub struct UpdateUserRequest {
    pub name: String,
    pub role: String,
}

pub async fn list() -> impl IntoResponse {
    Json(UserListResponse {
        users: vec![UserItem {
            id: "admin-001".to_string(),
            email: "admin@nicespeak.app".to_string(),
            name: "Super Admin".to_string(),
            role: "super_admin".to_string(),
            last_login_at: Some("2024-01-15T10:00:00Z".to_string()),
        }],
        pagination: Pagination {
            page: 1,
            limit: 20,
            total: 1,
            total_pages: 1,
        },
    })
}

pub async fn create(Json(payload): Json<CreateUserRequest>) -> impl IntoResponse {
    Json(serde_json::json!({
        "success": true,
        "user": {
            "id": "new-user-id",
            "email": payload.email,
            "name": payload.name,
            "role": payload.role,
        }
    }))
}

pub async fn get(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({
        "id": id,
        "email": "admin@nicespeak.app",
        "name": "Super Admin",
        "role": "super_admin",
    }))
}

pub async fn update(Path(id): Path<String>, Json(_payload): Json<UpdateUserRequest>) -> impl IntoResponse {
    Json(serde_json::json!({
        "success": true,
        "message": "User updated"
    }))
}

pub async fn delete(Path(_id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({
        "success": true,
        "message": "User deleted"
    }))
}
