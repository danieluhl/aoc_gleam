import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) {
  input |> string.split("\n") |> list.try_map(int.parse) |> result.unwrap([])
}

pub fn mix_and_prune(num: Int, prev_secret: Int) {
  let mixed = num |> int.bitwise_exclusive_or(prev_secret, _)
  mixed % 16_777_216
}

pub fn pt_1(input: List(Int)) {
  list.range(1, 2000)
  |> list.fold(input, fn(acc, _) {
    acc
    |> list.map(fn(num) {
      // multiply by 64 then mix an prune
      let secret_1 = mix_and_prune(num * 64, num)

      // divide by 32, mix and prune
      let secret_2 = mix_and_prune(secret_1 / 32, secret_1)

      // multiply by 2048, mix and prune
      let secret_3 = mix_and_prune(secret_2 * 2048, secret_2)
      secret_3
    })
  })
  |> list.reduce(fn(acc, n) { acc + n })
}

pub fn pt_2(input: List(Int)) {
  // build the list of changes and the value for each
  // find 4 changes that will have the higest amount for all 
  //  window the changes in groups of 4 and calculate the total max
  // matches: dict(#(1, -1, 1, -1), [values])
  list.range(1, 2000)
  |> list.fold(#(input, [], dict.new()), fn(acc, _) {
    let #(secrets, changes, change_vals) = acc
    let next_secrets =
      secrets
      |> list.map(fn(num) {
        // multiply by 64 then mix an prune
        let secret_1 = mix_and_prune(num * 64, num)

        // divide by 32, mix and prune
        let secret_2 = mix_and_prune(secret_1 / 32, secret_1)

        // multiply by 2048, mix and prune
        let secret_3 = mix_and_prune(secret_2 * 2048, secret_2)
        secret_3
      })
    // let this_changes = 
    #(next_secrets, next_changes, next_change_vals)
  })
  todo as "part 2 not implemented"
}
