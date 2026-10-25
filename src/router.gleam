import context.{type Context}
import handlers/forecast
import handlers/geocode
import handlers/home
import handlers/physical
import handlers/political
import web
import wisp.{type Request, type Response}

pub fn handler(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> home.index_handler(req, ctx)
    ["geocode"] -> geocode.geocode_handler(req, ctx)
    ["physical"] -> physical.physical_handler(req, ctx)
    ["political"] -> political.political_handler(req, ctx)
    ["forecast"] -> forecast.forecast_handler(req, ctx)
    _ -> wisp.not_found()
  }
}
