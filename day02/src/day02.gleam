import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import tools

fn get(d, k) {
  case dict.get(d, k) {
    Ok(v) -> v
    Error(_) -> panic as "unexpected"
  }
}

fn restore(d, noun, verb) {
  d |> dict.insert(1, noun) |> dict.insert(2, verb)
}

fn run(d, i) {
  case get(d, i) {
    99 -> d
    1 -> {
      let a = get(d, get(d, i + 1))
      let b = get(d, get(d, i + 2))
      let c = get(d, i + 3)
      run(dict.insert(d, c, a + b), i + 4)
    }
    2 -> {
      let a = get(d, get(d, i + 1))
      let b = get(d, get(d, i + 2))
      let c = get(d, i + 3)
      run(dict.insert(d, c, a * b), i + 4)
    }
    _ -> panic as "unexpected"
  }
}

pub fn main() {
  let d =
    tools.read_line()
    |> string.split(",")
    |> list.map(fn(v) {
      let assert Ok(v) = int.parse(v)
      v
    })
    |> list.index_fold(dict.new(), fn(d, v, i) { dict.insert(d, i, v) })
  let n = d |> restore(12, 2) |> run(0) |> get(0)
  io.println("Solution 1: " <> n |> int.to_string)
}
