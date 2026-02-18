import fluo/color.{type Color}
import shared/vector.{type Vec3}

pub type Light {
  Light(direction: Vec3, color: Color)
}
