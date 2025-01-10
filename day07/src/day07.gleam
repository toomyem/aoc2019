import gleam/int
import gleam/io
import gleam/list
import gleam/string
import intcomp.{State, run}
import tools

fn next(n: List(Int)) -> Result(List(Int), Nil) {
  case n {
    [v, ..rest] if v < 4 -> Ok([v + 1, ..rest])
    [_, ..rest] ->
      case next(rest) {
        Ok(v) -> Ok([0, ..v])
        Error(Nil) -> Error(Nil)
      }
    [] -> Error(Nil)
  }
}

fn thrust(state, phases: List(Int), acc) -> Int {
  case phases {
    [] -> acc
    [p, ..rest] -> {
      let assert [out] = run(State(..state, input: [p, acc])).output
      thrust(state, rest, out)
    }
  }
}

fn check(state) {
  list.permutations([0, 1, 2, 3, 4])
  |> list.map(fn(p) { thrust(state, p, 0) })
  |> list.max(with: int.compare)
  |> tools.unwrap
}

pub fn main() {
  let state =
    tools.read_line() |> string.split(",") |> tools.to_int_list |> intcomp.init
  let n = check(state)
  io.println("Solution 1: " <> n |> int.to_string)
}
