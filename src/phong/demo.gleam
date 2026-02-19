import camera/camera
import fluo/color
import fluo/window
import gleam/function
import gleam/int
import phong/loader
import phong/phong
import shared/light
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

  let car = loader.load("assets/car.obj", transform.origin)

  let light = light.Light(direction: Vec3(0.5, 1.0, 0.0), color: color.white)

  let window =
    window.create_window("Fluo Window", width, height, captured: True)

  use ctx, camera <- window.loop(window, camera)

  phong.draw(
    car,
    function.identity,
    camera:,
    light:,
    ambient: color.black,
    ctx:,
  )

  camera.first_person_control(camera, ctx, speed: 5.0, sensitivity: 0.1)
}
