import gleeunit
import location/queries

pub fn main() {
  gleeunit.main()
}

pub fn build_hucs_test() {
  let raw_items = [
    "North Slough-Boise River",
    "Mill Slough-Boise River",
    "Outlet Boise River",
    "Homestead Gulch-Snake River",
    "Ashlock Gulch-Snake River",
    "Plummer Slough-Snake River",
    "Buttermilk Gulch-Snake River",
    "Bridge Gulch-Snake River",
    "Road Gulch-Snake River",
    "Grouse Creek-Snake River",
    "Ryan Gulch-Snake River",
    "Morgan Creek-Snake River",
    "Dennett Creek-Snake River",
    "Raft Creek-Snake River",
    "Jackson Gulch-Snake River",
    "Cottonwood Creek-Snake River",
    "Dukes Creek-Snake River",
    "Oxbow Dam-Snake River",
    "Herman Creek-Snake River",
    "McGraw Creek-Snake River",
    "Hells Canyon Dam-Snake River",
    "Butte Creek-Snake River",
    "Sluice Creek-Snake River",
    "Sand Creek-Snake River",
    "Salt Creek-Snake River",
    "Corral Creek-Snake River",
    "Kurry Creek-Snake River",
    "Big Canyon Creek-Snake River",
    "Somers Creek-Snake River",
    "Dry Creek-Snake River",
    "Dug Bar-Snake River",
    "Eureka Bar-Snake River",
    "Jim Creek-Snake River",
    "Cache Creek-Snake River",
    "Corral Creek-Snake River",
    "Fisher Gulch-Snake River",
    "Redbird Creek-Snake River",
    "Asotin Dam-Snake River",
    "Dry Creek-Snake River",
    "Yakawawa Canyon-Snake River",
    "Wawawai Canyon-Snake River",
    "Long Hollow-Snake River",
    "Town of Central Ferry-Snake River",
    "Flagpole Gulch-Snake River",
    "Choke Cherry Spring-Snake River",
    "Lyons Dam-Snake River",
    "Skookum Canyon-Snake River",
    "Burr Canyon-Snake River",
    "Lake Sacajawea-Snake River",
    "Dalton Lake-Snake River",
    "Snake River",
    "City of Kennewick-Columbia River",
    "Burbank Slough-Lake Wallula",
    "Lake Wallula",
    "Spring Gulch-Lake Wallula",
    "Spaw Canyon-Lake Wallula",
    "Cold Springs Wash-Lake Wallula",
    "McNary Lock and Dam-Lake Wallula",
    "Lake Umatilla",
    "Paterson Slough-Lake Umatilla",
    "McCormack Slough-Lake Umatilla",
    "Whitcomb Island-Lake Umatilla",
    "Crow Butte-Lake Umatilla",
    "Threemile Canyon-Lake Umatilla",
    "Hurlburt Flats-Lake Umatilla",
    "Old Lady Canyon-Lake Umatilla",
    "Philippi Canyon-Lake Umatilla",
    "John Day Dam-Lake Umatilla",
    "Hells Gate Canyon-Columbia River",
    "Threemile Creek-Columbia River",
    "Town of Murdock-Columbia River",
    "Rowena Creek-Columbia River",
    "Grays Creek-Columbia River",
    "Carson Creek-Columbia River",
    "Tanner Creek-Columbia River",
    "Woodard Creek-Columbia River",
    "Bridal Veil Creek-Columbia River",
    "Latourell Creek-Columbia River",
    "Hayden Island-Columbia River",
    "Cathlamet Channel-Columbia River",
    "Baker Bay-Columbia River",
  ]

  let expected = [
    "Boise River",
    "Outlet Boise River",
    "Snake River",
    "Columbia River",
    "Lake Wallula",
    "Lake Umatilla",
    "Columbia River",
  ]

  assert queries.clean_watershed_items(raw_items) == expected
}

pub fn clean_watershed_items_empty_test() {
  assert queries.clean_watershed_items([]) == []
}

pub fn clean_watershed_items_no_suffix_test() {
  assert queries.clean_watershed_items(["Lake Wallula"]) == ["Lake Wallula"]
}

pub fn clean_watershed_items_collapses_consecutive_duplicates_test() {
  assert queries.clean_watershed_items([
      "Dry Creek-Snake River",
      "Dry Creek-Snake River",
      "Snake River",
    ])
    == ["Snake River"]
}
