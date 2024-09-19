use crate::server::{html::HtmlTemplate, http::HTTP};
use askama::Template;
use askama_axum::IntoResponse;
use axum::{http::HeaderValue, response::Response, Json};
use reqwest::{header, Method};
use serde::Deserialize;
use std::collections::HashMap;

#[derive(Template)]
#[template(path = "pages/login/post.html")]
pub struct Html {
  pub message: String,
}

#[derive(Deserialize, Debug)]
pub struct Payload {
  pub email: String,
  pub password: String,
}

pub async fn route(Json(payload): Json<Payload>) -> Response {
  let mut map = HashMap::new();

  map.insert("email", payload.email);
  map.insert("password", payload.password);

  let response = HTTP
    .read()
    .await
    .req(Method::POST, "/user/login", Some(&map), None)
    .await
    .unwrap();

  let status = response.status;

  if !status.is_success() {
    let template = Html {
      message: String::from("Invalid credentials"),
    };

    return HtmlTemplate(template).into_response();
  }

  let token = response
    .value
    .get("token")
    .map(|token| token.to_string().replace("\"", ""))
    .unwrap();

  let cookie = format!("kkstrauth={token}");

  let template = Html {
    message: String::from("Logged in"),
  };

  let mut html = HtmlTemplate(template).into_response();

  html
    .headers_mut()
    .insert(header::SET_COOKIE, HeaderValue::from_str(&cookie).unwrap());

  html
    .headers_mut()
    .insert("HX-Redirect", HeaderValue::from_str("/dashboard").unwrap());

  html
}
