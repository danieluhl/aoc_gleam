import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/pair
import gleam/result
import gleam/string
import gleam/yielder

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

fn get_middle(row) {
  row
  |> yielder.from_list
  |> yielder.at(list.length(row) / 2)
  |> result.unwrap(0)
}

pub fn pt_1(input: #(List(#(Int, Int)), List(List(Int)))) {
  // 4924
  let #(orders, updates) = input
  updates
  |> list.fold(0, fn(count_valid, update_row) {
    case check_updates(orders, update_row) {
      True -> {
        let middle = update_row |> get_middle
        count_valid + middle
      }
      False -> count_valid
    }
  })
}

fn order_row(update_row, orders: List(#(Int, Int))) {
  update_row
  |> list.sort(fn(a, b) {
    case list.contains(orders, #(b, a)) {
      // bad
      True -> order.Gt
      False -> order.Lt
    }
  })
}

pub fn pt_2(input: #(List(#(Int, Int)), List(List(Int)))) {
  // get out of order rows
  let #(orders, updates) = input
  let unordered =
    updates
    |> list.filter(fn(update_row) {
      bool.negate(check_updates(orders, update_row))
    })
  list.fold(unordered, 0, fn(total, row) {
    let middle = order_row(row, orders) |> get_middle
    total + middle
  })
}
