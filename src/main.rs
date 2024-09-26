mod http;
mod server;
mod trace;

#[tokio::main]
async fn main() {
  trace::setup_tracing();

  if let Err(err) = server::start_server().await {
    tracing::error!("Server faced a fatal error: {}", err);
  }
}
