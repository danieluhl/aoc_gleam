import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import utils/grid.{type Grid}
import utils/vec.{type Vec, Vec}

pub fn parse(input: String) {
  grid.from_input(input)
}

const directions = [Vec(1, 0), Vec(-1, 0), Vec(0, 1), Vec(0, -1)]

pub type Block {
  Block(
    perimeter: Int,
    locs: Set(Vec),
    value: String,
    sides: Dict(Vec, List(Vec)),
  )
}

pub fn build_block(grid: Grid(String), loc: Vec, value: String) {
  // adds the seen locs set for this block
  continue_build_block(
    grid,
    loc,
    value,
    Block(perimeter: 0, locs: set.new(), value: value, sides: dict.new()),
  )
}

fn add_side(sides: Dict(Vec, List(Vec)), dir: Vec, side: Vec) {
  dict.upsert(sides, dir, fn(dir_sides_opt: Option(List(Vec))) {
    case dir_sides_opt {
      Some(dir_sides) -> [side, ..dir_sides]
      None -> [side]
    }
  })
}

pub fn continue_build_block(
  grid: Grid(String),
  loc: Vec,
  value: String,
  block: Block,
) {
  // we know this is a valid node, so add it to the block
  let next_block = Block(..block, locs: set.insert(block.locs, loc))
  // check each direction to see if we should add it to the block
  list.fold(directions, next_block, fn(acc_block, dir) {
    let check_loc = vec.add(loc, dir)
    // shortcut out if we already hit this location

    use <- bool.guard(
      set.contains(acc_block.locs, check_loc),
      return: acc_block,
    )

    case dict.get(grid, check_loc) {
      Error(_) -> {
        // outer perimeter of the current loc
        Block(
          ..acc_block,
          perimeter: acc_block.perimeter + 1,
          sides: add_side(acc_block.sides, dir, loc),
        )
      }
      Ok(val) if val != value -> {
        // it's part of a different block
        Block(
          ..acc_block,
          perimeter: acc_block.perimeter + 1,
          sides: add_side(acc_block.sides, dir, loc),
        )
      }
      Ok(_) -> {
        // part of this block, process it
        continue_build_block(grid, check_loc, value, acc_block)
      }
    }
  })
}

pub fn pt_1(grid: Grid(String)) {
  // build the list of blocks
  dict.fold(grid, list.new(), fn(blocks, loc, value) {
    // check if we've already included this node in out blocks
    let visited =
      list.any(blocks, fn(block: Block) { set.contains(block.locs, loc) })
    case visited {
      True -> blocks
      False -> [build_block(grid, loc, value), ..blocks]
    }
  })
  |> list.fold(0, fn(total, block) {
    total + { set.size(block.locs) * block.perimeter }
  })
}

// row_num: List(col_nums) <- sort these and find continguous count
// then fold all the row counts into a single count - the number of keys is the unique
//  sides from before

fn add_row_col(row_cols: Dict(Int, List(Int)), x: Int, y: Int) {
  dict.upsert(row_cols, x, fn(axis_opt: Option(List(Int))) {
    case axis_opt {
      Some(axis) -> [y, ..axis]
      None -> [y]
    }
  })
}

fn get_side_count(sides: Dict(Vec, List(Vec))) {
  dict.fold(sides, 0, fn(count, dir, dir_sides) {
    // if the direction is vertical, get the distinct
    //  count of y values, of horizontal then x
    let side_axis_map =
      list.fold(dir_sides, dict.new(), fn(side_coords, side) {
        case dir {
          Vec(0, _) -> add_row_col(side_coords, side.y, side.x)
          Vec(_, 0) -> add_row_col(side_coords, side.x, side.y)
          _ -> {
            io.debug("found invlaid direction")
            side_coords
          }
        }
      })

    let contiguous_side_count =
      side_axis_map
      |> dict.fold(0, fn(count, _, dim_list) {
        let sorted = list.sort(dim_list, by: int.compare)
        let contiguous =
          sorted
          |> list.fold([], fn(cont, next) {
            case cont {
              [head, ..rest] if next == head + 1 -> {
                // its contiguous, replace the prev check value
                [next, ..rest]
              }
              [head, ..rest] -> {
                // no longer contiguous, add a new check
                [next, head, ..rest]
              }
              [] -> [next]
            }
          })
        count + list.length(contiguous)
      })
    count + contiguous_side_count
  })
}

pub fn pt_2(grid: Grid(String)) {
  // build the list of blocks
  dict.fold(grid, list.new(), fn(blocks, loc, value) {
    // check if we've already included this node in out blocks
    let visited =
      list.any(blocks, fn(block: Block) { set.contains(block.locs, loc) })
    case visited {
      True -> blocks
      False -> [build_block(grid, loc, value), ..blocks]
    }
  })
  |> list.fold(0, fn(total, block) {
    let side_count = get_side_count(block.sides)
    total + { set.size(block.locs) * side_count }
  })
}
