import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import rememo/memo

pub fn parse(input: String) {
  input |> string.split(" ")
}

fn continue_blink(vals: List(String), new_vals: List(String)) {
  case vals {
    [val, ..rest] -> {
      let should_divide = string.length(val) % 2 == 0
      case val {
        "0" -> {
          continue_blink(rest, list.append(new_vals, ["1"]))
        }
        str if should_divide -> {
          let len = string.length(str)
          let mid_index = len / 2
          let first = string.slice(str, 0, mid_index)
          let last =
            string.slice(str, mid_index, len)
            |> int.parse
            |> result.unwrap(0)
            |> int.to_string
          continue_blink(rest, list.append(new_vals, [first, last]))
        }
        _ -> {
          // multiply by 99
          let int_val = val |> int.parse |> result.unwrap(0)
          let next_val = int_val * 2024 |> int.to_string
          continue_blink(rest, list.append(new_vals, [next_val]))
        }
      }
    }
    [] -> new_vals
  }
}

fn blink(vals: List(String)) {
  continue_blink(vals, [])
}

pub fn pt_1(input: List(String)) {
  io.debug("part 1")
  // let blinks = 25
  // list.range(0, blinks - 1)
  // |> list.fold(input, fn(acc, i) {
  //   io.debug("blinking")
  //   io.debug(i)
  //   blink(acc)
  // })
  // |> list.length
}

// fn blink2(nums: List(Int)) {
//   continue_blink2(nums: List(Int), depth: 25)
// }

// fn continue_blink2(nums: List(Int), depth: Int) {
//   case depth {
//       0 -> 1
//       _ -> {
//         case nums {
//             [first, ..rest] -> {

//               }
//               [] -> 0
//           }
//       }
//     }
// }

fn int_continue_blink(vals: List(Int), new_vals: List(Int)) {
  case vals {
    [val, ..rest] -> {
      let str_val = val |> int.to_string
      let len = str_val |> string.length
      let should_divide = len % 2 == 0
      case val {
        0 -> {
          int_continue_blink(rest, list.append(new_vals, [1]))
        }
        _ if should_divide -> {
          let mid_index = len / 2
          let first =
            string.slice(str_val, 0, mid_index) |> int.parse |> result.unwrap(0)
          let last =
            string.slice(str_val, mid_index, len)
            |> int.parse
            |> result.unwrap(0)
          int_continue_blink(rest, list.append(new_vals, [first, last]))
        }
        _ -> {
          let next_val = val * 2024
          int_continue_blink(rest, list.append(new_vals, [next_val]))
        }
      }
    }
    [] -> new_vals
  }
}

fn int_blink(vals: List(Int)) {
  int_continue_blink(vals, [])
}

fn n_blinks(val: Int, blinks: Int) {
  list.range(0, blinks - 1)
  |> list.fold([val], fn(acc, _) { int_blink(acc) })
}

fn cache_blink(val: Int, blinks: Int, cache) {
  case blinks {
    0 -> 1
    _ -> {
      use <- memo.memoize(cache, #(val, blinks))
      let next_vals = int_blink([val])
      list.fold(next_vals, 0, fn(acc, next) {
        acc + cache_blink(next, blinks - 1, cache)
      })
    }
  }
}

pub fn pt_2(input: List(String)) {
  let vals = list.map(input, fn(str) { int.parse(str) |> result.unwrap(0) })

  use cache <- memo.create()
  vals
  |> list.fold(0, fn(acc, val) { acc + cache_blink(val, 75, cache) })
}
