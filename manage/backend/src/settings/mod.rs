// manage/backend/src/settings/mod.rs

use axum::{Json, response::IntoResponse, extract::Path};

pub async fn roles() -> impl IntoResponse {
    Json(serde_json::json!({"roles": []}))
}

pub async fn create_role(Json(payload): Json<serde::Value>) -> impl IntoResponse {
    Json(serde_json::json!({"success": true}))
}

pub async fn update_role(Path(id): Path<String>, Json(_payload): Json<serde::Value>) -> impl IntoResponse {
    Json(serde_json::json!({"success": true}))
}

pub async fn categories() -> impl IntoResponse {
    Json(serde_json::json!({"categories": []}))
}

pub async fn create_category(Json(payload): Json<serde::Value>) -> impl IntoResponse {
    Json(serde_json::json!({"success": true}))
}

pub async fn parameters() -> impl IntoResponse {
    Json(serde_json::json!({
        "free_trial_days": 3,
        "evaluation_trial_days": 7,
        "max_practices_per_day": 10
    }))
}

pub async fn update_parameters(Json(payload): Json<serde::Value>) -> impl IntoResponse {
    Json(serde_json::json!({"success": true}))
}
