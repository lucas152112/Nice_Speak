// manage/backend/src/scenarios/mod.rs

use axum::{Json, response::IntoResponse};

pub async fn list() -> impl IntoResponse {
    Json(serde_json::json!({"scenarios": []}))
}

pub async fn create(Json(payload): Json<serde::Value>) -> impl IntoResponse {
    Json(serde_json::json!({"success": true}))
}

pub async fn get(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({"id": id}))
}

pub async fn update(Path(id): Path<String>, Json(_payload): Json<serde::Value>) -> impl IntoResponse {
    Json(serde_json::json!({"success": true}))
}

pub async fn delete(Path(_id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({"success": true}))
}

pub async fn publish(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({"success": true, "id": id}))
}

pub async fn unpublish(Path(id): Path<String>) -> impl IntoResponse {
    Json(serde_json::json!({"success": true, "id": id}))
}
