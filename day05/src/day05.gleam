import gleam/int
import gleam/io
import gleam/string
import intcomp
import tools

pub fn main() {
  let state =
    tools.read_line()
    |> string.split(",")
    |> tools.to_int_list
    |> intcomp.init

  let assert [d1, ..] = intcomp.run(intcomp.State(..state, input: [1])).output
  io.println("Solution 1: " <> d1 |> int.to_string)

  let assert [d2, ..] = intcomp.run(intcomp.State(..state, input: [5])).output
  io.println("Solution 2: " <> d2 |> int.to_string)
}
