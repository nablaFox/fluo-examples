import fluo/color.{type Color}
import fluo/geometry.{type Geometry}
import fluo/mesh.{type Mesh}
import fluo/renderer.{type Renderer}
import fluo/texture.{type Texture}
import gleam/option
import scene/scene.{type SceneModel}
import shared/matrix.{type RawMatrix}
import shared/model
import shared/transform.{type Transform}

const vertex_shader = "default.vert"

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

pub type PhongDrawParams =
  #(RawMatrix, RawMatrix)

pub type PhongRenderer =
  Renderer(PhongMaterial, scene.SceneFrameParams, scene.SceneDrawParams)

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
) -> SceneModel {
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
) -> SceneModel {
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
