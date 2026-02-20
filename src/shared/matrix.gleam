import gleam/list
import shared/vector.{type Vec}

pub type Matrix =
  List(Vec)

pub type RawMatrix =
  List(Float)

fn nth(list xs: List(a), index i: Int) -> a {
  let assert True = i >= 0 as "Index must be >= 0"

  let assert True = i < list.length(xs) as "Index out of bounds"

  let assert [x, ..] = list.drop(xs, i)

  x
}

pub fn at(m: Matrix, row: Int, col: Int) -> Float {
  m
  |> nth(row)
  |> nth(col)
}

pub fn multiply(a: Matrix, b: Matrix) -> Matrix {
  case a, b {
    [], _ -> []
    _, [] -> []

    [arow, ..], _ -> {
      let assert True = list.length(arow) == list.length(b)
        as "Number of columns in A must match number of rows in B"

      let cols = list.transpose(b)

      use row <- list.map(a)
      use col <- list.map(cols)

      vector.dot(row, col)
    }
  }
}

pub fn transpose(matrix: Matrix) -> Matrix {
  list.transpose(matrix)
}

pub fn scale(matrix: Matrix, scale: Float) -> Matrix {
  use row <- list.map(matrix)

  use el <- list.map(row)

  el *. scale
}

pub fn multiply_vec3(mat: Matrix, vec: vector.Vec3) -> vector.Vec3 {
  vector.Vec3(
    at(mat, 0, 0) *. vec.x +. at(mat, 0, 1) *. vec.y +. at(mat, 0, 2) *. vec.z,
    at(mat, 1, 0) *. vec.x +. at(mat, 1, 1) *. vec.y +. at(mat, 1, 2) *. vec.z,
    at(mat, 2, 0) *. vec.x +. at(mat, 2, 1) *. vec.y +. at(mat, 2, 2) *. vec.z,
  )
}
