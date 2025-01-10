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

fn find(d) {
  let ans =
    tools.cartesian(list.range(0, 99), list.range(0, 99))
    |> list.find(fn(v) {
      let #(noun, verb) = v
      let ans = d |> restore(noun, verb) |> run(0) |> get(0)
      ans == 19_690_720
    })
  case ans {
    Error(_) -> panic as "unexpected"
    Ok(v) -> v
  }
}

pub fn main() {
  let d =
    tools.read_line()
    |> string.split(",")
    |> tools.to_int_list
    |> list.index_fold(dict.new(), fn(d, v, i) { dict.insert(d, i, v) })

  let n = d |> restore(12, 2) |> run(0) |> get(0)
  io.println("Solution 1: " <> n |> int.to_string)
  let #(noun, verb) = find(d)
  io.println("Solution 2: " <> { noun * 100 + verb } |> int.to_string)
}
