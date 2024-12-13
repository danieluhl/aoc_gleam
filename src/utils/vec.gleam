pub type Vec {
  Vec(x: Int, y: Int)
}

pub fn add(a: Vec, b: Vec) {
  Vec(a.x + b.x, a.y + b.y)
}
