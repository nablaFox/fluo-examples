import gleam_community/maths.{cos, degrees_to_radians, sin, tan}
import transform.{type Transform, Transform}

pub type Camera {
  Camera(
    proj: List(Float),
    position: Transform,
    rotation: Transform,
    forward: Transform,
    right: Transform,
    up: Transform,
  )
}

fn forward_from_rotation(rot: Transform) -> Transform {
  let Transform(x: pitch, y: yaw, ..) = rot

  Transform(
    sin(yaw) *. cos(pitch),
    0.0 -. sin(pitch),
    0.0 -. cos(yaw) *. cos(pitch),
  )
}

fn right_from_rotation(rot: Transform) -> Transform {
  let Transform(y: yaw, ..) = rot
  Transform(cos(yaw), 0.0, sin(yaw))
}

fn up_from_basis(forward: Transform, right: Transform) -> Transform {
  let Transform(ax, ay, az) = forward
  let Transform(bx, by, bz) = right

  Transform(ay *. bz -. az *. by, az *. bx -. ax *. bz, ax *. by -. ay *. bx)
}

pub fn create_camera(
  position position: Transform,
  rotation rotation: Transform,
  fov fov: Float,
  near near: Float,
  far far: Float,
  aspect aspect: Float,
) -> Camera {
  let proj = {
    let fov_angle = degrees_to_radians(fov)

    let top = near *. tan(fov_angle /. 2.0)
    let right = top *. aspect

    [
      near /. right,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0 -. { near /. top },
      0.0,
      0.0,
      0.0,
      0.0,
      { far +. near } /. { near -. far },
      { 2.0 *. far *. near } /. { near -. far },
      0.0,
      0.0,
      -1.0,
      0.0,
    ]
  }

  let forward = forward_from_rotation(rotation)
  let right = right_from_rotation(rotation)
  let up = up_from_basis(forward, right)

  Camera(proj, position, rotation, forward, right, up)
}

pub fn rotate_camera(camera: Camera, rotation: Transform) -> Camera {
  let forward = forward_from_rotation(rotation)
  let right = right_from_rotation(rotation)

  Camera(..camera, forward:, right:, rotation:)
}

pub fn rotate_x(camera: Camera, deg_x: Float) -> Camera {
  camera |> rotate_camera(transform.rotate_x(camera.rotation, deg_x))
}

pub fn rotate_y(camera: Camera, deg_y: Float) -> Camera {
  camera |> rotate_camera(transform.rotate_y(camera.rotation, deg_y))
}

pub fn rotate_z(camera: Camera, deg_z: Float) -> Camera {
  camera |> rotate_camera(transform.rotate_z(camera.rotation, deg_z))
}

pub fn move(camera: Camera, direction: Transform, amount: Float) -> Camera {
  let position = camera.position |> transform.move(direction, amount)

  Camera(..camera, position:)
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
