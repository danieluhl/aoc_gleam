import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

// Button A: X+94, Y+34
// Button B: X+22, Y+67
// Prize: X=8400, Y=5400

pub type Point {
  Point(x: Int, y: Int)
}

pub type Game {
  Game(a: Point, b: Point, prize: Point)
}

pub fn list_to_pair(input: List(a)) -> Result(#(a, a), String) {
  case input {
    [first, second] -> Ok(#(first, second))
    _ -> Error("List does not have exactly two elements")
  }
}

pub fn parse(input: String) {
  input
  |> string.split("\n\n")
  |> list.map(fn(game_str) {
    game_str
    |> string.split("\n")
    |> list.map(fn(row) {
      row
      |> string.replace(each: "Button A: X+", with: "")
      |> string.replace(each: "Button B: X+", with: "")
      |> string.replace(each: " Y+", with: "")
      |> string.replace(each: "Prize: X=", with: "")
      |> string.replace(each: " Y=", with: "")
      |> string.split(",")
      |> list.try_map(fn(n) { int.parse(n) })
      |> result.unwrap([])
      |> list_to_pair
      |> result.unwrap(#(0, 0))
    })
  })
  |> list.map(fn(game) {
    case game {
      [#(ax, ay), #(bx, by), #(px, py)] -> {
        Game(Point(ax, ay), Point(bx, by), Point(px, py))
      }
      _ -> {
        io.debug("Invalid Game Data")
        Game(Point(0, 0), Point(0, 0), Point(0, 0))
      }
    }
  })
}

fn find_optimal_game(game: Game) {
  let ax_limit = game.prize.x / game.a.x
  let ay_limit = game.prize.y / game.a.y
  let bx_limit = game.prize.x / game.b.x
  let by_limit = game.prize.y / game.b.y
  let a_limit = case ax_limit > ay_limit {
    True -> ax_limit
    False -> ay_limit
  }
  let b_limit = case bx_limit > by_limit {
    True -> bx_limit
    False -> by_limit
  }

  continue_find_optimal_game(game, 0, 0)
}

fn continue_find_optimal_game(game: Game, a_count: Int, b_count: Int) {
  case a_count, b_count {
    101, _ -> {
      0
    }
    ax, 101 -> {
      continue_find_optimal_game(game, ax + 1, 1)
    }
    ax, bx -> {
      let ax_total = ax * game.a.x
      let ay_total = ax * game.a.y
      let bx_total = bx * game.b.x
      let by_total = bx * game.b.y
      let x_total = ax_total + bx_total
      let y_total = ay_total + by_total
      case game.prize.x, game.prize.y {
        px, py if px == x_total && py == y_total -> {
          // found optimal
          ax * 3 + bx
        }
        px, py if py < y_total || px < x_total -> {
          // we've gone over, increment x and start again
          continue_find_optimal_game(game, ax + 1, 1)
        }
        _, _ -> {
          // go to the next increment of button b
          continue_find_optimal_game(game, ax, bx + 1)
        }
      }
    }
  }
}

pub fn pt_1(input: List(Game)) {
  input
  |> list.fold(0, fn(total, game) { total + find_optimal_game(game) })
}

fn find_optimal_limit_game(game: Game) {
  let ax_limit = game.prize.x / game.a.x
  let ay_limit = game.prize.y / game.a.y
  let bx_limit = game.prize.x / game.b.x
  let by_limit = game.prize.y / game.b.y
  let a_limit = case ax_limit > ay_limit {
    True -> ax_limit
    False -> ay_limit
  }
  let b_limit = case bx_limit > by_limit {
    True -> bx_limit
    False -> by_limit
  }

  continue_find_optimal_limit_game(game, 1, b_limit, a_limit, b_limit)
}

fn continue_find_optimal_limit_game(
  game: Game,
  a_count: Int,
  b_count: Int,
  a_limit: Int,
  b_limit: Int,
) {
  case a_count, b_count {
    ax, 1 if ax > a_limit -> {
      io.debug("no game can be found")
      0
    }
    ax, 1 -> {
      continue_find_optimal_limit_game(game, ax + 1, b_limit, a_limit, b_limit)
    }
    ax, bx -> {
      let ax_total = ax * game.a.x
      let ay_total = ax * game.a.y
      let bx_total = bx * game.b.x
      let by_total = bx * game.b.y
      let x_total = ax_total + bx_total
      let y_total = ay_total + by_total
      case game.prize.x, game.prize.y {
        px, py if px == x_total && py == y_total -> {
          // found optimal
          io.debug("found")
          ax * 3 + bx
        }
        px, py if py > y_total || px > x_total -> {
          // we've gone over, increment x and start again
          continue_find_optimal_limit_game(
            game,
            ax + 1,
            b_limit,
            a_limit,
            b_limit,
          )
        }
        _, _ -> {
          // go to the next increment of button b
          continue_find_optimal_limit_game(game, ax, bx - 1, a_limit, b_limit)
        }
      }
    }
  }
}

pub fn pt_2(input: List(Game)) {
  let new_input =
    input
    |> list.map(fn(game) {
      Game(
        ..game,
        prize: Point(
          game.prize.x + 10_000_000_000_000,
          game.prize.y + 10_000_000_000_000,
        ),
      )
    })
  new_input
  |> list.fold(0, fn(total, game) {
    io.debug("found game!")
    total + find_optimal_limit_game(game)
  })
}
