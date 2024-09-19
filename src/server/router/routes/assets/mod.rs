use axum::Router;
use tower_http::services::ServeDir;
use tracing::{debug, error};

pub fn router() -> Router {
  let path = std::env::var("KICKBASE_ASSETS").map_or_else(
        |_| {
            debug!("KICKBASE_ASSETS environment variable is not set. Using current directory as the fallback for assets.");
            std::env::current_dir()
                .map(|path| path.join("assets"))
                .unwrap_or_else(|err| {
                    error!("Failed to get current directory: {}", err);
                    std::process::exit(1);
                })
        },
        |path_str| {
            debug!("KICKBASE_ASSETS environment variable found, using path: {}", path_str);
            std::path::PathBuf::from(path_str)
        }
    );

  let assets = path.to_str().unwrap_or_else(|| {
    error!("Failed to convert assets path to string.");
    std::process::exit(1);
  });

  Router::new().nest_service("/assets", ServeDir::new(assets))
}
