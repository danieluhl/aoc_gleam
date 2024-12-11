import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string

pub type Node {
  Node(x: Int, y: Int, value: Int)
}

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.index_map(fn(row, y) {
    row
    |> string.to_graphemes
    |> list.index_map(fn(val, x) {
      let int_val = int.parse(val) |> result.unwrap(0)
      Node(x, y, int_val)
    })
  })
  |> list.flatten
}

// right, left, down, up
const directions = [#(1, 0), #(-1, 0), #(0, 1), #(0, -1)]

fn valid_next_node(
  map: List(Node),
  node: Node,
  direction: #(Int, Int),
  level: Int,
) {
  let #(dx, dy) = direction
  let next_node = Node(node.x + dx, node.y + dy, level + 1)
  case list.contains(map, next_node) {
    True -> Ok(next_node)
    False -> Error("no")
  }
}

fn get_node_score(map, node: Node) {
  // map, node, level, score
  // dedupe then count
  continue_get_node_score(map, node, 0, node) |> set.from_list |> set.size
}

type Trail {
  Trail(start: Node, end: Node)
}

fn continue_get_node_score(map: List(Node), node: Node, level: Int, start: Node) {
  case level {
    9 -> [Trail(start: start, end: node)]
    _ -> {
      let next_nodes =
        directions
        |> list.filter_map(fn(dir) { valid_next_node(map, node, dir, level) })
      case next_nodes == [] {
        True -> []
        False -> {
          list.fold(next_nodes, [], fn(trails, next_node) {
            list.flatten([
              trails,
              continue_get_node_score(map, next_node, level + 1, start),
            ])
          })
        }
      }
    }
  }
}

pub fn pt_1(input: List(Node)) {
  input
  |> list.fold(0, fn(total_score, node) {
    case node.value {
      0 -> total_score + get_node_score(input, node)
      _ -> total_score
    }
  })
}

fn get_node_score2(map, node: Node) {
  // map, node, level, score
  // dedupe then count
  continue_get_node_score(map, node, 0, node) |> list.length
}

pub fn pt_2(input: List(Node)) {
  input
  |> list.fold(0, fn(total_score, node) {
    case node.value {
      0 -> total_score + get_node_score2(input, node)
      _ -> total_score
    }
  })
}
