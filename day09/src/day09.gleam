import gleam/int
import gleam/io
import intcomp.{State, init, run}
import tools

pub fn main() {
  let state = tools.read_line() |> init
  let assert [d1] = run(State(..state, input: [1])).output
  io.println("Solution 1: " <> d1 |> int.to_string)
  let assert [d2] = run(State(..state, input: [2])).output
  io.println("Solution 2: " <> d2 |> int.to_string)
}
