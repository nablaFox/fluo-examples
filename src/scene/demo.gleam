import fluo/color
import fluo/window
import phong/loader
import scene/room
import scene/scene
import shared/transform

const width = 800

const height = 800

pub fn main() {
  let scene =
    room.create_room(
      transform: transform.origin,
      window_width: width,
      window_height: height,
      color: color.Color(0.9, 0.88, 0.8),
    )
    |> loader.add_model(
      transform: transform.origin,
      spawn: transform.origin,
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
