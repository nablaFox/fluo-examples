import camera/camera.{type Camera}
import fluo/color
import fluo/geometry
import fluo/window
import gleam/dict
import gleam/function
import gleam/list
import phong/loader
import phong/model
import shared/transform
import shared/vector

pub type Scene {
  Scene(
    camera: Camera,
    light: model.Light,
    ambient: color.Color,
    models: dict.Dict(String, model.PhongModel),
  )
}

pub fn create(
  fov fov: Float,
  near near: Float,
  far far: Float,
  aspect aspect: Float,
  camera_transform camera_transform: transform.Transform,
  light_dir light_dir: vector.Vec3,
  light_color light_color: color.Color,
  ambient ambient: color.Color,
) {
  let camera =
    camera.create_camera(
      fov: fov,
      near: near,
      far: far,
      transform: camera_transform,
      aspect: aspect,
    )

  let light = model.Light(direction: light_dir, color: light_color)

  Scene(camera, light, ambient, dict.new())
}

pub fn draw_model(
  scene: Scene,
  model model_name: String,
  transformer transformer: fn(transform.Transform) -> transform.Transform,
  ctx ctx: window.Context,
) -> Scene {
  let Scene(camera, light, ambient, models) = scene

  let assert Ok(model) = dict.get(models, model_name)
    as { "Tried to draw model that does not exist: " <> model_name }

  model.draw(model:, camera:, light:, ambient:, transformer:, ctx:)

  scene
}

pub fn draw(scene: Scene, ctx ctx: window.Context) -> Scene {
  let Scene(models:, ..) = scene

  {
    use model <- list.each(dict.keys(models))

    draw_model(scene, model, function.identity, ctx)
  }

  scene
}

pub fn update_camera_fpc(
  scene: Scene,
  ctx: window.Context,
  speed speed: Float,
  sensitivity sensitivity: Float,
) -> Scene {
  let camera =
    camera.first_person_control(scene.camera, ctx, speed:, sensitivity:)

  Scene(..scene, camera:)
}

pub fn load_model(
  scene: Scene,
  name name: String,
  path path: String,
  transform transform: transform.Transform,
) -> Scene {
  let model = loader.load(path, transform)
  add_model(scene, name, model, function.identity)
}

pub fn add_model(
  scene: Scene,
  name: String,
  model: model.PhongModel,
  transformer: fn(transform.Transform) -> transform.Transform,
) -> Scene {
  let transform = model.transform |> transformer

  let model = model.PhongModel(..model, transform:)

  let models = dict.insert(scene.models, name, model)

  Scene(..scene, models:)
}

pub fn add_shape(
  scene: Scene,
  name: String,
  geometry: geometry.Geometry,
  color: color.Color,
  transform: transform.Transform,
) -> Scene {
  let model = model.create_shape(geometry, color, transform)
  add_model(scene, name, model, function.identity)
}

pub fn translate(
  scene: Scene,
  model model_name: String,
  x x: Float,
  y y: Float,
  z z: Float,
) -> Scene {
  let model = dict.get(scene.models, model_name)

  case model {
    Ok(model) -> {
      let model = model |> model.translate(x, y, z)
      let models = dict.insert(scene.models, model_name, model)

      Scene(..scene, models:)
    }
    _ -> scene
  }
}

pub fn rotate(
  scene: Scene,
  model model_name: String,
  pitch pitch: Float,
  yaw yaw: Float,
  roll roll: Float,
) -> Scene {
  let model = dict.get(scene.models, model_name)

  case model {
    Ok(model) -> {
      let model = model |> model.rotate(pitch, yaw, roll)
      let models = dict.insert(scene.models, model_name, model)

      Scene(..scene, models:)
    }
    _ -> scene
  }
}

pub fn rotate_pitch(scene: Scene, model: String, pitch: Float) -> Scene {
  rotate(scene, model, pitch, 0.0, 0.0)
}

pub fn rotate_yaw(scene: Scene, model: String, yaw: Float) -> Scene {
  rotate(scene, model, 0.0, yaw, 0.0)
}

pub fn rotate_roll(scene: Scene, model: String, roll: Float) -> Scene {
  rotate(scene, model, 0.0, 0.0, roll)
}

pub fn translate_x(scene: Scene, model: String, x: Float) -> Scene {
  translate(scene, model, x, 0.0, 0.0)
}

pub fn translate_y(scene: Scene, model: String, y: Float) -> Scene {
  translate(scene, model, 0.0, y, 0.0)
}

pub fn translate_z(scene: Scene, model: String, z: Float) -> Scene {
  translate(scene, model, 0.0, 0.0, z)
}
