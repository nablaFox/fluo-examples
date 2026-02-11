import gleam_community/maths.{degrees_to_radians}

pub type Transform {
  Transform(x: Float, y: Float, z: Float)
}

pub fn translate(
  transform: Transform,
  x x: Float,
  y y: Float,
  z z: Float,
) -> Transform {
  Transform(transform.x +. x, transform.y +. y, transform.z +. z)
}

pub fn rotate(
  transform: Transform,
  deg_x x: Float,
  deg_y y: Float,
  deg_z z: Float,
) -> Transform {
  let rad_x = degrees_to_radians(x)
  let rad_y = degrees_to_radians(y)
  let rad_z = degrees_to_radians(z)

  Transform(transform.x +. rad_x, transform.y +. rad_y, transform.z +. rad_z)
}

pub fn translate_x(transform: Transform, x: Float) -> Transform {
  transform |> translate(x, 0.0, 0.0)
}

pub fn translate_y(transform: Transform, y: Float) -> Transform {
  transform |> translate(0.0, y, 0.0)
}

pub fn translate_z(transform: Transform, z: Float) -> Transform {
  transform |> translate(0.0, 0.0, z)
}

pub fn rotate_x(transform: Transform, deg_x: Float) -> Transform {
  transform |> rotate(deg_x, 0.0, 0.0)
}

pub fn rotate_y(transform: Transform, deg_y: Float) -> Transform {
  transform |> rotate(0.0, deg_y, 0.0)
}

pub fn rotate_z(transform: Transform, deg_z: Float) -> Transform {
  transform |> rotate(0.0, 0.0, deg_z)
}

pub fn scale(transform: Transform, scale: Float) -> Transform {
  Transform(transform.x *. scale, transform.y *. scale, transform.z *. scale)
}

pub fn move(base: Transform, direction: Transform, amount: Float) -> Transform {
  let delta = scale(direction, amount)

  translate(base, delta.x, delta.y, delta.z)
}
