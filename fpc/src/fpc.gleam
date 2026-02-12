import camera
import fluo/mesh
import fluo/render
import fluo/texture
import fluo/window.{Context}
import gleam/int
import gleam/list
import transform.{Transform}

const width = 800

const height = 600

const speed = 6.0

const sensitivity = 0.06

pub fn main() {
  let camera =
    camera.create_camera(
      fov: 70.0,
      near: 0.1,
      far: 100.0,
      aspect: int.to_float(width) /. int.to_float(height),
      position: Transform(0.0, 0.0, 3.0),
      rotation: Transform(0.0, 0.0, 0.0),
    )

  let window = window.create_window("Fluo Window", width, height)

  let suzanne = mesh.load_obj("assets/suzanne.obj")

  let texture = texture.load_texture("assets/brick.jpeg")

  let renderer =
    render.create_renderer(#(texture), vert: "vert.spv", frag: "frag.spv")

  let axis = fn(neg: Bool, pos: Bool) -> Float {
    case neg, pos {
      True, False -> -1.0
      False, True -> 1.0
      _, _ -> 0.0
    }
  }

  use ctx, camera <- window.loop(window, camera)

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

  ctx.draw(renderer, suzanne, #(camera.viewproj |> list.flatten))

  camera
}
