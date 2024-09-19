use super::constants::API;
use crate::http::HttpClient;
use std::sync::LazyLock;
use tokio::sync::RwLock;

pub static HTTP: LazyLock<RwLock<HttpClient>> = LazyLock::new(|| {
  let client = HttpClient::new(API).unwrap();
  RwLock::new(client)
});
