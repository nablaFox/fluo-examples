import fluo/key.{type Key}
import fluo/mesh
import fluo/renderer.{type Renderer}
import fluo/texture.{type Texture}
import fluo/window.{Context, drawer}
import fpc/camera
import fpc/transform
import gleam/int
import gleam/list

const width = 800

const height = 600

const speed = 6.0

const sensitivity = 0.06

const rotspeed = 90.0

pub fn main() {
  let camera =
    camera.create_camera(
      fov: 45.0,
      near: 0.1,
      far: 100.0,
      transform: transform.origin(),
      aspect: int.to_float(width) /. int.to_float(height),
    )

  let window = window.create_window("Fluo Window", width, height)

  let suzanne = mesh.load_obj("assets/cube.obj")

  let texture = texture.load_texture("assets/white.jpeg")

  let renderer: Renderer(
    #(List(Float), Float, Texture),
    List(Float),
    List(Float),
  ) =
    renderer.create_renderer(
      vert: "shader.vert",
      frag: "outline.frag",
      material: #([0.0, 0.0, 0.0, 1.0], 0.01, texture),
    )

  let transform = transform.origin() |> transform.translate_z(-3.0)

  let axis = fn(neg: Bool, pos: Bool) -> Float {
    case neg, pos {
      True, False -> -1.0
      False, True -> 1.0
      _, _ -> 0.0
    }
  }

  use ctx, state <- window.loop(window, #(camera, transform))

  let #(camera, transform) = state

  let Context(delta:, keys_down: keys, mouse_delta:, ..) = ctx

  let is_down = fn(key: Key) { keys |> list.contains(key) }

  let strafe = axis(is_down(key.A), is_down(key.D))

  let forward = axis(is_down(key.S), is_down(key.W))

  let vertical = axis(is_down(key.LShift), is_down(key.Space))

  let camera = case mouse_delta {
    window.Position(x, y) ->
      camera
      |> camera.pitch(y *. sensitivity)
      |> camera.yaw(x *. sensitivity)
  }

  let camera =
    camera
    |> camera.move_right(strafe *. speed *. delta)
    |> camera.move_forward(forward *. speed *. delta)
    |> camera.move_up(vertical *. speed *. delta)

  case ctx.keys_down {
    [key.Enter] -> ctx.capture_mouse()
    [key.Escape] -> ctx.release_mouse()
    _ -> Nil
  }

  let yaw_dir = axis(is_down(key.Left), is_down(key.Right))

  let pitch_dir = axis(is_down(key.Up), is_down(key.Down))

  let transform =
    transform
    |> transform.rotate_yaw(yaw_dir *. rotspeed *. delta)
    |> transform.rotate_pitch(pitch_dir *. rotspeed *. delta)

  let viewproj = camera.viewproj |> list.flatten
  let model = transform |> transform.model_matrix |> list.flatten

  suzanne |> drawer(ctx, renderer, viewproj)(model)

  #(camera, transform)
}
