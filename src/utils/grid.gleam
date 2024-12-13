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
