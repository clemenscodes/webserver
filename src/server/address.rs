use crate::server::port::PORT;
use std::net::SocketAddr;

pub fn get_address() -> SocketAddr {
  #[cfg(debug_assertions)]
  {
    SocketAddr::from(([127, 0, 0, 1], *PORT))
  }
  #[cfg(not(debug_assertions))]
  {
    SocketAddr::from(([0, 0, 0, 0], *PORT))
  }
}
