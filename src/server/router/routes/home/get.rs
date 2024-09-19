use crate::server::html::HtmlTemplate;
use askama::Template;
use askama_axum::IntoResponse;

#[derive(Template)]
#[template(path = "pages/home.html")]
pub struct Html {}

pub async fn route() -> impl IntoResponse {
  let template = Html {};
  HtmlTemplate(template)
}
