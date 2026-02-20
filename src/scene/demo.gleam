import fluo/color
import fluo/geometry
import fluo/renderer
import fluo/window
import gleam/int
import phong/loader
import scene/scene
import shared/transform
import shared/vector

const width = 800

const height = 800

pub fn main() {
  let scene = {
    let scale = 150.0
    let cell_size = 15.0
    let offset = scale /. 2.0

    scene.create(
      fov: 45.0,
      near: 0.1,
      far: 1000.0,
      aspect: int.to_float(width) /. int.to_float(height),
      spawn: transform.origin
        |> transform.translate_z(10.0)
        |> transform.translate_y(0.0 -. offset +. 5.0),
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
          cell_size /. scale,
          cell_size /. scale /. 100.0,
        ),
      ),
      transform.origin |> transform.scale(scale),
    )
    |> scene.add_spotlight(
      "LightCeiling",
      color: color.Color(0.9, 0.88, 0.8),
      position: vector.Vec3(0.0, offset -. 5.0, 0.0),
      direction: vector.Vec3(0.0, -1.0, 0.0),
      inner_cutoff: 10.0,
      outer_cutoff: 30.0,
      linear: 0.02,
      quadratic: 0.001,
    )
    |> scene.add_spotlight(
      "LightNorth",
      color: color.Color(1.0, 0.96, 0.9),
      position: vector.Vec3(0.0, 0.0, 0.0 -. offset +. 5.0),
      direction: vector.Vec3(0.0, 0.0, 1.0),
      inner_cutoff: 25.0,
      outer_cutoff: 80.0,
      linear: 0.01,
      quadratic: 0.0,
    )
    |> scene.add_spotlight(
      "LightSouth",
      color: color.Color(1.0, 0.96, 0.9),
      position: vector.Vec3(0.0, 0.0, offset -. 5.0),
      direction: vector.Vec3(0.0, 0.0, -1.0),
      inner_cutoff: 25.0,
      outer_cutoff: 80.0,
      linear: 0.01,
      quadratic: 0.0,
    )
    |> scene.add_spotlight(
      "LightEast",
      color: color.Color(1.0, 0.96, 0.9),
      position: vector.Vec3(offset -. 5.0, 0.0, 0.0),
      direction: vector.Vec3(-1.0, 0.0, 0.0),
      inner_cutoff: 25.0,
      outer_cutoff: 80.0,
      linear: 0.01,
      quadratic: 0.0,
    )
    |> scene.add_spotlight(
      "LightWest",
      color: color.Color(1.0, 0.96, 0.9),
      position: vector.Vec3(0.0 -. offset +. 5.0, 0.0, 0.0),
      direction: vector.Vec3(1.0, 0.0, 0.0),
      inner_cutoff: 25.0,
      outer_cutoff: 80.0,
      linear: 0.01,
      quadratic: 0.0,
    )
  }

  let scene =
    scene
    |> loader.add_model(
      transform.origin |> transform.translate_y(-70.0),
      name: "suzanne",
      path: "assets/suzanne.obj",
    )

  let window =
    window.create_window("Fluo Window", width:, height:, captured: True)

  use ctx, scene <- window.loop(window, scene)

  scene
  |> scene.update_camera_fpc(ctx, speed: 10.0, sensitivity: 0.1)
  |> scene.draw(ctx)
}
