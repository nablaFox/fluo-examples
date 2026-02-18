import fluo/geometry
import fluo/mesh.{type Mesh}
import fluo/renderer.{type Renderer}
import fluo/window
import gleam/list
import shared/transform.{type Transform}

pub type Drawable(frame_params, draw_params) {
  Drawable(
    mesh: Mesh,
    draw: fn(frame_params, draw_params, window.Context) -> Nil,
  )
}

pub type Model(frame_params, draw_params) {
  Model(
    drawables: List(Drawable(frame_params, draw_params)),
    transform: Transform,
  )
}

pub fn create(
  mesh: Mesh,
  renderer: Renderer(material, frame_params, draw_params),
  transform: Transform,
) -> Model(frame_params, draw_params) {
  let drawable = create_drawable(mesh, renderer)

  Model([drawable], transform)
}

pub fn create_shape(
  shape: geometry.Geometry,
  renderer: Renderer(material, frame_params, draw_params),
  transform: Transform,
) -> Model(frame_params, draw_params) {
  let mesh = geometry.to_mesh(shape)
  create(mesh, renderer, transform)
}

pub fn create_drawable(
  mesh: Mesh,
  renderer: Renderer(material, frame_params, draw_params),
) -> Drawable(frame_params, draw_params) {
  let draw = fn(frame_params, draw_params, ctx) {
    window.draw(mesh, ctx, renderer, frame_params, draw_params)
  }

  Drawable(mesh, draw)
}

pub fn draw(
  model: Model(a, b),
  frame_params: a,
  draw_params: b,
  ctx ctx: window.Context,
) {
  use drawable <- list.each(model.drawables)

  drawable.draw(frame_params, draw_params, ctx)
}

pub fn translate(
  model: Model(a, b),
  x x: Float,
  y y: Float,
  z z: Float,
) -> Model(a, b) {
  let Model(drawables, transform) = model

  Model(drawables, transform |> transform.translate(x, y, z))
}

pub fn rotate(
  model: Model(a, b),
  pitch pitch: Float,
  yaw yaw: Float,
  roll roll: Float,
) -> Model(a, b) {
  let Model(drawables, transform) = model

  Model(drawables, transform |> transform.rotate(pitch, yaw, roll))
}

pub fn translate_x(model: Model(a, b), x: Float) -> Model(a, b) {
  model |> translate(x, 0.0, 0.0)
}

pub fn translate_y(model: Model(a, b), y: Float) -> Model(a, b) {
  model |> translate(0.0, y, 0.0)
}

pub fn translate_z(model: Model(a, b), z: Float) -> Model(a, b) {
  model |> translate(0.0, 0.0, z)
}

pub fn rotate_pitch(model: Model(a, b), deg_x: Float) -> Model(a, b) {
  model |> rotate(deg_x, 0.0, 0.0)
}

pub fn rotate_yaw(model: Model(a, b), deg_y: Float) -> Model(a, b) {
  model |> rotate(0.0, deg_y, 0.0)
}

pub fn rotate_roll(model: Model(a, b), deg_z: Float) -> Model(a, b) {
  model |> rotate(0.0, 0.0, deg_z)
}
