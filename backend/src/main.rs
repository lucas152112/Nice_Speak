use axum::{routing::post, Router};
use dotenv::dotenv;
use std::net::SocketAddr;
use tower_http::cors::{Any, CorsLayer};

mod config;
mod auth;
mod conversation;
mod user;
mod database;

use config::Config;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 載入環境變數
    dotenv().ok();
    env_logger::init();

    // 讀取配置
    let config = Config::from_env()?;

    // 建立資料庫連線池
    let pool = database::create_pool(&config.database_url).await?;

    // CORS 設定
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    // 建立路由
    let app = Router::new()
        .route("/health", post(|| async { "OK" }))
        .route("/api/v1/auth/register", post(auth::register))
        .route("/api/v1/auth/login", post(auth::login))
        .route("/api/v1/user/profile", post(user::get_profile))
        .layer(cors)
        .with_state(pool.clone());

    // 建立伺服器
    let addr = SocketAddr::from(([0, 0, 0, 0], config.port));
    log::info!("🚀 Server running on http://{}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await?;

    Ok(())
}
