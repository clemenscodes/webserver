use askama::Template;
use axum::{
  http::StatusCode,
  response::{Html, IntoResponse, Response},
};
use tracing::error;

pub struct HtmlTemplate<T>(pub T);

impl<T> IntoResponse for HtmlTemplate<T>
where
  T: Template,
{
  fn into_response(self) -> Response {
    match self.0.render() {
      Ok(html) => Html(html).into_response(),
      Err(err) => {
        error!("Failed to render template: {}", err);
        let code = StatusCode::INTERNAL_SERVER_ERROR;
        let message = "Internal Server Error".to_string();
        (code, message).into_response()
      }
    }
  }
}
