import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import tools

fn sum_ints(l: List(Int)) -> Int {
  l |> list.fold(0, fn(acc, v) { acc + v })
}

fn path_to_com(p, system, path) {
  case dict.get(system, p) {
    Ok(p2) -> path_to_com(p2, system, [p, ..path])
    Error(_) -> [p, ..path]
  }
}

fn count(system) {
  system
  |> dict.keys
  |> list.map(fn(p) { path_to_com(p, system, []) |> list.length })
  |> sum_ints
}

fn common(system, p1, p2) {
  let path1 = path_to_com(p1, system, [])
  let path2 = path_to_com(p2, system, [])
  let d =
    list.zip(path1, path2)
    |> list.take_while(fn(p) { p.0 == p.1 })
    |> list.length
  list.length(path1) + list.length(path2) - 2 * d - 2
}

pub fn main() {
  let system =
    tools.read_lines()
    |> list.fold(dict.new(), fn(acc, s) {
      let assert Ok(#(planet1, planet2)) = string.split_once(s, ")")
      dict.insert(acc, planet2, planet1)
    })
  let n = count(system)
  io.println("Solution 1: " <> n |> int.to_string)
  let m = common(system, "YOU", "SAN")
  io.println("Solution 2: " <> m |> int.to_string)
}
