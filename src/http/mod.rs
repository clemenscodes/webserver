use axum::http::HeaderMap;
use reqwest::{Client, Method, StatusCode, Url};
use serde::Serialize;
use serde_json::{json, Value};
use thiserror::Error;
use tracing::{debug, warn};

#[derive(Debug)]
pub struct HttpClient {
  client: Client,
  base_url: Url,
}

#[derive(Debug)]
pub struct HttpResponse {
  pub value: Value,
  pub status: StatusCode,
}

impl HttpClient {
  pub fn new(base_url: &str) -> Result<Self, HttpClientError> {
    let client = Client::new();

    let base_url = Url::parse(base_url)?;

    Ok(Self { client, base_url })
  }

  pub async fn get(
    &self,
    method: Method,
    endpoint: &str,
    headers: Option<HeaderMap>,
  ) -> Result<HttpResponse, HttpClientError> {
    self.req(method, endpoint, Some(&json!({})), headers).await
  }

  pub async fn req<T: Serialize>(
    &self,
    method: Method,
    endpoint: &str,
    payload: Option<&T>,
    headers: Option<HeaderMap>,
  ) -> Result<HttpResponse, HttpClientError> {
    let url = self.base_url.join(endpoint)?;

    let mut request = self.client.request(method, url);

    if let Some(headers) = headers {
      request = request.headers(headers)
    }

    if let Some(payload) = payload {
      request = request.json(payload);
    }

    debug!("{request:#?}");

    let response = request.send().await.unwrap();

    let status = response.status();

    let value = response
      .json::<Value>()
      .await
      .map_err(|err| {
        warn!("Failed to parse JSON: {err}");
        err
      })
      .unwrap_or_else(|_| json!({}));

    let response = HttpResponse { value, status };

    debug!("{response:#?}");

    Ok(response)
  }
}

#[derive(Error, Debug)]
pub enum HttpClientError {
  #[error("HTTP client error: {0}")]
  ReqwestError(#[from] reqwest::Error),

  #[error("URL parsing error: {0}")]
  UrlParseError(#[from] url::ParseError),
}
