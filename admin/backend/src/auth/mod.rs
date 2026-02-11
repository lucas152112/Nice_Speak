// admin_backend/src/auth/mod.rs

use axum::{Json, response::IntoResponse};
use serde::{Deserialize, Serialize};
use jsonwebtoken::{encode, Header, EncodingKey};
use std::sync::Arc;
use sqlx::MySqlPool;

const JWT_EXPIRY: usize = 8 * 60 * 60; // 8 hours

#[derive(Serialize)]
pub struct AuthResponse {
    pub access_token: String,
    pub user: AdminUserResponse,
}

#[derive(Serialize)]
pub struct AdminUserResponse {
    pub id: String,
    pub email: String,
    pub name: String,
    pub role: String,
}

#[derive(Deserialize)]
pub struct LoginRequest {
    pub email: String,
    pub password: String,
}

#[derive(Serialize)]
pub struct Claims {
    pub sub: String,
    pub email: String,
    pub role: String,
    pub exp: usize,
}

// Login handler
pub async fn login(
    Json(payload): Json<LoginRequest>,
) -> impl IntoResponse {
    // TODO: Validate credentials from database
    let user_id = "admin-001".to_string();
    let role = "super_admin".to_string();
    
    let claims = Claims {
        sub: user_id.clone(),
        email: payload.email,
        role: role.clone(),
        exp: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as usize + JWT_EXPIRY,
    };
    
    let token = encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(b"your-secret-key"),
    ).unwrap();
    
    Json(AuthResponse {
        access_token: token,
        user: AdminUserResponse {
            id: user_id,
            email: payload.email,
            name: "Super Admin".to_string(),
            role,
        },
    })
}

// Logout handler
pub async fn logout() -> impl IntoResponse {
    Json(serde_json::json!({ "success": true }))
}

// Get current user
pub async fn get_me() -> impl IntoResponse {
    // TODO: Extract claims from token and return user
    Json(serde_json::json!({
        "id": "admin-001",
        "email": "admin@nicespeak.app",
        "name": "Super Admin",
        "role": "super_admin",
        "permissions": ["all"]
    }))
}
