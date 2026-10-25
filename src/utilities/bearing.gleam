pub fn bearing_from_angle(angle: Float) -> String {
  case angle {
    i if i >. 337.5 || i <=. 22.5 -> "N"
    i if i >=. 22.5 && i <=. 67.5 -> "NE"
    i if i >=. 67.5 && i <=. 112.5 -> "E"
    i if i >=. 112.5 && i <=. 157.5 -> "SE"
    i if i >=. 157.5 && i <=. 202.5 -> "S"
    i if i >=. 202.5 && i <=. 247.5 -> "SW"
    i if i >=. 247.5 && i <=. 292.5 -> "W"
    i if i >=. 292.5 && i <=. 337.5 -> "NW"
    _ -> ""
  }
}
