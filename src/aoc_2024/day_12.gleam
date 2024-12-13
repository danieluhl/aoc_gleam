import gleam/bool
import gleam/dict
import gleam/list
import gleam/set.{type Set}
import utils/grid.{type Grid}
import utils/vec.{type Vec, Vec}

pub fn parse(input: String) {
  grid.from_input(input)
}

const directions = [Vec(1, 0), Vec(-1, 0), Vec(0, 1), Vec(0, -1)]

pub type Block {
  Block(perimeter: Int, locs: Set(Vec), value: String)
}

pub fn build_block(grid: Grid, loc: Vec, value: String) {
  // adds the seen locs set for this block
  continue_build_block(
    grid,
    loc,
    value,
    Block(perimeter: 0, locs: set.new(), value: value),
  )
}

pub fn continue_build_block(grid: Grid, loc: Vec, value: String, block: Block) {
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
        Block(..acc_block, perimeter: acc_block.perimeter + 1)
      }
      Ok(val) if val != value -> {
        // it's part of a different block
        Block(..acc_block, perimeter: acc_block.perimeter + 1)
      }
      Ok(_) -> {
        // part of this block, process it
        continue_build_block(grid, check_loc, value, acc_block)
      }
    }
  })
}

pub fn pt_1(grid: Grid) {
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

pub fn pt_2(grid: Grid) {
  todo as "part 2 not implemented"
}
