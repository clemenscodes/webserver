use std::sync::LazyLock;
use tracing::warn;

pub static PORT: LazyLock<u16> = LazyLock::new(|| {
  let port: u16 = 8000;

  std::env::var("PORT")
    .map(|port_str| {
      port_str.parse::<u16>().unwrap_or_else(|_| {
        warn!("PORT must be a valid u16, got: {}", port_str);
        port
      })
    })
    .unwrap_or(port)
});
