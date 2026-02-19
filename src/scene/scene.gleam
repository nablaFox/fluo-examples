import camera/camera.{type Camera}
import fluo/color.{type Color}
import fluo/geometry
import fluo/mesh
import fluo/renderer.{type Renderer}
import fluo/window
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam_community/maths.{cos, degrees_to_radians}
import shared/light.{type DirectionalLight, type SpotLight}
import shared/matrix
import shared/model.{type Model}
import shared/transform.{type Transform}
import shared/vector.{type Vec3}

const max_spotlights = 16

const default_ambient = color.Color(0.05, 0.05, 0.05)

const default_light = light.DirectionalLight(
  direction: vector.Vec3(0.0, 0.0, 0.0),
  color: color.white,
)

pub type ModelMatrix =
  matrix.RawMatrix

pub type ViewProjMatrix =
  matrix.RawMatrix

pub type SceneDrawParams =
  #(ModelMatrix, ViewProjMatrix)

pub type SceneFrameParams {
  SceneFrameParams(
    camera_position: Vec3,
    ambient: Color,
    light: DirectionalLight,
    spotlights_count: Int,
    spotlights: List(SpotLight),
  )
}

pub type SceneDrawable =
  model.Drawable(SceneFrameParams, SceneDrawParams)

pub type SceneModel =
  model.Model(SceneFrameParams, SceneDrawParams)

pub type SceneRenderer(material) =
  Renderer(material, SceneFrameParams, SceneDrawParams)

pub type Scene {
  Scene(
    camera: Camera,
    models: Dict(String, Model(SceneFrameParams, SceneDrawParams)),
    spotlights: Dict(String, SpotLight),
    light: DirectionalLight,
    ambient: Color,
  )
}

pub fn create(
  fov fov: Float,
  near near: Float,
  far far: Float,
  aspect aspect: Float,
  spawn camera_transform: Transform,
) {
  let camera =
    camera.create_camera(
      fov: fov,
      near: near,
      far: far,
      transform: camera_transform,
      aspect: aspect,
    )

  Scene(
    camera:,
    models: dict.new(),
    spotlights: dict.new(),
    light: default_light,
    ambient: default_ambient,
  )
}

pub fn draw(scene: Scene, ctx ctx: window.Context) -> Scene {
  let Scene(models:, ..) = scene

  {
    use model <- list.each(dict.keys(models))
    draw_model(scene, model, function.identity, ctx)
  }

  scene
}

pub fn draw_model(
  scene: Scene,
  model model_name: String,
  transformer transformer: fn(Transform) -> Transform,
  ctx ctx: window.Context,
) -> Scene {
  let Scene(camera:, light:, ambient:, spotlights:, models:) = scene

  let assert Ok(model) = dict.get(models, model_name)
    as { "Tried to draw model that does not exist: " <> model_name }

  let spotlights = dict.values(spotlights)
  let spotlights_count = list.length(spotlights)

  let camera_position = camera.position(camera)

  let params =
    SceneFrameParams(
      camera_position:,
      light:,
      ambient:,
      spotlights_count:,
      spotlights:,
    )

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
  scene: Scene,
  ctx: window.Context,
  speed speed: Float,
  sensitivity sensitivity: Float,
) -> Scene {
  let camera =
    camera.first_person_control(scene.camera, ctx, speed:, sensitivity:)

  Scene(..scene, camera:)
}

pub fn add_model(
  scene: Scene,
  name: String,
  model: Model(SceneFrameParams, SceneDrawParams),
  transformer: fn(transform.Transform) -> Transform,
) -> Scene {
  let transform = model.transform |> transformer

  let model = model.Model(..model, transform:)

  let models = dict.insert(scene.models, name, model)

  Scene(..scene, models:)
}

pub fn create_model(
  scene: Scene,
  name: String,
  mesh: mesh.Mesh,
  renderer: SceneRenderer(material),
  transform: transform.Transform,
) -> Scene {
  let model = model.create(mesh, renderer, transform)

  add_model(scene, name, model, function.identity)
}

pub fn add_shape(
  scene: Scene,
  name: String,
  shape: geometry.Geometry,
  renderer: SceneRenderer(material),
  transform: transform.Transform,
) -> Scene {
  let model = model.create(geometry.to_mesh(shape), renderer, transform)
  add_model(scene, name, model, function.identity)
}

pub fn create_shape(
  scene: Scene,
  name: String,
  shape: geometry.Geometry,
  renderer: SceneRenderer(material),
  transform: transform.Transform,
) -> Scene {
  let model = model.create_shape(shape, renderer, transform)
  add_model(scene, name, model, function.identity)
}

pub fn remove_model(scene: Scene, name: String) -> Scene {
  let models = dict.delete(scene.models, name)
  Scene(..scene, models:)
}

pub fn set_light_color(scene: Scene, color: Color) -> Scene {
  Scene(..scene, light: light.DirectionalLight(..scene.light, color:))
}

pub fn set_light_direction(scene: Scene, direction: Vec3) -> Scene {
  Scene(..scene, light: light.DirectionalLight(..scene.light, direction:))
}

pub fn add_spotlight(
  scene: Scene,
  name name: String,
  color color: Color,
  position position: Vec3,
  direction direction: Vec3,
  inner_cutoff inner_cutoff: Float,
  outer_cutoff outer_cutoff: Float,
  linear linear: Float,
  quadratic quadratic: Float,
) -> Scene {
  let Scene(spotlights:, ..) = scene

  assert dict.size(spotlights) < max_spotlights
    as {
      "Cannot add more than " <> int.to_string(max_spotlights) <> " spotlights"
    }

  let outer_cutoff = cos(degrees_to_radians(outer_cutoff))
  let inner_cutoff = cos(degrees_to_radians(inner_cutoff))

  let spotlight =
    light.SpotLight(
      position:,
      direction:,
      color:,
      inner_cutoff:,
      outer_cutoff:,
      linear:,
      quadratic:,
    )

  let spotlights = dict.insert(spotlights, name, spotlight)

  Scene(..scene, spotlights:)
}

pub fn remove_spotlight(scene: Scene, name: String) -> Scene {
  let spotlights = dict.delete(scene.spotlights, name)
  Scene(..scene, spotlights:)
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

// will draw the current scene to screen
pub fn display(scene: Scene, ctx: window.Context) {
  todo
}
