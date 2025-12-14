import gleam/list
import gleam/string

pub type Node {
  Node(val: String, instructions: String)
}

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(row) { row |> string.to_graphemes })
}

fn get_directions_to_number() {
  todo
}

pub fn pt_1(input: String) {
  todo as "part 1 not implemented"
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
