import context.{type Context}
import coordinate
import error
import gleam/http.{Post}
import gleam/json
import gleam/list
import gleam/option.{type Option, Some}
import gleam/result
import location/queries
import wisp.{type Request, type Response}

type PhysicalError {
  UnableToLoadWatershed(error.DatabaseError)
}

fn result_json(
  ecoregion: Option(coordinate.Ecoregion),
  watershed: List(String),
) -> String {
  let ecoregions = case ecoregion {
    Some(eco) -> [
      #(
        "ecoregions",
        json.object([
          #(
            "level1",
            json.string(eco.level1_code <> " " <> eco.level1_description),
          ),
          #(
            "level2",
            json.string(eco.level2_code <> " " <> eco.level2_description),
          ),
          #(
            "level3",
            json.string(eco.level3_code <> " " <> eco.level3_description),
          ),
        ]),
      ),
    ]
    _ -> []
  }

  let watersheds = [
    #(
      "drainage",
      watershed |> list.map(fn(i) { json.string(i) }) |> json.preprocessed_array,
    ),
  ]

  ecoregions
  |> list.append(watersheds)
  |> json.object
  |> json.to_string
}

pub fn physical_handler(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use formdata <- wisp.require_form(req)
  use coord <- coordinate.require_coord(coordinate.from_form(formdata))

  let result = {
    let ecoregion =
      queries.ecoregion(ctx.db, coord)
      |> option.from_result

    use watershed <- result.try(
      queries.watersheds(ctx.db, coord)
      |> result.map_error(UnableToLoadWatershed),
    )

    Ok(result_json(ecoregion, watershed))
  }
  case result {
    Ok(json_res) -> {
      wisp.json_response(json_res, 200)
    }
    Error(UnableToLoadWatershed(_)) -> {
      wisp.internal_server_error()
    }
  }
}
