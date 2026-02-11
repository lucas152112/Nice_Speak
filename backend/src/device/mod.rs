// src/device/mod.rs

use axum::{routing::{post, get}, Router, Json, extract::Path};
use serde::{Deserialize, Serialize};
use sqlx::{MySqlPool, Row};
use std::sync::Arc;

pub fn router(pool: Arc<MySqlPool>) -> Router {
    Router::new()
        .route("/api/v1/devices/status", post(check_status))
        .route("/api/v1/devices/register", post(register_device))
        .route("/api/v1/devices/mark-trial-used", post(mark_trial_used))
        .with_state(pool)
}

/// 設備註冊請求
#[derive(Deserialize)]
pub struct RegisterDeviceRequest {
    device_id: String,
    platform: String,
    fcm_token: Option<String>,
}

/// 設備狀態回應
#[derive(Serialize)]
pub struct DeviceStatusResponse {
    device_id: String,
    has_used_free_trial: bool,
    is_banned: bool,
    registered_at: Option<String>,
    last_used_at: Option<String>,
}

/// 檢查設備狀態
async fn check_status(
    Json(payload): Json<RegisterDeviceRequest>,
) -> Json<DeviceStatusResponse> {
    // TODO: 從資料庫查詢設備狀態
    Json(DeviceStatusResponse {
        device_id: payload.device_id,
        has_used_free_trial: false,
        is_banned: false,
        registered_at: None,
        last_used_at: None,
    })
}

/// 註冊設備
async fn register_device(
    Json(payload): Json<RegisterDeviceRequest>,
) -> Json<serde_json::Value> {
    // TODO: 寫入資料庫
    Json(serde_json::json!({
        "success": true,
        "device_id": payload.device_id,
        "message": "Device registered successfully"
    }))
}

/// 標記設備已使用免費試用
async fn mark_trial_used(
    Path(device_id): Path<String>,
) -> Json<serde_json::Value> {
    // TODO: 更新資料庫
    Json(serde_json::json!({
        "success": true,
        "device_id": device_id,
        "message": "Device marked as trial used"
    }))
}
