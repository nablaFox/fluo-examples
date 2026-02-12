import fpc/matrix.{type Matrix, type Vec3}
import fpc/transform.{type Transform}
import gleam_community/maths.{tan}

pub type Camera {
  Camera(
    transform: Transform,
    forward: Vec3,
    right: Vec3,
    up: Vec3,
    proj: Matrix,
    view: Matrix,
    viewproj: Matrix,
  )
}

pub fn create_camera(
  transform transform: Transform,
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

  let view = transform.view_matrix(transform)
  let up = transform.up(transform)
  let right = transform.right(transform)
  let forward = transform.forward(transform)

  let viewproj = matrix.multiply(proj, view)

  Camera(transform, forward, right, up, proj, view, viewproj)
}

pub fn rotate_camera(
  camera: Camera,
  pitch: Float,
  yaw: Float,
  roll: Float,
) -> Camera {
  let transform =
    camera.transform
    |> transform.rotate(pitch, yaw, roll)

  let view = transform.view_matrix(transform)
  let viewproj = matrix.multiply(camera.proj, view)

  let forward = transform.forward(transform)
  let right = transform.right(transform)
  let up = transform.up(transform)

  Camera(..camera, transform:, forward:, right:, up:, view:, viewproj:)
}

pub fn move(camera: Camera, direction: Vec3, amount: Float) -> Camera {
  let x = direction.x *. amount
  let y = direction.y *. amount
  let z = direction.z *. amount

  let transform = camera.transform |> transform.translate(x, y, z)

  let view = transform.view_matrix(transform)
  let forward = transform.forward(transform)
  let right = transform.right(transform)
  let up = transform.up(transform)

  let viewproj = matrix.multiply(camera.proj, view)

  Camera(..camera, transform:, forward:, right:, up:, view:, viewproj:)
}

pub fn pitch(camera: Camera, deg: Float) -> Camera {
  camera |> rotate_camera(0.0 -. deg, 0.0, 0.0)
}

pub fn yaw(camera: Camera, deg: Float) -> Camera {
  camera |> rotate_camera(0.0, 0.0 -. deg, 0.0)
}

pub fn roll(camera: Camera, deg: Float) -> Camera {
  camera |> rotate_camera(0.0, 0.0, 0.0 -. deg)
}

pub fn move_forward(camera: Camera, amount: Float) -> Camera {
  camera |> move(camera.forward, amount)
}

pub fn move_right(camera: Camera, amount: Float) -> Camera {
  camera |> move(camera.right, amount)
}

pub fn move_up(camera: Camera, amount: Float) -> Camera {
  camera |> move(camera.up, amount)
}
