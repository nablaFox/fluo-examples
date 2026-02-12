import fpc/matrix.{type Matrix, type Vec3, Vec3, at}
import gleam_community/maths.{cos, degrees_to_radians, sin}

pub type Transform {
  Transform(
    x: Float,
    y: Float,
    z: Float,
    pitch: Float,
    yaw: Float,
    roll: Float,
    scale: Float,
  )
}

pub fn origin() -> Transform {
  Transform(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0)
}

pub fn translate(
  transform: Transform,
  x x: Float,
  y y: Float,
  z z: Float,
) -> Transform {
  Transform(
    ..transform,
    x: transform.x +. x,
    y: transform.y +. y,
    z: transform.z +. z,
  )
}

pub fn rotate(
  transform: Transform,
  pitch: Float,
  yaw: Float,
  roll: Float,
) -> Transform {
  let pitch = degrees_to_radians(pitch)
  let yaw = degrees_to_radians(yaw)
  let roll = degrees_to_radians(roll)

  Transform(
    ..transform,
    pitch: transform.pitch +. pitch,
    yaw: transform.yaw +. yaw,
    roll: transform.roll +. roll,
  )
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

pub fn rotate_pitch(transform: Transform, deg_x: Float) -> Transform {
  transform |> rotate(deg_x, 0.0, 0.0)
}

pub fn rotate_yaw(transform: Transform, deg_y: Float) -> Transform {
  transform |> rotate(0.0, deg_y, 0.0)
}

pub fn rotate_roll(transform: Transform, deg_z: Float) -> Transform {
  transform |> rotate(0.0, 0.0, deg_z)
}

pub fn scale(transform: Transform, s: Float) -> Transform {
  Transform(..transform, scale: transform.scale *. s)
}

fn rot4(rot: Matrix) -> Matrix {
  [
    [at(rot, 0, 0), at(rot, 0, 1), at(rot, 0, 2), 0.0],
    [at(rot, 1, 0), at(rot, 1, 1), at(rot, 1, 2), 0.0],
    [at(rot, 2, 0), at(rot, 2, 1), at(rot, 2, 2), 0.0],
    [0.0, 0.0, 0.0, 1.0],
  ]
}

pub fn rot_matrix(transform: Transform) -> Matrix {
  let Transform(pitch:, yaw:, roll:, ..) = transform

  let cx = cos(pitch)
  let cy = cos(yaw)
  let cz = cos(roll)
  let sx = sin(pitch)
  let sy = sin(yaw)
  let sz = sin(roll)

  let rx = [
    [1.0, 0.0, 0.0],
    [0.0, cx, 0.0 -. sx],
    [0.0, sx, cx],
  ]

  let ry = [
    [cy, 0.0, sy],
    [0.0, 1.0, 0.0],
    [0.0 -. sy, 0.0, cy],
  ]

  let rz = [
    [cz, 0.0 -. sz, 0.0],
    [sz, cz, 0.0],
    [0.0, 0.0, 1.0],
  ]

  rz |> matrix.multiply(ry) |> matrix.multiply(rx)
}

pub fn trans_matrix(transform: Transform) -> Matrix {
  let Transform(x, y, z, ..) = transform

  [
    [1.0, 0.0, 0.0, x],
    [0.0, 1.0, 0.0, y],
    [0.0, 0.0, 1.0, z],
    [0.0, 0.0, 0.0, 1.0],
  ]
}

pub fn scale_matrix(transform: Transform) -> Matrix {
  let Transform(scale:, ..) = transform

  [
    [scale, 0.0, 0.0, 0.0],
    [0.0, scale, 0.0, 0.0],
    [0.0, 0.0, scale, 0.0],
    [0.0, 0.0, 0.0, 1.0],
  ]
}

pub fn model_matrix(transform: Transform) -> Matrix {
  let scale = scale_matrix(transform)
  let trans = trans_matrix(transform)

  let rot = transform |> rot_matrix |> rot4

  trans |> matrix.multiply(rot) |> matrix.multiply(scale)
}

pub fn view_matrix(transform: Transform) -> Matrix {
  let Transform(x, y, z, ..) = transform

  let rot = transform |> rot_matrix |> matrix.transpose |> rot4

  let trans =
    trans_matrix(Transform(0.0 -. x, 0.0 -. y, 0.0 -. z, 0.0, 0.0, 0.0, 1.0))

  matrix.multiply(rot, trans)
}

fn basis(transform: Transform) -> #(Vec3, Vec3, Vec3) {
  let r = rot_matrix(transform)

  let right = Vec3(at(r, 0, 0), at(r, 1, 0), at(r, 2, 0))
  let up = Vec3(at(r, 0, 1), at(r, 1, 1), at(r, 2, 1))
  let forward = Vec3(0.0 -. at(r, 0, 2), 0.0 -. at(r, 1, 2), 0.0 -. at(r, 2, 2))

  #(forward, right, up)
}

pub fn up(transform: Transform) -> Vec3 {
  let #(_, _, up) = basis(transform)
  up
}

pub fn right(transform: Transform) -> Vec3 {
  let #(_, right, _) = basis(transform)
  right
}

pub fn forward(transform: Transform) -> Vec3 {
  let #(forward, _, _) = basis(transform)
  forward
}
