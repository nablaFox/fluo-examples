import fpc/matrix.{type Matrix, at}
import fpc/transform.{type Transform, Transform}
import gleam/list
import gleam_community/maths.{cos, sin, tan}

pub type Camera {
  Camera(
    proj: Matrix,
    view: Matrix,
    viewproj: Matrix,
    position: Transform,
    rotation: Transform,
    forward: Transform,
    right: Transform,
    up: Transform,
  )
}

fn calc_view_and_basis(
  rot: Transform,
  pos: Transform,
) -> #(Matrix, Transform, Transform, Transform) {
  let cx = cos(rot.x)
  let cy = cos(rot.y)
  let cz = cos(rot.z)
  let sx = sin(rot.x)
  let sy = sin(rot.y)
  let sz = sin(rot.z)

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

  let rcw = rz |> matrix.multiply(ry) |> matrix.multiply(rx)

  let right = Transform(at(rcw, 0, 0), at(rcw, 1, 0), at(rcw, 2, 0))

  let up = Transform(at(rcw, 0, 1), at(rcw, 1, 1), at(rcw, 2, 1))

  let forward =
    Transform(0.0 -. at(rcw, 0, 2), 0.0 -. at(rcw, 1, 2), 0.0 -. at(rcw, 2, 2))

  let rwc = matrix.transpose(rcw)

  let assert [tx, ty, tz] =
    rwc
    |> matrix.multiply([[pos.x], [pos.y], [pos.z]])
    |> matrix.scale(-1.0)
    |> list.flatten
    as "Invalid view matrix"

  let view = [
    [at(rwc, 0, 0), at(rwc, 0, 1), at(rwc, 0, 2), tx],
    [at(rwc, 1, 0), at(rwc, 1, 1), at(rwc, 1, 2), ty],
    [at(rwc, 2, 0), at(rwc, 2, 1), at(rwc, 2, 2), tz],
    [0.0, 0.0, 0.0, 1.0],
  ]

  #(view, forward, right, up)
}

pub fn create_camera(
  position position: Transform,
  rotation rotation: Transform,
  fov fov: Float,
  near n: Float,
  far f: Float,
  aspect aspect: Float,
) -> Camera {
  let proj = {
    let fov_angle = maths.degrees_to_radians(fov)

    let top = n *. tan(fov_angle /. 2.0)
    let right = top *. aspect

    let a = n /. right
    let b = 0.0 -. { n /. top }
    let c = { f +. n } /. { n -. f }
    let d = { 2.0 *. f *. n } /. { n -. f }

    [
      [a, 0.0, 0.0, 0.0],
      [0.0, b, 0.0, 0.0],
      [0.0, 0.0, c, d],
      [0.0, 0.0, -1.0, 0.0],
    ]
  }

  let #(view, forward, right, up) = calc_view_and_basis(rotation, position)

  let viewproj = matrix.multiply(proj, view)

  Camera(proj, view, viewproj, position, rotation, forward, right, up)
}

pub fn rotate_camera(camera: Camera, rotation: Transform) -> Camera {
  let #(view, forward, right, up) =
    calc_view_and_basis(rotation, camera.position)

  let viewproj = matrix.multiply(camera.proj, view)

  Camera(..camera, forward:, right:, up:, rotation:, view:, viewproj:)
}

/// rotate around x axis (look up/down)
pub fn pitch(camera, deg) -> Camera {
  camera |> rotate_camera(transform.rotate_x(camera.rotation, 0.0 -. deg))
}

/// rotate around y axis (look left/right)
pub fn yaw(camera, deg) -> Camera {
  camera |> rotate_camera(transform.rotate_y(camera.rotation, 0.0 -. deg))
}

/// rotate around z axis
pub fn roll(camera, deg) -> Camera {
  camera |> rotate_camera(transform.rotate_z(camera.rotation, deg))
}

pub fn move(camera: Camera, direction: Transform, amount: Float) -> Camera {
  let position = camera.position |> transform.move(direction, amount)

  let #(view, forward, right, up) =
    calc_view_and_basis(camera.rotation, position)

  let viewproj = matrix.multiply(camera.proj, view)

  Camera(..camera, position:, view:, viewproj:, forward:, right:, up:)
}

pub fn move_forward(camera: Camera, amount: Float) -> Camera {
  move(camera, camera.forward, amount)
}

pub fn move_right(camera: Camera, amount: Float) -> Camera {
  move(camera, camera.right, amount)
}

pub fn move_up(camera: Camera, amount: Float) -> Camera {
  move(camera, camera.up, amount)
}
