use crate::server::{html::HtmlTemplate, http::HTTP};
use askama::Template;
use askama_axum::IntoResponse;
use axum::{extract::Request, http::HeaderMap};
use reqwest::{header, Method};
use tracing::debug;

#[derive(Template)]
#[template(path = "pages/dashboard/get.html")]
pub struct Html {
  pub user: User,
}

#[derive(Debug)]
pub struct User {
  pub name: String,
  pub id: String,
  pub image: String,
  pub leagues: Vec<League>,
}

#[derive(Debug)]
pub struct League {
  pub id: String,
  pub name: String,
  pub creator: String,
  pub creation: String,
  pub image: String,
}

pub async fn route(request: Request) -> impl IntoResponse {
  debug!("{request:#?}");

  let cookie = request.headers().get("cookie").unwrap();

  let mut headers = HeaderMap::new();

  headers.insert(header::COOKIE, cookie.clone());

  let response = HTTP
    .read()
    .await
    .get(Method::GET, "/user/me", Some(headers.clone()))
    .await
    .unwrap();

  let user = response.value.get("user").unwrap();

  let response = HTTP
    .read()
    .await
    .get(Method::GET, "/leagues", Some(headers))
    .await
    .unwrap();

  let leagues: Vec<League> = response
    .value
    .get("leagues")
    .unwrap()
    .as_array()
    .unwrap()
    .iter()
    .map(|league| {
      let name = league.get("name").unwrap().to_string().replace("\"", "");
      let id = league.get("id").unwrap().to_string().replace("\"", "");
      let creator =
        league.get("creator").unwrap().to_string().replace("\"", "");
      let creation = league
        .get("creation")
        .unwrap()
        .to_string()
        .replace("\"", "");
      let image = league.get("ci").unwrap().to_string().replace("\"", "");
      League {
        id,
        name,
        creator,
        creation,
        image,
      }
    })
    .collect();

  let user = User {
    id: user.get("id").unwrap().to_string().replace("\"", ""),
    name: user.get("name").unwrap().to_string().replace("\"", ""),
    image: user.get("profile").unwrap().to_string().replace("\"", ""),
    leagues,
  };

  debug!("{user:#?}");

  let template = Html { user };

  HtmlTemplate(template)
}
