import gleam/int
import gleam/io
import gleam/list
import gleam/string
import intcomp.{State, run}
import tools

fn compute(state, phases: List(Int), sig) -> Int {
  case phases {
    [] -> sig
    [p, ..rest] -> {
      let assert [out] = run(State(..state, input: [p, sig])).output
      compute(state, rest, out)
    }
  }
}

fn check(state) {
  list.permutations([0, 1, 2, 3, 4])
  |> list.map(compute(state, _, 0))
  |> list.max(with: int.compare)
  |> tools.unwrap
}

fn compute2(states, sig) -> Int {
  let #(sig, states) =
    list.fold(states, #(sig, []), fn(acc, s) {
      let s = run(State(..s, input: [acc.0]))
      let assert [o, ..] = s.output
      #(o, list.append(acc.1, [s]))
    })
  let assert Ok(last_state) = list.last(states)
  case last_state.paused {
    True -> compute2(states, sig)
    False -> sig
  }
}

fn check2(state) {
  list.permutations([5, 6, 7, 8, 9])
  |> list.map(fn(p) { list.map(p, fn(i) { run(State(..state, input: [i])) }) })
  |> list.map(compute2(_, 0))
  |> list.max(with: int.compare)
  |> tools.unwrap
}

pub fn main() {
  let state =
    tools.read_line() |> string.split(",") |> tools.to_int_list |> intcomp.init
  io.println("Solution 1: " <> check(state) |> int.to_string)
  io.println("Solution 2: " <> check2(state) |> int.to_string)
}
