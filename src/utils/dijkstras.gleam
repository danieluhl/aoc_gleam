import gleam/dict
import gleam/order
import gleamy/priority_queue.{type Queue} as pq
import utils/grid.{type Grid}

// hold a dictionary of all values
// and the current best time to get
// to those values

// always walk to the next lowest value
// check adjacent values and update them
// as we walk. To automatcially keep track
// of the lowest next node to visit we use a priority queue

pub opaque type GridQueue(node) {
  GridQueue(queue: Queue(node), grid: Grid(Int))
}

pub fn init(grid: Grid(Int)) {
  dict.to_list(grid)
  |> pq.from_list(fn(a, b) {
    case a, b {
      #(_, a_val), #(_, b_val) if a_val < b_val -> {
        order.Lt
      }
      _, _ -> {
        order.Gt
      }
    }
  })
}

pub fn push(node, queue) {
  pq.push(queue, node)
}

pub fn pop(queue) {
  pq.pop(queue)
}
