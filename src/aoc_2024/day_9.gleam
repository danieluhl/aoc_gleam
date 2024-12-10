import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub type Block {
  Block(id: Int, size: Int)
}

pub fn parse(input: String) {
  input
  |> string.to_graphemes
  |> list.index_map(fn(letter, i) {
    let size = int.parse(letter) |> result.unwrap(0)
    case i % 2 == 0 {
      // block
      True -> Block(id: i / 2, size: size)
      // free space
      False -> Block(id: -1, size: size)
    }
  })
  |> deque.from_list()
}

fn get_checksum_loop(blocks: Deque(Block), index: Int, checksum: Int) {
  case deque.length(blocks) {
    0 -> checksum
    1 -> {
      let #(front, back_rest) =
        deque.pop_front(blocks) |> result.unwrap(#(Block(0, 0), deque.new()))

      case front.id, front.size {
        // if the last item only has spaces, we're done
        -1, _ -> checksum
        _, size if size == 0 -> checksum
        id, size -> {
          let next_blocks = deque.push_front(back_rest, Block(id, size - 1))
          get_checksum_loop(next_blocks, index + 1, checksum + { id * index })
        }
      }
    }
    _ -> {
      let #(front, back_rest) =
        deque.pop_front(blocks) |> result.unwrap(#(Block(0, 0), deque.new()))
      let #(back, front_rest) =
        deque.pop_back(back_rest) |> result.unwrap(#(Block(0, 0), deque.new()))

      case front.id, front.size {
        // if the last item only has spaces, we're done
        _, 0 -> {
          // end of the front
          let next_blocks = deque.push_back(front_rest, back)
          get_checksum_loop(next_blocks, index, checksum)
        }
        -1, size -> {
          // get from back
          case back.id, back.size {
            _, 0 | -1, _ -> {
              // end of the back or back is block of blank space
              let next_blocks = deque.push_front(front_rest, front)
              get_checksum_loop(next_blocks, index, checksum)
            }
            back_id, back_size -> {
              // we have a valid back and gap in front, take from both
              let blocks_with_front =
                deque.push_front(front_rest, Block(-1, size - 1))
              let next_blocks =
                deque.push_back(
                  blocks_with_front,
                  Block(back_id, back_size - 1),
                )
              get_checksum_loop(
                next_blocks,
                index + 1,
                checksum + { back_id * index },
              )
            }
          }
        }
        _, size if size == 0 -> checksum
        // use from front until we get to a space
        id, size -> {
          let next_blocks = deque.push_front(back_rest, Block(id, size - 1))
          get_checksum_loop(next_blocks, index + 1, checksum + { id * index })
        }
      }
    }
  }
}

pub fn pt_1(input: Deque(Block)) {
  get_checksum_loop(input, 0, 0)
}

fn get_largest_to_fill(blocks: List(Block), size: Int, processed_ids: List(Int)) {
  blocks
  |> list.reverse
  |> list.find(fn(block) {
    case list.contains(processed_ids, block.id) {
      True -> False
      False -> {
        case block.id, block.size {
          -1, _ -> False
          _, large_size if large_size <= size -> {
            True
          }
          _, _ -> False
        }
      }
    }
  })
}

fn process_block(block: Block, index: Int, checksum: Int) {
  case block.id, block.size {
    -1, _ -> checksum
    id, size -> {
      list.fold(
        list.range(from: index, to: index + size - 1),
        checksum,
        fn(acc, add_num) { acc + { add_num * id } },
      )
    }
  }
}

fn get_checksum2(
  blocks: List(Block),
  processed_ids: List(Int),
  index: Int,
  checksum: Int,
) {
  io.debug(list.length(blocks))
  case blocks {
    [first, ..rest] -> {
      case first.id, first.size {
        _, 0 -> get_checksum2(rest, processed_ids, index, checksum)
        0, size -> get_checksum2(rest, processed_ids, index + size, checksum)
        -1, size -> {
          // get from back
          case get_largest_to_fill(rest, size, processed_ids) {
            Ok(back_block) -> {
              // process from front
              let next_checksum = process_block(back_block, index, checksum)
              let next_first = Block(-1, size - back_block.size)
              get_checksum2(
                [next_first, ..rest],
                [back_block.id, ..processed_ids],
                index + back_block.size,
                next_checksum,
              )
            }
            Error(_) -> {
              // don't add to checksum because these are gaps that cannot be filled
              get_checksum2(rest, processed_ids, index + size, checksum)
            }
          }
        }
        id, size -> {
          case list.contains(processed_ids, id) {
            True -> {
              get_checksum2(rest, processed_ids, index + size, checksum)
            }
            False -> {
              // process from front
              let next_checksum = process_block(first, index, checksum)
              get_checksum2(
                rest,
                [first.id, ..processed_ids],
                index + size,
                next_checksum,
              )
            }
          }
        }
      }
    }
    [] -> checksum
  }
}

pub fn pt_2(input: Deque(Block)) {
  let list_input = deque.to_list(input)
  get_checksum2(list_input, [], 0, 0)
}
