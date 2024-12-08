import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) {
  // [#(180, [18, 10])]
  input
  |> string.split("\n")
  |> list.map(fn(row) { row |> string.split(": ") })
  |> list.map(fn(check_vals) {
    case check_vals {
      [check, vals] -> #(check, string.split(vals, " "))
      _ -> {
        io.debug("invalid check vals")
        #("", [])
      }
    }
  })
  |> list.map(fn(check_pairs) {
    let #(check, vals) = check_pairs
    let parsed_check = int.parse(check) |> result.unwrap(0)
    let parsed_vals =
      vals
      |> list.map(fn(val) { int.parse(val) |> result.unwrap(0) })
    #(parsed_check, parsed_vals)
  })
}

fn has_solution(check, vals, total) {
  case check < total, vals {
    True, _ -> False
    _, [first, second, ..rest] if total == -1 -> {
      // first time through
      has_solution(check, rest, first + second)
      || has_solution(check, rest, first * second)
    }
    _, [first, ..rest] -> {
      has_solution(check, rest, total + first)
      || has_solution(check, rest, total * first)
    }
    _, [] -> total == check
  }
}

pub fn pt_1(input: List(#(Int, List(Int)))) {
  // io.debug(input)
  input
  |> list.fold(0, fn(acc, check_vals) {
    let #(check, vals) = check_vals
    case has_solution(check, vals, -1) {
      True -> acc + check
      False -> acc
    }
  })
}

fn has_solution2(check, vals, total) {
  case check < total, vals {
    True, _ -> False
    _, [first, second, ..rest] if total == -1 -> {
      // first time through
      let combo =
        int.parse(int.to_string(first) <> int.to_string(second))
        |> result.unwrap(0)
      has_solution2(check, rest, first + second)
      || has_solution2(check, rest, first * second)
      || has_solution2(check, rest, combo)
    }
    _, [first, ..rest] -> {
      let combo =
        int.parse(int.to_string(total) <> int.to_string(first))
        |> result.unwrap(0)
      has_solution2(check, rest, total + first)
      || has_solution2(check, rest, total * first)
      || has_solution2(check, rest, combo)
    }
    _, [] -> total == check
  }
}

pub fn pt_2(input: List(#(Int, List(Int)))) {
  //110_365_987_435_001
  input
  |> list.fold(0, fn(acc, check_vals) {
    let #(check, vals) = check_vals
    case has_solution2(check, vals, -1) {
      True -> {
        acc + check
      }
      False -> acc
    }
  })
}
