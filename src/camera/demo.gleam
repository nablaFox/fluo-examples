import camera/camera
import fluo/color
import fluo/geometry
import fluo/key
import fluo/renderer.{type Renderer}
import fluo/texture.{type Texture}
import fluo/window.{drawer}
import gleam/int
import gleam/list
import shared/matrix
import shared/transform

const width = 800

const height = 600

const speed = 90.0

pub fn main() {
  let camera =
    camera.create_camera(
      fov: 45.0,
      near: 0.1,
      far: 100.0,
      transform: transform.origin |> transform.translate_z(10.0),
      aspect: int.to_float(width) /. int.to_float(height),
    )

  let window =
    window.create_window("Fluo Window", width, height, captured: True)

  let cube = geometry.create_cube()

  let texture = texture.create_from_color(color.white)

  let renderer: Renderer(
    #(List(Float), Float, Texture),
    matrix.RawMatrix,
    matrix.RawMatrix,
  ) =
    renderer.create_renderer(
      vert: "shader.vert",
      frag: "outline.frag",
      material: #([0.0, 0.0, 0.0, 1.0], 0.01, texture),
    )

  use ctx, state <- window.loop(window, #(camera, transform.origin))

  let #(camera, transform) = state

  let yaw_dir = ctx.axis(key.Left, key.Right)

  let pitch_dir = ctx.axis(key.Up, key.Down)

  let transform =
    transform
    |> transform.rotate_yaw(yaw_dir *. speed *. ctx.delta)
    |> transform.rotate_pitch(pitch_dir *. speed *. ctx.delta)

  let draw = drawer(ctx, renderer, camera.viewproj |> list.flatten)

  let range = int.range(list.prepend, from: -1, to: 2, with: [])

  let camera =
    camera.first_person_control(camera, ctx, sensitivity: 0.1, speed: 5.0)

  {
    use x <- list.map(range)

    use y <- list.map(range)

    draw(
      cube,
      transform
        |> transform.translate_x(int.to_float(x) *. 1.5)
        |> transform.translate_y(int.to_float(y) *. 1.5)
        |> transform.to_matrix
        |> list.flatten,
    )
  }

  #(camera, transform)
}
