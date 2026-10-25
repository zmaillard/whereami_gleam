import pog

pub type Context {
  Context(
    static_directory: String,
    db: pog.Connection,
    mapbox_token: String,
    aqi_token: String,
  )
}
