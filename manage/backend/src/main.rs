// manage_backend/src/main.rs

use axum::{routing::{post, get, put, delete}, Router};
use dotenv::dotenv;
use std::net::SocketAddr;
use tower_http::cors::CorsLayer;

mod config;
mod auth;
mod users;
mod roles;
mod permissions;
mod menus;
mod customers;
mod scenarios;
mod subscriptions;
mod analytics;
mod settings;
mod audit;

use config::Config;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenv().ok();
    env_logger::init();
    
    let config = Config::from_env()?;
    
    let cors = CorsLayer::new()
        .allow_origin(tower_http::cors::Any)
        .allow_methods(tower_http::cors::Any)
        .allow_headers(tower_http::cors::Any);

    let app = Router::new()
        // Health
        .route("/health", get(|| async { "OK" }))
        // Auth
        .route("/api/admin/auth/login", post(auth::login))
        .route("/api/admin/auth/logout", post(auth::logout))
        .route("/api/admin/auth/me", get(auth::get_me))
        // Users (Admin Users)
        .route("/api/admin/users", get(users::list))
        .route("/api/admin/users", post(users::create))
        .route("/api/admin/users/:id", get(users::get))
        .route("/api/admin/users/:id", put(users::update))
        .route("/api/admin/users/:id", delete(users::delete))
        // Roles
        .route("/api/admin/roles", get(roles::list))
        .route("/api/admin/roles", post(roles::create))
        .route("/api/admin/roles/:id", get(roles::get))
        .route("/api/admin/roles/:id", put(roles::update))
        .route("/api/admin/roles/:id", delete(roles::delete))
        .route("/api/admin/roles/:id/permissions", get(roles::permissions))
        .route("/api/admin/roles/:id/permissions", put(roles::update_permissions))
        .route("/api/admin/roles/:id/menus", get(roles::menus))
        .route("/api/admin/roles/:id/menus", put(roles::update_menus))
        // Permissions
        .route("/api/admin/permissions", get(permissions::list))
        .route("/api/admin/permissions/grouped", get(permissions::grouped))
        // Menus
        .route("/api/admin/menus", get(menus::list))
        .route("/api/admin/menus", post(menus::create))
        .route("/api/admin/menus/tree", get(menus::tree))
        .route("/api/admin/menus/:id", get(menus::get))
        .route("/api/admin/menus/:id", put(menus::update))
        .route("/api/admin/menus/:id", delete(menus::delete))
        .route("/api/admin/menus/reorder", put(menus::reorder))
        // Customers
        .route("/api/admin/customers", get(customers::list))
        .route("/api/admin/customers/:id", get(customers::get))
        .route("/api/admin/customers/:id/subscriptions", get(customers::subscriptions))
        .route("/api/admin/customers/:id/devices", get(customers::devices))
        .route("/api/admin/customers/:id/practices", get(customers::practices))
        // Scenarios
        .route("/api/admin/scenarios", get(scenarios::list))
        .route("/api/admin/scenarios", post(scenarios::create))
        .route("/api/admin/scenarios/:id", get(scenarios::get))
        .route("/api/admin/scenarios/:id", put(scenarios::update))
        .route("/api/admin/scenarios/:id", delete(scenarios::delete))
        .route("/api/admin/scenarios/:id/publish", post(scenarios::publish))
        .route("/api/admin/scenarios/:id/unpublish", post(scenarios::unpublish))
        // Subscriptions
        .route("/api/admin/subscriptions/plans", get(subscriptions::plans))
        .route("/api/admin/subscriptions/plans", post(subscriptions::create_plan))
        .route("/api/admin/subscriptions/plans/:id", put(subscriptions::update_plan))
        .route("/api/admin/subscriptions/orders", get(subscriptions::orders))
        .route("/api/admin/subscriptions/orders/:id", get(subscriptions::get_order))
        .route("/api/admin/subscriptions/orders/:id/refund", post(subscriptions::refund))
        // Analytics
        .route("/api/admin/analytics/overview", get(analytics::overview))
        .route("/api/admin/analytics/revenue", get(analytics::revenue))
        .route("/api/admin/analytics/users", get(analytics::users))
        .route("/api/admin/analytics/retention", get(analytics::retention))
        // Settings
        .route("/api/admin/settings/roles", get(settings::roles))
        .route("/api/admin/settings/roles", post(settings::create_role))
        .route("/api/admin/settings/roles/:id", put(settings::update_role))
        .route("/api/admin/settings/categories", get(settings::categories))
        .route("/api/admin/settings/categories", post(settings::create_category))
        .route("/api/admin/settings/parameters", get(settings::parameters))
        .route("/api/admin/settings/parameters", put(settings::update_parameters))
        // Audit
        .route("/api/admin/audit/logs", get(audit::logs))
        .route("/api/admin/audit/login-logs", get(audit::login_logs))
        .layer(cors);

    let addr = SocketAddr::from(([0, 0, 0, 0], config.admin_port));
    log::info!("🚀 Manage Server running on http://{}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await?;

    Ok(())
}
