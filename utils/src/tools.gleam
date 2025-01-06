import gleam/erlang
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
