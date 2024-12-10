import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/pair
import gleam/string

pub type Point {
  Point(x: Int, y: Int)
}

pub fn parse(input: String) {
  let grid_values =
    input
    |> string.split("\n")
    |> list.index_map(fn(row, y) {
      row
      |> string.to_graphemes
      |> list.index_map(fn(letter, x) { #(letter, Point(x, y)) })
    })
    |> list.flatten

  let letter_values =
    grid_values
    |> list.filter(fn(item) {
      let #(letter, _) = item
      letter != "."
    })
    |> list.group(fn(item) {
      let #(letter, _) = item
      letter
    })
    |> dict.map_values(fn(_, vals) {
      vals
      |> list.map(pair.second)
    })
  let grid_points = grid_values |> list.map(pair.second)
  #(grid_points, letter_values)
}

fn get_all_frequency_points(letter_values: Dict(String, List(Point))) {
  letter_values
  |> dict.values
  |> list.map(fn(points) {
    points
    |> list.combination_pairs
    |> list.flat_map(fn(point_pair) {
      let #(p1, p2) = point_pair
      // the point and the distance to the other point
      let d = Point(x: p1.x - p2.x, y: p1.y - p2.y)
      let before = Point(p2.x + { d.x * 2 }, p2.y + { d.y * 2 })
      let after = Point(p2.x - d.x, p2.y - d.y)
      [before, after]
    })
  })
  |> list.flatten
}

fn get_before_points(grid_points: List(Point), start: Point, distance: Point) {
  get_points_loop(grid_points, start, distance, [], 2, 1)
}

fn get_after_points(grid_points: List(Point), start: Point, distance: Point) {
  get_points_loop(grid_points, start, distance, [], -1, -1)
}

fn get_points_loop(
  grid_points: List(Point),
  start: Point,
  distance: Point,
  valid_points: List(Point),
  i: Int,
  step: Int,
) {
  let after = Point(start.x + { distance.x * i }, start.y + { distance.y * i })
  case list.contains(grid_points, after) {
    True ->
      get_points_loop(
        grid_points,
        start,
        distance,
        [after, ..valid_points],
        i + step,
        step,
      )
    False -> valid_points
  }
}

fn get_valid_frequency_points(
  letter_values: Dict(String, List(Point)),
  grid_points,
) {
  letter_values
  |> dict.values
  |> list.map(fn(points) {
    points
    |> list.combination_pairs
    |> list.flat_map(fn(point_pair) {
      let #(p1, p2) = point_pair
      // the point and the distance to the other point
      let d = Point(x: p1.x - p2.x, y: p1.y - p2.y)
      let before_points = get_before_points(grid_points, p2, d)
      let after_points = get_after_points(grid_points, p2, d)
      list.flatten([[p1, p2], before_points, after_points])
    })
  })
  |> list.flatten
}

pub fn pt_1(input: #(List(Point), Dict(String, List(Point)))) {
  // 381
  let #(grid_points, letter_values) = input
  let frequency_points = get_all_frequency_points(letter_values)
  frequency_points
  |> list.filter(fn(point) { list.contains(grid_points, point) })
  |> list.fold([], fn(acc, point) {
    case list.contains(acc, point) {
      True -> acc
      False -> [point, ..acc]
    }
  })
  |> list.length
}

pub fn pt_2(input: #(List(Point), Dict(String, List(Point)))) {
  let #(grid_points, letter_values) = input
  let frequency_points = get_valid_frequency_points(letter_values, grid_points)
  frequency_points
  |> list.filter(fn(point) { list.contains(grid_points, point) })
  |> list.fold([], fn(acc, point) {
    case list.contains(acc, point) {
      True -> acc
      False -> [point, ..acc]
    }
  })
  |> list.length
}
