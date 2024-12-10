import gleam/deque.{type Deque}
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

fn get_checksum(blocks: Deque(Block)) {
  get_checksum_loop(blocks, 0, 0)
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
  get_checksum(input)
}

pub fn pt_2(input: Deque(Block)) {
  todo as "part 2 not implemented"
}
