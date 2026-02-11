// manage/backend/src/subscriptions/mod.rs

use axum::{Json, response::IntoResponse};

pub async fn plans() -> impl IntoResponse {
    Json(serde_json::json!({"plans": []}))
}

pub async fn create_plan(Json(payload): Json<serde::Value>) -> impl IntoResponse {
    Json(serde_json::json!({"success": true}))
}

pub async fn update_plan(Path(id): Path<String>, Json(_payload): Json<serde::Value>) -> impl IntoResponse {
    Json(serde_json::json!({"success": true}))
}

pub async fn orders() -> impl IntoResponse {
    Json(serde_json::json!({"orders": []}))
}

pub async fn get_order(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({"id": id}))
}

pub async fn refund(Path(id): Path<String>, Json(_payload): Json<serde::Value>) -> impl IntoResponse {
    Json(serde_json::json!({"success": true}))
}
