import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import tools

pub type State {
  State(
    mem: dict.Dict(Int, Int),
    pc: Int,
    input: List(Int),
    output: List(Int),
    paused: Bool,
    debug: Bool,
    base: Int,
  )
}

type Instr {
  Add(mode: Int)
  Mul(mode: Int)
  In(mode: Int)
  Out(mode: Int)
  JmpTrue(mode: Int)
  JmpFalse(mode: Int)
  LessThen(mode: Int)
  Equals(mode: Int)
  Adjust(mode: Int)
  End
}

pub fn init(data: String) -> State {
  let mem =
    data
    |> string.split(",")
    |> tools.to_int_list
    |> list.index_fold(dict.new(), fn(acc, v, i) { dict.insert(acc, i, v) })
  State(
    mem:,
    pc: 0,
    input: [],
    output: [],
    paused: False,
    debug: False,
    base: 0,
  )
}

fn decode(code: Int) -> Instr {
  let mode = code / 100
  case code % 100 {
    1 -> Add(mode)
    2 -> Mul(mode)
    3 -> In(mode)
    4 -> Out(mode)
    5 -> JmpTrue(mode)
    6 -> JmpFalse(mode)
    7 -> LessThen(mode)
    8 -> Equals(mode)
    9 -> Adjust(mode)
    99 -> End
    _ -> panic as { "unexpected code: " <> int.to_string(code) }
  }
}

fn get_arg(s: State, offs, mode) -> Int {
  let #(mem, adr) = #(s.mem, s.pc + offs)
  let v = dict.get(mem, adr) |> result.unwrap(0)
  case mode {
    0 -> dict.get(mem, v) |> result.unwrap(0)
    1 -> v
    2 -> dict.get(mem, s.base + v) |> result.unwrap(0)
    _ -> panic as { "unexpected mode " <> int.to_string(mode) }
  }
}

fn get_out(s: State, offs, mode) -> Int {
  let #(mem, adr) = #(s.mem, s.pc + offs)
  let v = dict.get(mem, adr) |> result.unwrap(0)
  case mode {
    0 -> v
    2 -> v + s.base
    n -> panic as { "invalid mode " <> int.to_string(n) }
  }
}

fn debug(s: State, msg) {
  case s.debug {
    True -> io.debug(msg)
    False -> msg
  }
}

fn add(s: State, mode: Int) -> State {
  let a = get_arg(s, 1, mode % 10)
  let b = get_arg(s, 2, mode / 10 % 10)
  let c = get_out(s, 3, mode / 100 % 10)
  debug(s, #("add", s.pc, "mode", mode, "abc", a, b, c))
  State(..s, mem: dict.insert(s.mem, c, a + b), pc: s.pc + 4)
}

fn mul(s: State, mode: Int) -> State {
  let a = get_arg(s, 1, mode % 10)
  let b = get_arg(s, 2, mode / 10 % 10)
  let c = get_out(s, 3, mode / 100 % 10)
  debug(s, #("mul", s.pc, "mode", mode, "abc", a, b, c))
  State(..s, mem: dict.insert(s.mem, c, a * b), pc: s.pc + 4)
}

fn in(s: State, mode: Int) -> State {
  let a = get_out(s, 1, mode % 10)
  debug(s, #("in", s.pc, "mode", mode, "a", a))
  case s.input {
    [v, ..rest] ->
      State(..s, mem: dict.insert(s.mem, a, v), input: rest, pc: s.pc + 2)
    [] -> State(..s, paused: True)
  }
}

fn out(s: State, mode: Int) -> State {
  let a = get_arg(s, 1, mode % 10)
  debug(s, #("out", s.pc, "mode", mode, "a", a))
  State(..s, output: [a, ..s.output], pc: s.pc + 2)
}

fn jmp_true(s: State, mode: Int) -> State {
  let a = get_arg(s, 1, mode % 10)
  let b = get_arg(s, 2, mode / 10 % 10)
  debug(s, #("jt", mode, a, b))
  case a {
    0 -> State(..s, pc: s.pc + 3)
    _ -> State(..s, pc: b)
  }
}

fn jmp_false(s: State, mode: Int) -> State {
  let a = get_arg(s, 1, mode % 10)
  let b = get_arg(s, 2, mode / 10 % 10)
  debug(s, #("jf", mode, a, b))
  case a {
    0 -> State(..s, pc: b)
    _ -> State(..s, pc: s.pc + 3)
  }
}

fn less_then(s: State, mode: Int) -> State {
  let a = get_arg(s, 1, mode % 10)
  let b = get_arg(s, 2, mode / 10 % 10)
  let c = get_out(s, 3, mode / 100 % 10)
  let v = case a < b {
    True -> 1
    False -> 0
  }
  debug(s, #("lt", mode, a, b, c, v))
  State(..s, mem: dict.insert(s.mem, c, v), pc: s.pc + 4)
}

fn equals(s: State, mode: Int) -> State {
  let a = get_arg(s, 1, mode % 10)
  let b = get_arg(s, 2, mode / 10 % 10)
  let c = get_out(s, 3, mode / 100 % 10)
  let v = case a == b {
    True -> 1
    False -> 0
  }
  debug(s, #("eq", mode, a, b, c, v))
  State(..s, mem: dict.insert(s.mem, c, v), pc: s.pc + 4)
}

fn adjust(s: State, mode: Int) -> State {
  let a = get_arg(s, 1, mode % 10)
  debug(s, #("adj", mode, a, s.base))
  State(..s, base: s.base + a, pc: s.pc + 2)
}

pub fn run(s: State) {
  let s = State(..s, paused: False)
  case dict.get(s.mem, s.pc) {
    Error(Nil) -> panic as { "not found in mem: " <> int.to_string(s.pc) }
    Ok(code) -> {
      case decode(code) {
        End -> s
        Add(mode) -> run(add(s, mode))
        Mul(mode) -> run(mul(s, mode))
        Out(mode) -> run(out(s, mode))
        In(mode) ->
          case in(s, mode) {
            s if s.paused -> s
            s -> run(s)
          }
        JmpTrue(mode) -> run(jmp_true(s, mode))
        JmpFalse(mode) -> run(jmp_false(s, mode))
        LessThen(mode) -> run(less_then(s, mode))
        Equals(mode) -> run(equals(s, mode))
        Adjust(mode) -> run(adjust(s, mode))
      }
    }
  }
}
