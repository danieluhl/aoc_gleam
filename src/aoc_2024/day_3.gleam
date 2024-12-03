import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

fn get_muls_for_string_part(part: String) {
  // split on "mul("
  // split that on )
  // take only the first
  // split that on ","
  // parse and take any numbers
  // multiply them all up
  part
  |> string.split("mul(")
  |> list.filter_map(fn(str) {
    let str_lists =
      str
      |> string.split(")")
      |> list.first
      |> result.unwrap("")
      |> string.split(",")
    let valid_str_lists =
      str_lists |> list.try_map(fn(num) { num |> int.parse })
    case valid_str_lists {
      Ok([first, second]) -> Ok(first * second)
      _ -> Error("invalid format")
    }
  })
}

pub fn pt_1(input: String) {
  input
  |> get_muls_for_string_part
  |> list.reduce(fn(acc, next) { acc + next })
  |> result.unwrap(0)
}

fn get_valid_string_parts(input: String) {
  // split on "don't()"
  // split that on "do()"
  // take second
  // flatten
  // map to get out nums
  // flatten
  // add
  let donts =
    input
    |> string.split("don't()")
  // move the first one to the end since it's always a do
  let fixed_donts = case donts {
    [first, ..rest] -> [string.append("do()", first), ..rest]
    _ -> []
  }
  fixed_donts
  |> list.filter_map(fn(str) {
    let strs = str |> string.split("do")
    case strs {
      [_, ..rest] -> Ok(rest)
      _ -> Error("donts")
    }
  })
  |> list.flatten
}

pub fn pt_2(input: String) {
  input
  |> get_valid_string_parts
  |> list.reduce(fn(acc, next) { string.append(acc, next) })
  |> result.unwrap("")
  |> get_muls_for_string_part
  |> list.reduce(fn(acc, next) { acc + next })
  |> result.unwrap(0)
}
