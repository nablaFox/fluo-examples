import gleam/list

pub type Vec =
  List(Float)

pub type Vec3 {
  Vec3(x: Float, y: Float, z: Float)
}

pub type Vec2 {
  Vec2(x: Float, y: Float)
}

pub fn dot(a: Vec, b: Vec) -> Float {
  let assert Ok(list) = list.strict_zip(a, b)
    as "Vectors must be the same length"

  use acc, el <- list.fold(list, 0.0)

  acc +. el.0 *. el.1
}

pub fn scale(vec: Vec, scale: Float) -> Vec {
  use el <- list.map(vec)
  el *. scale
}
