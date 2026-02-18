import camera/camera
import fluo/color
import fluo/window
import gleam/int
import phong/loader
import phong/model
import shared/transform
import shared/vector.{Vec3}

const width = 800

const height = 800

pub fn main() {
  let camera =
    camera.create_camera(
      fov: 45.0,
      near: 0.1,
      far: 100.0,
      transform: transform.origin |> transform.translate_z(10.0),
      aspect: int.to_float(width) /. int.to_float(height),
    )

  let car = loader.load(transform.origin, "assets/car.obj")

  let light = model.Light(direction: Vec3(0.5, 1.0, 0.0), color: color.white)

  let window = window.create_window("Fluo Window", width, height)

  window.capture_mouse(window)

  use ctx, camera <- window.loop(window, camera)

  model.draw(car, camera:, light:, ambient: color.gray, ctx:)

  camera.first_person_control(camera, ctx, speed: 5.0, sensitivity: 0.1)
}
