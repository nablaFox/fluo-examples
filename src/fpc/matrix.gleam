import gleam/list

pub type Vec =
  List(Float)

pub type Matrix =
  List(Vec)

pub type Vec3 {
  Vec3(x: Float, y: Float, z: Float)
}

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

fn dot(a: Vec, b: Vec) -> Float {
  let assert Ok(list) = list.strict_zip(a, b)
    as "Vectors must be the same length"

  use acc, el <- list.fold(list, 0.0)

  acc +. el.0 *. el.1
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

      dot(row, col)
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
