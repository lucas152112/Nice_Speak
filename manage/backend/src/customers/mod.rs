// manage/backend/src/customers/mod.rs

use axum::{Json, response::IntoResponse};

pub async fn list() -> impl IntoResponse {
    Json(serde_json::json!({
        "customers": [],
        "pagination": {"page": 1, "limit": 20, "total": 0}
    }))
}

pub async fn get(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({"id": id, "email": "user@example.com"}))
}

pub async fn subscriptions(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({"subscriptions": []}))
}

pub async fn devices(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({"devices": []}))
}

pub async fn practices(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({"practices": []}))
}
