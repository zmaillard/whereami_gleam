import gleam/int
import gleam/string
import gleam/time/calendar.{Date}
import gleam/time/duration
import gleam/time/timestamp

pub fn get_tide_date() -> #(String, String) {
  let now = timestamp.system_time()
  let offset = calendar.local_offset()

  let #(Date(year, month, day), _) = timestamp.to_calendar(now, offset)

  let start =
    int.to_string(year)
    <> int.to_string(calendar.month_to_int(month))
    |> string.pad_start(to: 2, with: "0")
    <> int.to_string(day) |> string.pad_start(to: 2, with: "0")

  let tomorrow = now |> timestamp.add(duration.hours(24))
  let #(Date(year, month, day), _) = timestamp.to_calendar(tomorrow, offset)
  let end =
    int.to_string(year)
    <> int.to_string(calendar.month_to_int(month))
    |> string.pad_start(to: 2, with: "0")
    <> int.to_string(day) |> string.pad_start(to: 2, with: "0")

  #(start, end)
}
