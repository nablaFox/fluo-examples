import fluo/color.{type Color}
import gleam/function
import phong/loader
import phong/phong.{type PhongFrameParams, PhongFrameParams}
import scene/scene.{type Scene}
import shared/transform.{type Transform}
import shared/vector.{type Vec3}

pub type PhongScene =
  Scene(PhongFrameParams)

pub fn create(
  fov fov: Float,
  near near: Float,
  far far: Float,
  aspect aspect: Float,
  camera_transform camera_transform: Transform,
  light_dir light_dir: Vec3,
  light_color light_color: Color,
  ambient ambient: Color,
) -> PhongScene {
  let params =
    PhongFrameParams(
      camera_pos: transform.position(camera_transform),
      light_dir:,
      light_color:,
      ambient_color: ambient,
    )

  scene.create(fov:, near:, far:, aspect:, camera_transform:, params:)
}

pub fn load_model(
  scene: PhongScene,
  name name: String,
  path path: String,
  transform transform: Transform,
) -> PhongScene {
  let model = loader.load(path, transform)

  scene.add_model(scene, name, model, function.identity)
}
