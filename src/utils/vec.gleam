import gleam/int

pub type Vec {
  Vec(x: Int, y: Int)
}

pub fn add(a: Vec, b: Vec) {
  Vec(a.x + b.x, a.y + b.y)
}

pub fn to_string(v: Vec) {
  "(x: " <> int.to_string(v.x) <> ", y: " <> int.to_string(v.y) <> ")"
}
