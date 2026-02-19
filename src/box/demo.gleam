import fluo/color
import fluo/geometry
import fluo/renderer
import fluo/window
import gleam/int
import phong/loader
import scene/scene
import shared/transform
import shared/vector.{Vec3}

const width = 800

const height = 800

pub fn main() {
  let scene = {
    let scale = 150.0
    let cell_size = 15.0

    scene.create(
      fov: 45.0,
      near: 0.1,
      far: 1000.0,
      aspect: int.to_float(width) /. int.to_float(height),
      camera_transform: transform.origin |> transform.translate_z(10.0),
      light_dir: Vec3(1.0, 1.0, 0.0),
      light_color: color.white,
      ambient_color: color.multiply(color.white, 0.1),
      spot_lights: [],
    )
    |> scene.add_shape(
      "room",
      geometry.cube,
      renderer.create_renderer(
        vert: "default.vert",
        frag: "grid.frag",
        material: #(
          color.white,
          color.black,
          cell_size /. scale,
          cell_size /. scale /. 100.0,
        ),
      ),
      transform.origin |> transform.scale(scale),
    )
  }

  let scene =
    loader.add_model(
      scene,
      transform.origin,
      name: "car",
      path: "assets/suzanne.obj",
    )

  let window =
    window.create_window("Fluo Window", width:, height:, captured: True)

  use ctx, scene <- window.loop(window, scene)

  scene
  |> scene.update_camera_fpc(ctx, speed: 5.0, sensitivity: 0.1)
  |> scene.draw(ctx)
}
