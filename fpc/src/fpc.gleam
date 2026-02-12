import fluo/mesh
import fluo/render
import fluo/texture
import fluo/window.{Context}
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
      fov: 70.0,
      near: 0.1,
      far: 100.0,
      transform: transform.origin(),
      aspect: int.to_float(width) /. int.to_float(height),
    )

  let window = window.create_window("Fluo Window", width, height)

  let suzanne = mesh.load_obj("assets/suzanne.obj")

  let texture = texture.load_texture("assets/brick.jpeg")

  let renderer =
    render.create_renderer(
      vert: "shader.vert",
      frag: "shader.frag",
      material: #(texture),
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

  let is_down = fn(k: window.Key) { keys |> list.contains(k) }

  let strafe = axis(is_down(window.KeyA), is_down(window.KeyD))

  let forward = axis(is_down(window.KeyS), is_down(window.KeyW))

  let vertical = axis(is_down(window.LShift), is_down(window.Space))

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
    [window.Enter] -> ctx.capture_mouse()
    [window.Escape] -> ctx.release_mouse()
    _ -> Nil
  }

  let yaw_dir = axis(is_down(window.ArrowLeft), is_down(window.ArrowRight))

  let pitch_dir = axis(is_down(window.ArrowUp), is_down(window.ArrowDown))

  let transform =
    transform
    |> transform.rotate_yaw(yaw_dir *. rotspeed *. delta)
    |> transform.rotate_pitch(pitch_dir *. rotspeed *. delta)

  ctx.draw(renderer, suzanne, #(
    camera.viewproj |> list.flatten,
    transform |> transform.model_matrix |> list.flatten,
  ))

  #(camera, transform)
}
