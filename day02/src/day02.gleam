import gleam/int
import gleam/io
import gleam/list
import tools

pub fn main() {
  let s = tools.read_lines()
  io.println("Solution 1: " <> list.length(s) |> int.to_string)
}
