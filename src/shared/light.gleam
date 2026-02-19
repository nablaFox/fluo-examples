import fluo/color.{type Color}
import shared/vector.{type Vec3}

pub type DirectionalLight {
  Light(direction: Vec3, color: Color)
}

pub type SpotLight {
  SpotLight(
    position: Vec3,
    direction: Vec3,
    color: Color,
    inner_cutoff: Float,
    outer_cutoff: Float,
  )
}
