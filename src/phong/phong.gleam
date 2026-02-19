import camera/camera.{type Camera}
import fluo/color.{type Color}
import fluo/geometry.{type Geometry}
import fluo/mesh.{type Mesh}
import fluo/renderer.{type Renderer}
import fluo/texture.{type Texture}
import fluo/window
import gleam/list
import gleam/option
import shared/light.{type Light}
import shared/matrix.{type RawMatrix}
import shared/model.{type Drawable, type Model}
import shared/transform.{type Transform}
import shared/vector.{type Vec3}

const vertex_shader = "phong.vert"

const fragment_shader = "phong.frag"

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

pub type PhongFrameParams {
  PhongFrameParams(
    camera_pos: Vec3,
    light_dir: Vec3,
    light_color: Color,
    ambient_color: Color,
  )
}

pub type PhongDrawParams =
  #(RawMatrix, RawMatrix)

pub type PhongRenderer =
  Renderer(PhongMaterial, PhongFrameParams, PhongDrawParams)

pub type PhongDrawable =
  Drawable(PhongFrameParams, PhongDrawParams)

pub type PhongModel =
  Model(PhongFrameParams, PhongDrawParams)

pub fn create(
  mesh: Mesh,
  transform: Transform,
  albedo: option.Option(Texture),
  diffuse: Color,
  specular: Color,
  emissive: Color,
  transmission: Color,
  shininess: Float,
  opacity: Float,
  ior: Float,
) -> PhongModel {
  let albedo = option.unwrap(albedo, texture.create_from_color(color.white))

  let illum = case opacity <. 1.0 {
    True -> 4
    False -> 2
  }

  let material =
    PhongMaterial(
      albedo:,
      diffuse:,
      specular:,
      emissive:,
      transmission:,
      shininess:,
      opacity:,
      ior:,
      illum:,
    )

  let renderer = create_renderer(material)

  model.create(mesh, renderer, transform)
}

pub fn create_shape(
  shape: Geometry,
  color: Color,
  transform: Transform,
) -> PhongModel {
  let mesh = mesh.create(shape.vertices, shape.indices)

  let material =
    PhongMaterial(
      ..create_default_material(),
      diffuse: color,
      specular: color.Color(0.0, 0.0, 0.0),
      shininess: 1.0,
    )

  let renderer = create_renderer(material)

  model.create(mesh, renderer, transform)
}

pub fn create_default_material() -> PhongMaterial {
  PhongMaterial(
    albedo: texture.create_from_color(color.white),
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

pub fn create_renderer(material: PhongMaterial) -> PhongRenderer {
  renderer.create_renderer(
    vert: vertex_shader,
    frag: fragment_shader,
    material:,
  )
}

pub fn draw(
  model model: PhongModel,
  camera camera: Camera,
  light light: Light,
  ambient ambient: Color,
  transformer transformer: fn(Transform) -> Transform,
  ctx ctx: window.Context,
) {
  let params =
    PhongFrameParams(
      camera_pos: camera.position(camera),
      light_dir: light.direction,
      light_color: light.color,
      ambient_color: ambient,
    )

  let model_matrix =
    model.transform
    |> transformer
    |> transform.to_matrix
    |> list.flatten

  let viewproj = camera.viewproj |> list.flatten

  model.draw(model, params, #(viewproj, model_matrix), ctx)
}
