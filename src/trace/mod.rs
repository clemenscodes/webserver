use tracing_subscriber::{
  fmt, layer::SubscriberExt, util::SubscriberInitExt, EnvFilter,
};

pub fn setup_tracing() {
  #[cfg(debug_assertions)]
  {
    let env_filter =
      EnvFilter::try_from_default_env().unwrap_or_else(|_| "debug".into());

    tracing_subscriber::registry()
      .with(env_filter)
      .with(fmt::layer())
      .init();
  }

  #[cfg(not(debug_assertions))]
  {
    let env_filter =
      EnvFilter::try_from_default_env().unwrap_or_else(|_| "info".into());

    tracing_subscriber::registry()
      .with(env_filter)
      .with(fmt::layer())
      .init();
  }
}
