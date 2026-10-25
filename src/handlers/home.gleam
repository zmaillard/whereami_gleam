import context.{type Context}
import gleam/http.{Get}
import gleam/string_tree
import handles
import handles/ctx
import simplifile.{read}
import wisp.{type Request, type Response}

pub fn index_handler(req: Request, context: Context) -> Response {
  use <- wisp.require_method(req, Get)
  let assert Ok(index_contents) =
    read(from: "./src/components/layout.html.handles")
  let assert Ok(layout_template) = handles.prepare(index_contents)

  let assert Ok(index_contents) =
    read(from: "./src/components/index.html.handles")
  let assert Ok(content_template) = handles.prepare(index_contents)

  let assert Ok(html) =
    handles.run(
      layout_template,
      ctx.Dict([
        ctx.Prop("title", ctx.Str("Where Am I?")),
        ctx.Prop("version", ctx.Str("1.0.0")),
        ctx.Prop("mapbox_token", ctx.Str(context.mapbox_token)),
      ]),
      [#("content_template", content_template)],
    )

  let output =
    html
    |> string_tree.to_string

  wisp.html_response(output, 200)
}
