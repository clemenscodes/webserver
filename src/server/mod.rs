mod address;
mod constants;
mod html;
mod http;
mod port;
mod router;

use address::get_address;
use tokio::net::TcpListener;
use tracing::{debug, error, info};

pub async fn start_server() -> Result<(), Box<dyn std::error::Error>> {
  let addr = get_address();

  debug!("Attempting to bind to address: http://{}", addr);

  let listener = match TcpListener::bind(&addr).await {
    Ok(listener) => listener,
    Err(err) => {
      error!("Failed to bind to address: {}", err);
      return Err(Box::new(err));
    }
  };

  let addr = listener.local_addr()?;

  let router = router::create_router();

  info!("Server running on http://{}", addr);

  axum::serve(listener, router.into_make_service()).await?;

  Ok(())
}
