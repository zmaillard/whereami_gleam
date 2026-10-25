import context.{Context}
import envoy
import gleam/erlang/process
import mist
import pog
import router
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  let db_pool_name = process.new_name("db_pool")
  let assert Ok(database_url) = envoy.get("DATABASE_URL")
  let assert Ok(pog_config) = pog.url_config(db_pool_name, database_url)
  let assert Ok(_) =
    pog_config
    |> pog.pool_size(10)
    |> pog.start

  wisp.configure_logger()

  // Secrets
  let assert Ok(secret) = envoy.get("SECRET_KEY_BASE")
  let assert Ok(mapbox_token) = envoy.get("MAPBOX_TOKEN")
  let assert Ok(airnow_token) = envoy.get("AQI_API_KEY")

  let conn = pog.named_connection(db_pool_name)
  let ctx = Context(static_directory(), conn, mapbox_token, airnow_token)

  let handler = router.handler(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret)
    |> mist.new
    |> mist.port(8080)
    |> mist.start

  process.sleep_forever()
}

fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("whereami_gleam")
  priv_directory <> "/static"
}
