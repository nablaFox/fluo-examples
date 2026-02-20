import fluo/color
import fluo/geometry
import fluo/renderer
import gleam/int
import scene/scene
import shared/transform
import shared/vector

pub const room_size = 150.0

pub const cell_size = 15.0

pub const lift = 5.0

pub const top = 145.0

pub const right = 75.0

pub const left = -75.0

pub const front = -75.0

pub const back = 75.0

pub fn create_room(
  transform room_transform: transform.Transform,
  window_width width: Int,
  window_height height: Int,
  color light_color: color.Color,
) -> scene.Scene {
  let l = {
    let assert Ok(sqrt3) = int.square_root(3)
    1.0 /. sqrt3
  }

  let linear = 0.015
  let quadratic = 0.0
  let inner_cutoff = 30.0
  let outer_cutoff = 60.0

  scene.create(
    fov: 45.0,
    near: 0.1,
    far: 1000.0,
    aspect: int.to_float(width) /. int.to_float(height),
    scene_transform: room_transform |> transform.translate_y(lift),
    camera_transform: transform.origin |> transform.translate_z(10.0),
  )
  |> scene.add_shape(
    "room",
    geometry.cube,
    renderer.create_renderer(
      vert: "default.vert",
      frag: "grid.frag",
      material: #(
        color.multiply(color.white, 0.8),
        color.black,
        cell_size /. room_size,
        cell_size /. room_size /. 100.0,
      ),
    ),
    transform: transform.origin |> transform.scale(room_size),
    spawn: transform.origin
      |> transform.translate_y(0.0 -. lift +. room_size /. 2.0),
  )
  |> scene.add_spotlight(
    "LightCorner1",
    color: light_color,
    position: vector.Vec3(left, top, front),
    direction: vector.Vec3(l, 0.0 -. l, l),
    inner_cutoff:,
    outer_cutoff:,
    linear:,
    quadratic:,
  )
  |> scene.add_spotlight(
    "LightCorner2",
    color: light_color,
    position: vector.Vec3(right, top, front),
    direction: vector.Vec3(0.0 -. l, 0.0 -. l, l),
    inner_cutoff:,
    outer_cutoff:,
    linear:,
    quadratic:,
  )
  |> scene.add_spotlight(
    "LightCorner3",
    color: light_color,
    position: vector.Vec3(right, top, back),
    direction: vector.Vec3(0.0 -. l, 0.0 -. l, 0.0 -. l),
    inner_cutoff:,
    outer_cutoff:,
    linear:,
    quadratic:,
  )
  |> scene.add_spotlight(
    "LightCorner4",
    color: light_color,
    position: vector.Vec3(left, top, back),
    direction: vector.Vec3(l, 0.0 -. l, 0.0 -. l),
    inner_cutoff:,
    outer_cutoff:,
    linear:,
    quadratic:,
  )
  |> scene.add_spotlight(
    "LightCorner5",
    color: light_color,
    position: vector.Vec3(left, 0.0, back),
    direction: vector.Vec3(l, l, 0.0 -. l),
    inner_cutoff:,
    outer_cutoff:,
    linear:,
    quadratic:,
  )
  |> scene.add_spotlight(
    "LightCorner6",
    color: light_color,
    position: vector.Vec3(right, 0.0, back),
    direction: vector.Vec3(0.0 -. l, l, 0.0 -. l),
    inner_cutoff:,
    outer_cutoff:,
    linear:,
    quadratic:,
  )
}
