// admin_backend/src/customers/mod.rs

use axum::{Json, response::IntoResponse};
use serde::{Deserialize, Serialize};

// Customer list response
#[derive(Serialize)]
pub struct CustomerListResponse {
    pub customers: Vec<Customer>,
    pub pagination: Pagination,
}

#[derive(Serialize)]
pub struct Customer {
    pub id: String,
    pub email: String,
    pub name: String,
    pub avatar: Option<String>,
    pub subscription_tier: String,
    pub subscription_status: String,
    pub level: i32,
    pub total_practices: i32,
    pub average_score: f64,
    pub registered_at: String,
    pub last_login_at: Option<String>,
    pub is_banned: bool,
}

#[derive(Serialize)]
pub struct Pagination {
    pub page: i32,
    pub limit: i32,
    pub total: i32,
    pub total_pages: i32,
}

// List customers
pub async fn list() -> impl IntoResponse {
    // TODO: Query from database
    Json(CustomerListResponse {
        customers: vec![
            Customer {
                id: "user-001".to_string(),
                email: "user1@example.com".to_string(),
                name: "User One".to_string(),
                avatar: None,
                subscription_tier: "free".to_string(),
                subscription_status: "active".to_string(),
                level: 5,
                total_practices: 45,
                average_score: 82.5,
                registered_at: "2024-01-01T00:00:00Z".to_string(),
                last_login_at: Some("2024-01-15T10:30:00Z".to_string()),
                is_banned: false,
            }
        ],
        pagination: Pagination {
            page: 1,
            limit: 20,
            total: 100,
            total_pages: 5,
        },
    })
}

// Get customer detail
pub async fn get(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({
        "id": id,
        "email": "user1@example.com",
        "name": "User One",
        "subscription": {
            "tier": "basic",
            "status": "active",
            "started_at": "2024-01-01T00:00:00Z",
            "expires_at": "2024-02-01T00:00:00Z"
        },
        "level": 5,
        "stats": {
            "total_practices": 45,
            "average_score": 82.5,
            "total_time": 3600
        }
    }))
}

// Get customer subscriptions
pub async fn subscriptions(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({
        "subscriptions": [
            {
                "id": "sub-001",
                "tier": "basic",
                "status": "active",
                "started_at": "2024-01-01T00:00:00Z",
                "expires_at": "2024-02-01T00:00:00Z"
            }
        ]
    }))
}

// Get customer devices
pub async fn devices(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({
        "devices": [
            {
                "id": "device-001",
                "platform": "android",
                "device_id": "abc123...",
                "first_used_at": "2024-01-01T00:00:00Z",
                "last_used_at": "2024-01-15T10:30:00Z"
            }
        ]
    }))
}

// Get customer practices
pub async fn practices(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({
        "practices": [
            {
                "id": "practice-001",
                "scenario": "Code Review",
                "score": 85,
                "completed_at": "2024-01-15T10:30:00Z"
            }
        ],
        "pagination": {
            "page": 1,
            "limit": 20,
            "total": 45
        }
    }))
}
