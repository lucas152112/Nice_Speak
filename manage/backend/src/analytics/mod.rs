// manage/backend/src/analytics/mod.rs

use axum::{Json, response::IntoResponse};

pub async fn overview() -> impl IntoResponse {
    Json(serde_json::json!({
        "total_users": 1000,
        "active_users": {"dau": 500, "mau": 800},
        "revenue": {"today": 10000, "this_month": 300000}
    }))
}

pub async fn revenue() -> impl IntoResponse {
    Json(serde_json::json!({"data": []}))
}

pub async fn users() -> impl IntoResponse {
    Json(serde_json::json!({"data": []}))
}

pub async fn retention() -> impl IntoResponse {
    Json(serde_json::json!({"data": []}))
}
