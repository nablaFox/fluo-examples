import fluo/color
import fluo/geometry
import fluo/renderer
import fluo/texture
import fluo/window
import gleam/function
import gleam/int
import scene/scene
import shared/model
import shared/transform

const width = 800

const height = 800

pub fn main() {
  let renderer =
    renderer.create_renderer(
      vert: "default.vert",
      frag: "shader.frag",
      material: texture.create_from_color(color.white),
    )

  let cube = model.create_shape(geometry.cube, renderer, transform.origin)

  let scene =
    scene.create(
      fov: 45.0,
      near: 0.1,
      far: 100.0,
      aspect: int.to_float(width) /. int.to_float(height),
      spawn: transform.origin |> transform.translate_z(10.0),
    )
    |> scene.add_model("cube1", cube, function.identity)
    |> scene.add_model("cube2", cube, transform.translate_x(_, 2.0))

  let window =
    window.create_window("Fluo Window", width:, height:, captured: True)

  use ctx, scene <- window.loop(window, scene)

  scene
  |> scene.rotate_pitch("cube2", 90.0 *. ctx.delta)
  |> scene.draw_model("cube1", transform.translate_y(_, -2.0), ctx)
  |> scene.draw_model("cube1", transform.translate_z(_, -2.0), ctx)
  |> scene.update_camera_fpc(ctx, speed: 5.0, sensitivity: 0.1)
  |> scene.draw(ctx)
}
