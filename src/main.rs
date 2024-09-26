mod http;
mod server;
mod trace;

#[tokio::main]
async fn main() {
  trace::setup_tracing();

  if let Err(err) = server::start_server().await {
    tracing::error!("Server encountered a fatal error: {}", err);
  }
}
