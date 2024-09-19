mod get;
mod post;

use axum::{routing::get, Router};

pub fn router() -> Router {
  Router::new().route("/login", get(get::route).post(post::route))
}
