// manage/backend/src/audit/mod.rs

use axum::{Json, response::IntoResponse};

pub async fn logs() -> impl IntoResponse {
    Json(serde_json::json!({"logs": []}))
}

pub async fn login_logs() -> impl IntoResponse {
    Json(serde_json::json!({"login_logs": []}))
}
