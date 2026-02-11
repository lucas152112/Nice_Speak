// admin_backend/src/config.rs

use serde::Deserialize;
use std::env;

#[derive(Debug, Clone, Deserialize)]
pub struct Config {
    pub database_url: String,
    pub redis_url: String,
    pub jwt_secret: String,
    pub admin_port: u16,
    pub app_url: String,
}

impl Config {
    pub fn from_env() -> anyhow::Result<Self> {
        Ok(Self {
            database_url: env::var("ADMIN_DATABASE_URL")
                .unwrap_or_else(|_| "mysql://root:password@localhost:3306/nice_speak_admin".to_string()),
            redis_url: env::var("ADMIN_REDIS_URL")
                .unwrap_or_else(|_| "redis://localhost:6379".to_string()),
            jwt_secret: env::var("ADMIN_JWT_SECRET")
                .unwrap_or_else(|_| "admin-secret-key".to_string()),
            admin_port: env::var("ADMIN_PORT")
                .unwrap_or_else(|_| "32000".to_string())
                .parse()
                .unwrap_or(32000),
            app_url: env::var("APP_URL")
                .unwrap_or_else(|_| "http://localhost:3000".to_string()),
        })
    }
}
