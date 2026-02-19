import camera/camera.{type Camera}
import fluo/geometry
import fluo/mesh
import fluo/renderer.{type Renderer}
import fluo/window
import gleam/dict
import gleam/function
import gleam/list
import shared/matrix
import shared/model.{type Model}
import shared/transform.{type Transform}

pub type ModelMatrix =
  matrix.RawMatrix

pub type ViewProjMatrix =
  matrix.RawMatrix

pub type SceneDrawParams =
  #(ModelMatrix, ViewProjMatrix)

pub type Scene(frame_params) {
  Scene(
    camera: Camera,
    params: frame_params,
    models: dict.Dict(String, Model(frame_params, SceneDrawParams)),
  )
}

pub fn create(
  fov fov: Float,
  near near: Float,
  far far: Float,
  aspect aspect: Float,
  camera_transform camera_transform: Transform,
  params params: params,
) {
  let camera =
    camera.create_camera(
      fov: fov,
      near: near,
      far: far,
      transform: camera_transform,
      aspect: aspect,
    )

  Scene(camera, params, dict.new())
}

pub fn draw(scene: Scene(params), ctx ctx: window.Context) -> Scene(params) {
  let Scene(models:, ..) = scene

  {
    use model <- list.each(dict.keys(models))
    draw_model(scene, model, function.identity, ctx)
  }

  scene
}

pub fn draw_model(
  scene: Scene(params),
  model model_name: String,
  transformer transformer: fn(Transform) -> Transform,
  ctx ctx: window.Context,
) -> Scene(params) {
  let Scene(params:, models:, camera:) = scene

  let assert Ok(model) = dict.get(models, model_name)
    as { "Tried to draw model that does not exist: " <> model_name }

  let viewproj = camera.viewproj |> list.flatten

  let model_matrix =
    model.transform
    |> transformer
    |> transform.to_matrix
    |> list.flatten

  model.draw(model, params, #(viewproj, model_matrix), ctx)

  scene
}

pub fn update_camera_fpc(
  scene: Scene(params),
  ctx: window.Context,
  speed speed: Float,
  sensitivity sensitivity: Float,
) -> Scene(params) {
  let camera =
    camera.first_person_control(scene.camera, ctx, speed:, sensitivity:)

  Scene(..scene, camera:)
}

pub fn add_model(
  scene: Scene(params),
  name: String,
  model: Model(params, SceneDrawParams),
  transformer: fn(transform.Transform) -> Transform,
) -> Scene(params) {
  let transform = model.transform |> transformer

  let model = model.Model(..model, transform:)

  let models = dict.insert(scene.models, name, model)

  Scene(..scene, models:)
}

pub fn create_model(
  scene: Scene(params),
  name: String,
  mesh: mesh.Mesh,
  renderer: Renderer(material, params, SceneDrawParams),
  transform: transform.Transform,
) -> Scene(params) {
  let model = model.create(mesh, renderer, transform)

  add_model(scene, name, model, function.identity)
}

pub fn add_shape(
  scene: Scene(params),
  name: String,
  shape: geometry.Geometry,
  renderer: Renderer(material, params, SceneDrawParams),
  transform: transform.Transform,
) -> Scene(params) {
  let model = model.create(geometry.to_mesh(shape), renderer, transform)
  add_model(scene, name, model, function.identity)
}

pub fn create_shape(
  scene: Scene(params),
  name: String,
  shape: geometry.Geometry,
  renderer: Renderer(material, params, SceneDrawParams),
  transform: transform.Transform,
) -> Scene(params) {
  let model = model.create_shape(shape, renderer, transform)
  add_model(scene, name, model, function.identity)
}

pub fn remove_model(scene: Scene(params), name: String) -> Scene(params) {
  let models = dict.delete(scene.models, name)
  Scene(..scene, models:)
}

pub fn translate(
  scene: Scene(params),
  model model_name: String,
  x x: Float,
  y y: Float,
  z z: Float,
) -> Scene(params) {
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
  scene: Scene(params),
  model model_name: String,
  pitch pitch: Float,
  yaw yaw: Float,
  roll roll: Float,
) -> Scene(params) {
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

pub fn rotate_pitch(
  scene: Scene(params),
  model: String,
  pitch: Float,
) -> Scene(params) {
  rotate(scene, model, pitch, 0.0, 0.0)
}

pub fn rotate_yaw(
  scene: Scene(params),
  model: String,
  yaw: Float,
) -> Scene(params) {
  rotate(scene, model, 0.0, yaw, 0.0)
}

pub fn rotate_roll(
  scene: Scene(params),
  model: String,
  roll: Float,
) -> Scene(params) {
  rotate(scene, model, 0.0, 0.0, roll)
}

pub fn translate_x(
  scene: Scene(params),
  model: String,
  x: Float,
) -> Scene(params) {
  translate(scene, model, x, 0.0, 0.0)
}

pub fn translate_y(
  scene: Scene(params),
  model: String,
  y: Float,
) -> Scene(params) {
  translate(scene, model, 0.0, y, 0.0)
}

pub fn translate_z(
  scene: Scene(params),
  model: String,
  z: Float,
) -> Scene(params) {
  translate(scene, model, 0.0, 0.0, z)
}
