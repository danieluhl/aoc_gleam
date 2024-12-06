import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import gleam/yielder

pub type Point {
  Point(x: Int, y: Int)
}

pub type Vector {
  Vector(pos: Point, dir: Point)
}

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.index_map(fn(row, y) {
    row
    |> string.to_graphemes
    |> list.index_map(fn(item, x) { #(Point(x, y), item) })
  })
  |> list.flatten
  |> dict.from_list
}

fn get_start_pos(room) {
  room
  |> dict.to_list
  |> yielder.from_list
  |> yielder.find(fn(pos) { pair.second(pos) == "^" })
  |> result.unwrap(#(Point(0, 0), "."))
}

fn get_next_direction(pos: Point) {
  case pos {
    Point(0, -1) -> Point(1, 0)
    Point(1, 0) -> Point(0, 1)
    Point(0, 1) -> Point(-1, 0)
    Point(-1, 0) -> Point(0, -1)
    _ -> {
      io.debug("bad direction")
      Point(99, 99)
    }
  }
}

fn walk(room, start: Vector, visited) {
  let next_pos = Point(start.pos.x + start.dir.x, start.pos.y + start.dir.y)
  case dict.get(room, next_pos) {
    Ok(".") | Ok("^") -> {
      walk(
        room,
        Vector(next_pos, start.dir),
        dict.insert(visited, start.pos, True),
      )
    }
    Ok("#") ->
      walk(room, Vector(start.pos, get_next_direction(start.dir)), visited)
    Ok(_) -> {
      io.debug("we hit an unknown character, this should never happen")
      dict.size(visited) + 1
    }
    Error(_) -> {
      // done
      dict.size(visited) + 1
    }
  }
}

fn check(room, start: Vector, hit_blocks: Dict(Point, Point), new_block: Point) {
  let next_pos = Point(start.pos.x + start.dir.x, start.pos.y + start.dir.y)
  case dict.get(room, next_pos) {
    Ok(".") | Ok("^") if next_pos != new_block -> {
      check(room, Vector(next_pos, start.dir), hit_blocks, new_block)
    }
    Ok(".") | Ok("^") if next_pos == new_block -> {
      // did we hit this block going in this direction?
      case dict.get(hit_blocks, next_pos) {
        Ok(x) if x == start.dir -> True
        _ -> {
          check(
            room,
            Vector(start.pos, get_next_direction(start.dir)),
            dict.insert(hit_blocks, next_pos, start.dir),
            new_block,
          )
        }
      }
    }
    Ok("#") ->
      // did we hit this block going in this direction?
      case dict.get(hit_blocks, next_pos) {
        Ok(x) if x == start.dir -> True
        _ -> {
          check(
            room,
            Vector(start.pos, get_next_direction(start.dir)),
            dict.insert(hit_blocks, next_pos, start.dir),
            new_block,
          )
        }
      }
    Ok(_) -> {
      io.debug("we hit an unknown character, this should never happen")
      False
    }
    Error(_) -> {
      // we reached the end, it didn't cause a loop
      False
    }
  }
}

pub fn pt_1(input: Dict(Point, String)) {
  let #(start_pos, _) = get_start_pos(input)
  let start_vector = Vector(start_pos, Point(0, -1))
  walk(input, start_vector, dict.new())
}

pub fn pt_2(input: Dict(Point, String)) {
  let #(start_pos, _) = get_start_pos(input)
  let start_vector = Vector(start_pos, Point(0, -1))
  input
  |> dict.filter(fn(new_block, new_block_val) {
    case new_block_val {
      "." -> check(input, start_vector, dict.new(), new_block)
      _ -> False
    }
  })
  |> dict.size
}
