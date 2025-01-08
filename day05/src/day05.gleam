import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import tools

type Memory =
  dict.Dict(Int, Int)

type State {
  State(mem: Memory, pc: Int, output: List(Int))
}

type Instr {
  End
  Add(mode: Int)
  Mul(mode: Int)
  In1
  Out(mode: Int)
}

fn decode(code: Int) -> Instr {
  case code % 100 {
    99 -> End
    1 -> Add(code / 100)
    2 -> Mul(code / 100)
    3 -> In1
    4 -> Out(code / 100)
    _ -> panic as { "unexpected code: " <> int.to_string(code) }
  }
}

fn unwrap(r) {
  case r {
    Ok(v) -> v
    Error(_) -> panic as "unexpected"
  }
}

fn get_arg(mem, adr, mode) -> Int {
  io.debug(
    "get adr: " <> int.to_string(adr) <> ", mode: " <> int.to_string(mode),
  )
  let v = dict.get(mem, adr) |> unwrap
  io.debug("get adr, v: " <> int.to_string(v))
  let v = case mode {
    0 -> dict.get(mem, v) |> unwrap
    _ -> v
  }
  io.debug("get adr, v: " <> int.to_string(v))
  v
}

fn add(s: State, mode: Int) -> State {
  let a = get_arg(s.mem, s.pc + 1, mode % 10)
  let b = get_arg(s.mem, s.pc + 2, mode / 10 % 10)
  let c = get_arg(s.mem, s.pc + 3, 1)
  io.debug(
    "add, a: "
    <> int.to_string(a)
    <> ", b: "
    <> int.to_string(b)
    <> ", c: "
    <> int.to_string(c),
  )
  State(..s, mem: dict.insert(s.mem, c, a + b), pc: s.pc + 4)
}

fn mul(s: State, mode: Int) -> State {
  let a = get_arg(s.mem, s.pc + 1, mode % 10)
  let b = get_arg(s.mem, s.pc + 2, mode / 10 % 10)
  let c = get_arg(s.mem, s.pc + 3, 1)
  io.debug(
    "mul, a: "
    <> int.to_string(a)
    <> ", b: "
    <> int.to_string(b)
    <> ", c: "
    <> int.to_string(c),
  )
  State(..s, mem: dict.insert(s.mem, c, a * b), pc: s.pc + 4)
}

fn in1(s: State) -> State {
  let a = get_arg(s.mem, s.pc + 1, 1)
  io.debug("in1, a: " <> int.to_string(a))
  State(..s, mem: dict.insert(s.mem, a, 1), pc: s.pc + 2)
}

fn out(s: State, mode: Int) -> State {
  let a = get_arg(s.mem, s.pc + 1, mode % 10)
  io.debug("out, a: " <> int.to_string(a))
  State(..s, output: [a, ..s.output], pc: s.pc + 2)
}

fn run(s: State) {
  case dict.get(s.mem, s.pc) {
    Error(Nil) -> panic as { "not found in mem: " <> int.to_string(s.pc) }
    Ok(code) -> {
      io.debug(
        "run, pc: " <> int.to_string(s.pc) <> ", code: " <> int.to_string(code),
      )
      case decode(code) {
        End -> s
        Add(mode) -> run(add(s, mode))
        Mul(mode) -> run(mul(s, mode))
        Out(mode) -> run(out(s, mode))
        In1 -> run(in1(s))
      }
    }
  }
}

pub fn main() {
  let memory =
    tools.read_line()
    |> string.split(",")
    |> tools.to_int_list
    |> list.index_fold(dict.new(), fn(mem, v, i) { dict.insert(mem, i, v) })
  let State(_, _, outputs) = run(State(memory, 0, []))
  io.println("Solution 1: " <> list.first(outputs) |> unwrap |> int.to_string)
}
