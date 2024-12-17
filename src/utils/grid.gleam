import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import utils/vec.{type Vec, Vec}

pub type Grid =
  Dict(Vec, String)

pub fn from_input(input: String) {
  input
  |> string.split("\n")
  |> list.index_map(fn(row, y) {
    row
    |> string.to_graphemes
    |> list.index_map(fn(letter, x) { #(Vec(x, y), letter) })
  })
  |> list.flatten
  |> dict.from_list
}

pub type Direction {
  Up
  Down
  Left
  Right
}

pub fn direction_vector(dir: Direction) {
  case dir {
    Up -> Vec(0, -1)
    Right -> Vec(1, 0)
    Down -> Vec(0, 1)
    Left -> Vec(-1, 0)
  }
}

pub fn get_next_clockwise_direction(direction: Direction) {
  case direction {
    Up -> #(direction_vector(Right), Right)
    Right -> #(direction_vector(Down), Down)
    Down -> #(direction_vector(Left), Left)
    Left -> #(direction_vector(Up), Up)
  }
}

pub fn get_next_counter_clockwise_direction(direction: Direction) {
  case direction {
    Up -> #(direction_vector(Left), Left)
    Left -> #(direction_vector(Down), Down)
    Down -> #(direction_vector(Right), Right)
    Right -> #(direction_vector(Up), Up)
  }
}
