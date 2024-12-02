import gleam/int.{parse as to_int}
import gleam/io
import gleam/list.{map}
import gleam/option.{type Option, None, Some}
import gleam/result.{unwrap}
import gleam/string.{split}

pub fn parse(input: String) -> List(List(Int)) {
  input
  |> split("\n")
  |> map(fn(line: String) -> List(Int) {
    line
    |> split(" ")
    |> map(fn(num: String) -> Int {
      let parsed_result = to_int(num)
      unwrap(parsed_result, 0)
    })
  })
}

pub type Direction {
  Increasing
  Decreasing
  Unknown
  Invalid
}

pub fn get_direction(first, second) {
  case first - second {
    x if x < 0 && x > -4 -> Increasing
    x if x > 0 && x < 4 -> Decreasing
    _ -> Invalid
  }
}

pub fn is_safe(level: List(Int), direction: Direction) -> Bool {
  case level {
    [first, second, ..rest] -> {
      let next_direction = get_direction(first, second)
      case direction {
        x if x == next_direction -> is_safe([second, ..rest], next_direction)
        Unknown -> is_safe([second, ..rest], next_direction)
        _ -> False
      }
    }
    _ -> True
  }
}

pub fn pt_1(input: List(List(Int))) {
  input
  |> list.count(fn(level) { is_safe(level, Unknown) })
}

pub fn is_safe_with_skip(
  level level: List(Int),
  direction direction: Direction,
  skip skip: Int,
  prev prev: Option(Int),
) -> Bool {
  case level {
    [first, second, ..rest] -> {
      let next_direction = get_direction(first, second)
      case direction, next_direction {
        Increasing, Increasing ->
          is_safe_with_skip([second, ..rest], Increasing, skip, Some(first))
        Decreasing, Decreasing ->
          is_safe_with_skip([second, ..rest], Decreasing, skip, Some(first))
        Unknown, Invalid -> {
          // Unknown means we're on the first one
          case skip > 0 {
            True -> False
            False ->
              is_safe_with_skip(
                [second, ..rest],
                direction,
                skip + 1,
                Some(first),
              )
              || is_safe_with_skip(
                [first, ..rest],
                direction,
                skip + 1,
                Some(second),
              )
          }
        }
        Unknown, _ ->
          is_safe_with_skip([second, ..rest], next_direction, skip, Some(first))
        _, _ ->
          case skip > 0 {
            True -> False
            // skip one
            False ->
              // remove the second one and try again
              is_safe_with_skip(
                [first, ..rest],
                direction,
                skip + 1,
                Some(first),
              )
              || {
                case prev {
                  Some(x) ->
                    // since we're not on the first one but removing the first item
                    // we need to patch back in the previous value to see if it's good
                    // with the next
                    is_safe_with_skip(
                      [x, second, ..rest],
                      direction,
                      skip + 1,
                      Some(second),
                    )
                  None ->
                    is_safe_with_skip(
                      [second, ..rest],
                      direction,
                      skip + 1,
                      Some(second),
                    )
                }
              }
          }
      }
    }
    _ -> True
  }
}

pub fn pt_2(input: List(List(Int))) {
  input
  |> list.count(fn(level) {
    is_safe_with_skip(level, direction: Unknown, skip: 0, prev: None)
  })
  // 547 is too high
  // 515 is not correct, didn't say higher or lower
  // 514 is also not correct, but feels like we're close
  // input
  // |> list.map(fn(level) {
  //   is_safe_with_skip(level, direction: Unknown, skip: 0)
  // })
  // |> io.debug
}
