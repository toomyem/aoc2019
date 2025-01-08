import gleam/erlang
import gleam/int
import gleam/list
import gleam/string

pub fn read_line() -> String {
  case erlang.get_line("") {
    Ok(s) -> string.trim_end(s)
    Error(_) -> panic as "Cannot read from stdin"
  }
}

pub fn read_lines() -> List(String) {
  case erlang.get_line("") {
    Ok(s) -> [string.trim_end(s), ..read_lines()]
    Error(_) -> []
  }
}

pub fn cartesian(l1: List(a), l2: List(b)) -> List(#(a, b)) {
  list.flat_map(l1, fn(v1) { list.map(l2, fn(v2) { #(v1, v2) }) })
}

pub fn to_int_list(l: List(String)) -> List(Int) {
  list.map(l, fn(s) {
    let assert Ok(v) = int.parse(s)
    v
  })
}

pub fn int_list_to_string(l: List(Int)) -> String {
  list.fold(l, "", fn(acc, v) { acc <> int.to_string(v) <> "," })
  |> string.drop_end(1)
}
