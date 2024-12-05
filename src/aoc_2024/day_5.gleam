import gleam/bool
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub fn list_to_tuple(list: List(a)) -> Result(#(a, a), String) {
  case list {
    [x, y] -> Ok(#(x, y))
    _ -> Error("The list does not contain exactly two items")
  }
}

pub fn parse(input: String) {
  let #(orders, updates) =
    input |> string.split("\n\n") |> list_to_tuple |> result.unwrap(#("", ""))

  // parse orders
  let final_orders =
    orders
    |> string.split("\n")
    |> list.map(fn(order_pair) {
      order_pair
      |> string.split("|")
      |> list.map(int.parse)
      |> result.values
      |> list_to_tuple
      |> result.unwrap(#(0, 0))
    })

  // parse updates
  let updates_list =
    updates
    |> string.split("\n")
    |> list.map(fn(row) {
      row |> string.split(",") |> list.map(int.parse) |> result.values
    })

  #(final_orders, updates_list)
}

fn check_updates(orders: List(#(Int, Int)), update_row) {
  update_row
  |> list.combination_pairs
  |> list.all(fn(check_pair) {
    bool.negate(list.contains(orders, pair.swap(check_pair)))
  })
}

pub fn pt_1(input: #(List(#(Int, Int)), List(List(Int)))) {
  let #(orders, updates) = input
  updates
  |> list.fold(0, fn(count_valid, update_row) {
    case check_updates(orders, update_row) {
      True -> {
        count_valid + 1
      }
      False -> count_valid
    }
  })
}

pub fn pt_2(input: #(List(#(Int, Int)), List(List(Int)))) {
  todo as "part 2 not implemented"
}
