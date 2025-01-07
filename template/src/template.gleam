import gleam/int
import gleam/io
import gleam/list
import tools

pub fn main() {
  let d = tools.read_lines()
  let n = d |> list.length
  io.println("Solution 1: " <> n |> int.to_string)
}
