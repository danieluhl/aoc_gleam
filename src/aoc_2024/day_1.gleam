import gleam/dict.{get}
import gleam/int.{absolute_value}
import gleam/list.{fold, group, interleave, map, sort, zip}
import gleam/result.{unwrap}
import gleam/string.{split}

fn get_two_lists(input: String) {
  let input_strs =
    input
    |> split("\n")

  let input_lists =
    input_strs
    |> map(fn(str) {
      str
      |> split("   ")
      |> map(fn(str) { str |> int.parse() |> unwrap(0) })
    })

  let combined = input_lists |> interleave()
  combined |> list.split(list.length(combined) / 2)
}

pub fn pt_1(input: String) {
  let #(first, second) = get_two_lists(input)
  let sorted_first = first |> sort(by: int.compare)
  let sorted_second = second |> sort(by: int.compare)
  let result =
    zip(sorted_first, sorted_second)
    |> fold(0, fn(acc, next) {
      let #(first, second) = next
      acc + { absolute_value(first - second) }
    })

  result
}

pub fn pt_2(input: String) {
  let #(first, second) = get_two_lists(input)
  let sorted_first = first |> sort(by: int.compare)
  let sorted_second = second |> sort(by: int.compare)
  let grouped_second = sorted_second |> group(fn(a) { a })
  let result =
    sorted_first
    |> fold(0, fn(acc, next) {
      let mult = grouped_second |> get(next) |> unwrap([]) |> list.length()

      acc + { next * mult }
    })

  result
}
