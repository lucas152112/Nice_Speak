use axum::{routing::post, Router};
use dotenv::dotenv;
use std::net::SocketAddr;
use tower_http::cors::{Any, CorsLayer};

mod config;
mod auth;
mod conversation;
mod user;
mod database;
mod device;

use config::Config;
use axum::routing::post;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenv().ok();
    env_logger::init();
    let config = Config::from_env()?;
    let pool = database::create_pool(&config.database_url).await?;

    let cors = tower_http::cors::CorsLayer::new()
        .allow_origin(tower_http::cors::Any)
        .allow_methods(tower_http::cors::Any)
        .allow_headers(tower_http::cors::Any);

    let app = axum::Router::new()
        .route("/health", post(|| async { "OK" }))
        .route("/api/v1/auth/register", post(auth::register))
        .route("/api/v1/auth/login", post(auth::login))
        .route("/api/v1/user/profile", post(user::get_profile))
        .route("/api/v1/devices/status", post(device::check_status))
        .route("/api/v1/devices/register", post(device::register_device))
        .route("/api/v1/devices/mark-trial-used", post(device::mark_trial_used))
        .layer(cors)
        .with_state(pool.clone());

    let addr = std::net::SocketAddr::from(([0, 0, 0, 0], config.port));
    log::info!("🚀 Server running on http://{}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await?;

    Ok(())
}
