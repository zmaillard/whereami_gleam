import context.{type Context}
import wisp.{type Request, type Response}

pub fn middleware(
  req: Request,
  ctx: Context,
  handler: fn(Request) -> Response,
) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use req <- wisp.csrf_known_header_protection(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)
  handler(req)
}
