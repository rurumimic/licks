use axum::{Json, Router, http::StatusCode, response::IntoResponse, routing::get};
use serde_json::json;

#[derive(Clone)]
pub struct AppState {}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/", get(root));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    println!("listening on {}", listener.local_addr().unwrap());

    axum::serve(listener, app).await.unwrap();
}

async fn root() -> impl IntoResponse {
    (StatusCode::OK, Json(json!({ "status": "ok" })))
}
