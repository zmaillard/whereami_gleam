import context.{type Context}
import coordinate
import gleam/http.{Post}
import gleam/result
import location/queries
import wisp.{type Request, type Response}

pub fn geocode_handler(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use formdata <- wisp.require_form(req)
  use coord <- coordinate.require_coord(coordinate.from_form(formdata))

  let result = {
    queries.reverse(ctx.db, coord)
    |> result.map(coordinate.reverse_geocode_to_json)
    |> result.replace_error(Nil)
  }

  case result {
    Ok(json_res) -> {
      wisp.json_response(json_res, 200)
    }
    Error(_) -> {
      wisp.bad_request("invalid form")
    }
  }
}
