import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, i) {
    line
    |> string.split("")
    |> list.index_map(fn(char, j) { #(i, j, char) })
  })
  |> list.flatten
}

fn get_next_searches(item: #(Int, Int, String)) {
  let #(row, col, letter) = item
  let next_letter = case letter {
    "X" -> Some("M")
    "M" -> Some("A")
    "A" -> Some("S")
    "S" -> None
    _ -> panic
  }
  case next_letter {
    None -> None
    Some(next) ->
      Some([
        #(row - 1, col - 1, next),
        #(row - 1, col, next),
        #(row - 1, col + 1, next),
        #(row + 1, col - 1, next),
        #(row + 1, col, next),
        #(row + 1, col + 1, next),
        #(row, col - 1, next),
        #(row, col + 1, next),
      ])
  }
}

fn is_xmas(matrix: List(#(Int, Int, String)), item: #(Int, Int, String)) {
  case matrix |> list.contains(item) {
    True -> {
      // item found!
      // get list of next items to find
      case get_next_searches(item) {
        Some(next_items) ->
          next_items
          |> list.fold(0, fn(total, next_item) {
            total + is_xmas(matrix, next_item)
          })
        // nothing left to find, we found XMAS!
        None -> {
          1
        }
      }
    }
    False -> 0
  }
}

const directions = [
  #(1, 1), #(1, 0), #(1, -1), #(-1, 1), #(-1, 0), #(-1, -1), #(0, 1), #(0, -1),
]

const search = "MAS"

fn is_valid_word(search, item, direction, matrix) {
  case search {
    [check_letter, ..rest] -> {
      let #(row, col, _) = item
      let #(row_add, col_add) = direction
      let next_item = #(row + row_add, col + col_add, check_letter)
      case list.contains(matrix, next_item) {
        True -> {
          is_valid_word(rest, next_item, direction, matrix)
        }
        False -> False
      }
    }
    [] -> True
  }
}

fn valid_word_count(item: #(Int, Int, String), matrix) {
  directions
  |> list.fold(0, fn(total, direction) {
    let search_list = string.split(search, "")
    let count = case is_valid_word(search_list, item, direction, matrix) {
      True -> 1
      False -> 0
    }
    count + total
  })
}

pub fn pt_1(matrix: List(#(Int, Int, String))) {
  // loop over each row
  // if we find an X, look in every direction for an M
  // if we find an M, look in every direction for an A
  // continue until we find XMAS, add to the count
  matrix
  |> list.fold(0, fn(total, item) {
    let search_item = #(item.0, item.1, "X")
    total + is_xmas(matrix, search_item)
  })
  matrix
  |> list.fold(0, fn(total, item) {
    let #(_, _, letter) = item
    let count = case letter {
      "X" -> valid_word_count(item, matrix)
      _ -> 0
    }
    total + count
  })
}

const diagonals = [
  #(#(1, 1), #(2, 2)), #(#(1, -1), #(2, -2)), #(#(-1, -1), #(-2, -2)),
  #(#(-1, 1), #(-2, 2)),
]

fn count_doubles(count, items) {
  case items {
    [item, ..rest] -> {
      case list.contains(rest, item) {
        True -> count_doubles(count + 1, rest)
        False -> count_doubles(count, rest)
      }
    }
    [] -> count
  }
}

pub fn pt_2(matrix: List(#(Int, Int, String))) {
  // build a list of all "MAS" on a diagonal
  let diagonal_middles =
    matrix
    |> list.fold([], fn(mas_diags, item) {
      let #(row, col, letter) = item
      case letter == "M" {
        True -> {
          let next_diags =
            diagonals
            |> list.fold([], fn(valid_diags, diag) {
              // check if the item is in the list
              let #(#(r1_add, c1_add), #(r2_add, c2_add)) = diag
              case
                list.contains(matrix, #(row + r1_add, col + c1_add, "A"))
                && list.contains(matrix, #(row + r2_add, col + c2_add, "S"))
              {
                // add the middle
                True -> [#(row + r1_add, col + c1_add, "A"), ..valid_diags]
                False -> valid_diags
              }
            })
          list.append(next_diags, mas_diags)
        }
        False -> mas_diags
      }
    })
  // find how many things in that list share a center point
  count_doubles(0, diagonal_middles)
}
