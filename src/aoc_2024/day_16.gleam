import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import utils/grid.{type Direction, type Grid}
import utils/vec.{type Vec, Vec}

pub fn parse(input: String) {
  input |> grid.from_input
}

fn get_start(grid: Grid(String)) {
  grid
  |> dict.fold(Error("none found"), fn(acc, key, val) {
    case val == "S" {
      True -> Ok(key)
      False -> acc
    }
  })
  |> result.unwrap(Vec(0, 0))
}

fn shortest_path(grid: Grid(String), start: Vec) {
  continue_shortest_path(grid, dict.new(), start, grid.Right, 0, 0)
}

fn continue_shortest_path(
  grid: Grid(String),
  visited: Grid(String),
  loc: Vec,
  direction: Direction,
  turns: Int,
  steps: Int,
) -> Int {
  // if we already visited this one, it's not a valid path, return 0
  use <- bool.guard(result.is_ok(dict.get(visited, loc)), 0)
  let val = grid |> dict.get(loc) |> result.unwrap("")
  case val {
    "." | "S" -> {
      let next_visited = visited |> dict.insert(loc, "")

      let forward_loc = loc |> vec.add(grid.direction_vector(direction))
      let forward_result =
        continue_shortest_path(
          grid,
          next_visited,
          forward_loc,
          direction,
          turns,
          steps + 1,
        )

      let #(clockwise_vec, clockwise_dir) =
        grid.get_next_clockwise_direction(direction)
      let clockwise_loc = loc |> vec.add(clockwise_vec)
      let clockwise_result =
        continue_shortest_path(
          grid,
          next_visited,
          clockwise_loc,
          clockwise_dir,
          turns + 1,
          steps + 1,
        )

      let #(counter_clockwise_vec, counter_clockwise_dir) =
        grid.get_next_counter_clockwise_direction(direction)
      let counter_clockwise_loc = loc |> vec.add(counter_clockwise_vec)
      let counter_clockwise_result =
        continue_shortest_path(
          grid,
          next_visited,
          counter_clockwise_loc,
          counter_clockwise_dir,
          turns + 1,
          steps + 1,
        )

      list.filter(
        [forward_result, counter_clockwise_result, clockwise_result],
        fn(a) { a > 0 },
      )
      |> list.sort(int.compare)
      |> list.first
      |> result.unwrap(0)
    }
    "E" -> {
      // end
      // io.debug("end")
      turns * 1000 + steps
    }
    _ -> {
      // we hit a dead end, return 0
      0
    }
  }
}

pub fn pt_1(input: Grid(String)) {
  // find the start
  // walk each direction until we find the E or dead end
  let start = get_start(input)
  io.debug(start)
  shortest_path(input, start)
}

pub fn pt_2(input: Grid(String)) {
  todo as "part 2 not implemented"
}
