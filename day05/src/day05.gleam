import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import tools

type Memory =
  dict.Dict(Int, Int)

type State {
  State(mem: Memory, pc: Int, input: List(Int), output: List(Int))
}

type Instr {
  Add(mode: Int)
  Mul(mode: Int)
  In
  Out(mode: Int)
  JmpTrue(mode: Int)
  JmpFalse(mode: Int)
  LessThen(mode: Int)
  Equals(mode: Int)
  End
}

fn decode(code: Int) -> Instr {
  let mode = code / 100
  case code % 100 {
    1 -> Add(mode)
    2 -> Mul(mode)
    3 -> In
    4 -> Out(mode)
    5 -> JmpTrue(mode)
    6 -> JmpFalse(mode)
    7 -> LessThen(mode)
    8 -> Equals(mode)
    99 -> End
    _ -> panic as { "unexpected code: " <> int.to_string(code) }
  }
}

fn unwrap(r) {
  case r {
    Ok(v) -> v
    Error(_) -> panic as "unexpected error"
  }
}

fn get_arg(mem, adr, mode) -> Int {
  let v = dict.get(mem, adr) |> unwrap
  case mode {
    0 -> dict.get(mem, v) |> unwrap
    _ -> v
  }
}

fn add(s: State, mode: Int) -> State {
  let a = get_arg(s.mem, s.pc + 1, mode % 10)
  let b = get_arg(s.mem, s.pc + 2, mode / 10 % 10)
  let c = get_arg(s.mem, s.pc + 3, 1)
  State(..s, mem: dict.insert(s.mem, c, a + b), pc: s.pc + 4)
}

fn mul(s: State, mode: Int) -> State {
  let a = get_arg(s.mem, s.pc + 1, mode % 10)
  let b = get_arg(s.mem, s.pc + 2, mode / 10 % 10)
  let c = get_arg(s.mem, s.pc + 3, 1)
  State(..s, mem: dict.insert(s.mem, c, a * b), pc: s.pc + 4)
}

fn in(s: State) -> State {
  let a = get_arg(s.mem, s.pc + 1, 1)
  case s.input {
    [v, ..rest] ->
      State(..s, mem: dict.insert(s.mem, a, v), input: rest, pc: s.pc + 2)
    [] -> panic as "input underflow"
  }
}

fn out(s: State, mode: Int) -> State {
  let a = get_arg(s.mem, s.pc + 1, mode % 10)
  State(..s, output: [a, ..s.output], pc: s.pc + 2)
}

fn jmp_true(s: State, mode: Int) -> State {
  let a = get_arg(s.mem, s.pc + 1, mode % 10)
  let b = get_arg(s.mem, s.pc + 2, mode / 10 % 10)
  case a {
    0 -> State(..s, pc: s.pc + 3)
    _ -> State(..s, pc: b)
  }
}

fn jmp_false(s: State, mode: Int) -> State {
  let a = get_arg(s.mem, s.pc + 1, mode % 10)
  let b = get_arg(s.mem, s.pc + 2, mode / 10 % 10)
  case a {
    0 -> State(..s, pc: b)
    _ -> State(..s, pc: s.pc + 3)
  }
}

fn less_then(s: State, mode: Int) -> State {
  let a = get_arg(s.mem, s.pc + 1, mode % 10)
  let b = get_arg(s.mem, s.pc + 2, mode / 10 % 10)
  let c = get_arg(s.mem, s.pc + 3, 1)
  let v = case a < b {
    True -> 1
    False -> 0
  }
  State(..s, mem: dict.insert(s.mem, c, v), pc: s.pc + 4)
}

fn equals(s: State, mode: Int) -> State {
  let a = get_arg(s.mem, s.pc + 1, mode % 10)
  let b = get_arg(s.mem, s.pc + 2, mode / 10 % 10)
  let c = get_arg(s.mem, s.pc + 3, 1)
  let v = case a == b {
    True -> 1
    False -> 0
  }
  State(..s, mem: dict.insert(s.mem, c, v), pc: s.pc + 4)
}

fn run(s: State) {
  case dict.get(s.mem, s.pc) {
    Error(Nil) -> panic as { "not found in mem: " <> int.to_string(s.pc) }
    Ok(code) -> {
      case decode(code) {
        End -> s
        Add(mode) -> run(add(s, mode))
        Mul(mode) -> run(mul(s, mode))
        Out(mode) -> run(out(s, mode))
        In -> run(in(s))
        JmpTrue(mode) -> run(jmp_true(s, mode))
        JmpFalse(mode) -> run(jmp_false(s, mode))
        LessThen(mode) -> run(less_then(s, mode))
        Equals(mode) -> run(equals(s, mode))
      }
    }
  }
}

pub fn main() {
  let mem =
    tools.read_line()
    |> string.split(",")
    |> tools.to_int_list
    |> list.index_fold(dict.new(), fn(mem, v, i) { dict.insert(mem, i, v) })
  let State(_, _, _, output) =
    run(State(mem: mem, pc: 0, output: [], input: [1]))
  io.println("Solution 1: " <> list.first(output) |> unwrap |> int.to_string)
  let State(_, _, _, output) =
    run(State(mem: mem, pc: 0, output: [], input: [5]))
  io.println("Solution 2: " <> list.first(output) |> unwrap |> int.to_string)
}
