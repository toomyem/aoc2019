import gleam/int
import gleam/io
import gleam/list
import gleam/string
import tools

type Image {
  Image(w: Int, h: Int, pixels: String)
}

fn get_layers(img: Image) {
  let size = img.w * img.h
  list.range(0, string.length(img.pixels) / size - 1)
  |> list.map(fn(n) { string.slice(img.pixels, n * size, size) })
}

fn count(s, ch) {
  string.to_graphemes(s) |> list.count(fn(c) { c == ch })
}

fn calc(img: Image) {
  let min0 =
    get_layers(img)
    |> list.map(fn(layer) {
      let c = count(layer, "0")
      #(c, layer)
    })
    |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
    |> list.first
    |> tools.unwrap

  count(min0.1, "1") * count(min0.1, "2")
}

fn render(img: Image) -> Image {
  let pixels =
    get_layers(img)
    |> list.fold(string.repeat("2", img.w * img.h), fn(acc, layer) {
      list.zip(string.to_graphemes(acc), string.to_graphemes(layer))
      |> list.map(fn(pair) {
        case pair.0, pair.1 {
          "2", n -> n
          n, _ -> n
        }
      })
      |> string.concat
    })
  Image(..img, pixels:)
}

fn print(img: Image) -> String {
  let pixels =
    render(img).pixels
    |> string.to_graphemes
    |> list.map(fn(ch) {
      case ch {
        "1" -> "#"
        _ -> " "
      }
    })
  list.sized_chunk(pixels, img.w)
  |> list.map(fn(line) { string.concat(line) <> "\n" })
  |> string.concat
}

pub fn main() {
  let img = tools.read_line() |> Image(25, 6, _)
  let n = calc(img)
  io.println("Solution 1: " <> n |> int.to_string)
  io.println("Solution 2:\n" <> print(img))
}
