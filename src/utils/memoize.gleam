import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/otp/actor

// I realized in recursive walking algorithms they 
// are massively inefficient if I can't track what
// nodes have been visited globally. For some even
// having global state would not properly solve the
// problem. But for some this is necessary and in 
// gleam the only way to get it is through actors.

// Actors seem similar to actions in a flux system
// They sort of simulate connecting with an external
// data store in a pub/sub style

// We define the types of messages that can be sent,
//  the handlers, how to start and end the actor,
//  and a convenience method to get it all running
//  this was blatantly stolen from [here](https://github.com/devries/advent_of_code_2024/blob/main/src/internal/memoize.gleam)

pub type Message(k, v) {
  Insert(key: k, value: v)
  Get(reply_with: Subject(Result(v, Nil)), key: k)
  Shutdown
}

pub type Cache(k, v) =
  Subject(Message(k, v))

pub fn handle_message(message: Message(k, v), current: Dict(k, v)) {
  case message {
    Insert(key, value) -> {
      actor.continue(dict.insert(current, key, value))
    }
    Get(client, key) -> {
      process.send(client, dict.get(current, key))
      actor.continue(current)
    }
    Shutdown -> actor.Stop(process.Normal)
  }
}

// Checks the cache for a value. If none found it runs the callback and 
// returns the result instead
// e.g.
//   `use <- cache_check(cache, #(x, y))`
// any code after the use is the callback
pub fn cache_check(cache: Cache(k, v), key: k, callback: fn() -> v) -> v {
  let cache_result = process.call(cache, Get(_, key), 100)

  case cache_result {
    Ok(v) -> v
    Error(Nil) -> {
      let result = callback()
      process.send(cache, Insert(key, result))
      result
    }
  }
}

pub fn cache_init() -> Cache(k, v) {
  let assert Ok(cache) = actor.start(dict.new(), handle_message)
  cache
}

pub fn cache_shutdown(cache: Cache(k, v)) {
  process.send(cache, Shutdown)
}
