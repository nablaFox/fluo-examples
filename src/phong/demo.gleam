import fluo/window
import gleam/int
import phong/loader
import scene/scene
import shared/transform
import shared/vector

const width = 800

const height = 800

pub fn main() {
  let scene =
    scene.create(
      fov: 45.0,
      near: 0.1,
      far: 100.0,
      aspect: int.to_float(width) /. int.to_float(height),
      scene_transform: transform.origin,
      camera_transform: transform.origin |> transform.translate_z(10.0),
    )
    |> scene.set_light_direction(vector.Vec3(0.5, 0.5, 0.0))
    |> loader.add_model(
      spawn: transform.origin,
      transform: transform.origin,
      name: "car",
      path: "assets/car.obj",
    )

  let window =
    window.create_window("Fluo Window", width, height, captured: True)

  use ctx, scene <- window.loop(window, scene)

  scene
  |> scene.update_camera_fpc(ctx, speed: 5.0, sensitivity: 0.1)
  |> scene.draw(ctx)
}
