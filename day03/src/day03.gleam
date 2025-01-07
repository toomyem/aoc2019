import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/string
import tools

type Move {
  R(Int)
  L(Int)
  U(Int)
  D(Int)
}

type Pos {
  Pos(x: Int, y: Int)
}

type Line {
  Line(Pos, Pos)
}

fn to_int(s) {
  let assert Ok(v) = int.parse(s)
  v
}

fn line(pos, move) {
  let Pos(x, y) = pos
  case move {
    R(dist) -> Pos(x + dist, y)
    L(dist) -> Pos(x - dist, y)
    D(dist) -> Pos(x, y + dist)
    U(dist) -> Pos(x, y - dist)
  }
}

fn read_moves() {
  tools.read_line()
  |> string.split(",")
  |> list.map(fn(s) {
    case string.pop_grapheme(s) {
      Ok(#("R", dist)) -> R(to_int(dist))
      Ok(#("L", dist)) -> L(to_int(dist))
      Ok(#("U", dist)) -> U(to_int(dist))
      Ok(#("D", dist)) -> D(to_int(dist))
      Ok(_) | Error(_) -> panic as "Unexpected"
    }
  })
}

fn draw(moves) {
  list.fold(moves, #([], Pos(0, 0)), fn(acc, move) {
    let #(lines, prev) = acc
    let next = line(prev, move)
    #([Line(prev, next), ..lines], next)
  })
  |> pair.first
}

pub fn main() {
  let m1 = read_moves() |> draw()
  let m2 = read_moves() |> draw()
  io.println("Solution 1: " <> m1 |> list.length |> int.to_string)
  io.println("Solution 2: " <> m2 |> list.length |> int.to_string)
}
