import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string
import tools

fn is_non_decreasing(v) {
  int.to_string(v)
  |> string.to_graphemes
  |> tools.to_int_list
  |> list.window_by_2
  |> list.all(fn(v) {
    let #(a, b) = v
    a <= b
  })
}

fn has_pair(v) {
  let assert Ok(re) = regexp.from_string("(.)\\1")
  int.to_string(v) |> regexp.check(with: re)
}

fn has_strict_pair(v) {
  let assert Ok(re) = regexp.from_string("(.)\\1+")
  int.to_string(v)
  |> regexp.scan(with: re)
  |> list.any(fn(m) { string.length(m.content) == 2 })
}

pub fn main() {
  let assert [a, b] =
    tools.read_line() |> string.split("-") |> tools.to_int_list
  let l = list.range(a, b) |> list.filter(is_non_decreasing)
  io.println("Solution 1: " <> list.count(l, has_pair) |> int.to_string)
  io.println("Solution 1: " <> list.count(l, has_strict_pair) |> int.to_string)
}
