import gleam/int
import gleam/io
import gleam/list
import gleam/string
import tools

fn reduce(acc: Int, n: Int) -> Int {
  let n = n / 3 - 2
  case n {
    n if n <= 0 -> acc
    n -> reduce(acc + n, n)
  }
}

pub fn main() {
  let s =
    tools.read_lines()
    |> list.filter(fn(a) { !string.is_empty(a) })
    |> list.map(fn(a) {
      let assert Ok(v) = int.parse(a)
      v
    })
  let n1 = list.fold(s, 0, fn(acc, b) { acc + b / 3 - 2 })
  io.println("Solution 1: " <> int.to_string(n1))
  let n2 = list.fold(s, 0, fn(acc, b) { acc + reduce(0, b) })
  io.println("Solution 2: " <> int.to_string(n2))
}
