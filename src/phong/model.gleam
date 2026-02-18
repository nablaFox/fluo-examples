import camera/camera.{type Camera}
import fluo/color.{type Color}
import fluo/mesh.{type Mesh}
import fluo/renderer.{type Renderer}
import fluo/texture.{type Texture}
import fluo/window.{type Context}
import gleam/dict
import gleam/list
import gleam/result
import shared/matrix.{type RawMatrix}
import shared/transform.{type Transform}
import shared/vector.{type Vec3}

const vertex_shader = "phong.vert"

const fragment_shader = "phong.frag"

pub type Light {
  Light(direction: Vec3, color: Color)
}

pub type PhongMaterial {
  PhongMaterial(
    albedo: Texture,
    diffuse: Color,
    specular: Color,
    emissive: Color,
    transmission: Color,
    shininess: Float,
    opacity: Float,
    ior: Float,
    illum: Int,
  )
}

pub opaque type PhongFrameParams {
  PhongFrameParams(
    viewproj: RawMatrix,
    camera_pos: Vec3,
    light_dir: Vec3,
    light_color: Color,
    ambient_color: Color,
  )
}

pub type PhongRenderer =
  Renderer(PhongMaterial, PhongFrameParams, RawMatrix)

pub type Drawable {
  Drawable(mesh: Mesh, renderer: PhongRenderer)
}

pub type PhongModel {
  PhongModel(drawables: List(Drawable), transform: Transform)
}

pub fn create_frame_params(
  camera: Camera,
  light: Light,
  ambient: Color,
) -> PhongFrameParams {
  PhongFrameParams(
    viewproj: camera.viewproj |> list.flatten,
    light_dir: light.direction,
    light_color: light.color,
    ambient_color: color.multiply(ambient, 0.01),
    camera_pos: camera.position(camera),
  )
}

pub fn draw(
  model model: PhongModel,
  camera camera: Camera,
  light light: Light,
  ambient ambient: Color,
  ctx ctx: Context,
) {
  let params = create_frame_params(camera, light, ambient)

  let model_matrix = model.transform |> transform.to_matrix |> list.flatten

  use drawable <- list.each(model.drawables)

  drawable.mesh
  |> window.draw(ctx, drawable.renderer, params, model_matrix)
}

pub fn drawer(
  model: PhongModel,
  camera camera: Camera,
  light light: Light,
  ambient ambient: Color,
  ctx ctx: Context,
) -> fn(Transform) -> Nil {
  let params = create_frame_params(camera, light, ambient)

  let drawers = {
    use drawable <- list.map(model.drawables)
    window.drawer(ctx, drawable.renderer, params)
  }

  let drawers = dict.from_list(list.zip(model.drawables, drawers))

  fn(transform: Transform) {
    let model_matrix = transform |> transform.to_matrix |> list.flatten

    use drawable <- list.each(model.drawables)

    let drawer = result.unwrap(dict.get(drawers, drawable), fn(_, _) { Nil })

    drawer(drawable.mesh, model_matrix)
  }
}

pub fn translate(
  model: PhongModel,
  x x: Float,
  y y: Float,
  z z: Float,
) -> PhongModel {
  let PhongModel(drawables, transform) = model

  PhongModel(drawables, transform |> transform.translate(x, y, z))
}

pub fn rotate(
  model: PhongModel,
  pitch pitch: Float,
  yaw yaw: Float,
  roll roll: Float,
) -> PhongModel {
  let PhongModel(drawables, transform) = model

  PhongModel(drawables, transform |> transform.rotate(pitch, yaw, roll))
}

pub fn translate_x(model: PhongModel, x: Float) -> PhongModel {
  model |> translate(x, 0.0, 0.0)
}

pub fn translate_y(model: PhongModel, y: Float) -> PhongModel {
  model |> translate(0.0, y, 0.0)
}

pub fn translate_z(model: PhongModel, z: Float) -> PhongModel {
  model |> translate(0.0, 0.0, z)
}

pub fn rotate_pitch(model: PhongModel, deg_x: Float) -> PhongModel {
  model |> rotate(deg_x, 0.0, 0.0)
}

pub fn rotate_yaw(model: PhongModel, deg_y: Float) -> PhongModel {
  model |> rotate(0.0, deg_y, 0.0)
}

pub fn rotate_roll(model: PhongModel, deg_z: Float) -> PhongModel {
  model |> rotate(0.0, 0.0, deg_z)
}

pub fn create_default_material() -> PhongMaterial {
  let albedo: Texture = texture.create_from_color(color.white)

  PhongMaterial(
    albedo: albedo,
    diffuse: color.Color(1.0, 1.0, 1.0),
    specular: color.Color(0.04, 0.04, 0.04),
    emissive: color.black,
    transmission: color.white,
    shininess: 32.0,
    opacity: 1.0,
    ior: 1.0,
    illum: 2,
  )
}

pub fn create_phong_renderer(material: PhongMaterial) -> PhongRenderer {
  renderer.create_renderer(
    vert: vertex_shader,
    frag: fragment_shader,
    material:,
  )
}

pub fn create_default(mesh: Mesh) -> PhongModel {
  let material = create_default_material()
  let drawable = Drawable(mesh, create_phong_renderer(material))

  PhongModel([drawable], transform.origin)
}
