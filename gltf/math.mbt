///|
/// Small, allocation-conscious math primitives used by asset diagnostics.
/// They deliberately stay independent from a renderer so the same analysis
/// works in native and wasm-gc builds.

///|
pub(all) struct Vec2 {
  x : Double
  y : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct Mat4 {
  values : Array[Double]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct Bounds3 {
  min : Vec3
  max : Vec3
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn vec2(x : Double, y : Double) -> Vec2 {
  { x, y }
}

///|
pub fn vec3(x : Double, y : Double, z : Double) -> Vec3 {
  { x, y, z }
}

///|
pub fn quat(x : Double, y : Double, z : Double, w : Double) -> Quat {
  { x, y, z, w }
}

///|
pub fn vec2_add(a : Vec2, b : Vec2) -> Vec2 {
  { x: a.x + b.x, y: a.y + b.y }
}

///|
pub fn vec2_sub(a : Vec2, b : Vec2) -> Vec2 {
  { x: a.x - b.x, y: a.y - b.y }
}

///|
pub fn vec2_scale(a : Vec2, factor : Double) -> Vec2 {
  { x: a.x * factor, y: a.y * factor }
}

///|
pub fn vec2_dot(a : Vec2, b : Vec2) -> Double {
  a.x * b.x + a.y * b.y
}

///|
pub fn vec2_length_squared(a : Vec2) -> Double {
  vec2_dot(a, a)
}

///|
pub fn vec3_add(a : Vec3, b : Vec3) -> Vec3 {
  { x: a.x + b.x, y: a.y + b.y, z: a.z + b.z }
}

///|
pub fn vec3_sub(a : Vec3, b : Vec3) -> Vec3 {
  { x: a.x - b.x, y: a.y - b.y, z: a.z - b.z }
}

///|
pub fn vec3_scale(a : Vec3, factor : Double) -> Vec3 {
  { x: a.x * factor, y: a.y * factor, z: a.z * factor }
}

///|
pub fn vec3_dot(a : Vec3, b : Vec3) -> Double {
  a.x * b.x + a.y * b.y + a.z * b.z
}

///|
pub fn vec3_cross(a : Vec3, b : Vec3) -> Vec3 {
  {
    x: a.y * b.z - a.z * b.y,
    y: a.z * b.x - a.x * b.z,
    z: a.x * b.y - a.y * b.x,
  }
}

///|
pub fn vec3_length_squared(a : Vec3) -> Double {
  vec3_dot(a, a)
}

///|
pub fn vec3_min(a : Vec3, b : Vec3) -> Vec3 {
  {
    x: if a.x < b.x {
      a.x
    } else {
      b.x
    },
    y: if a.y < b.y {
      a.y
    } else {
      b.y
    },
    z: if a.z < b.z {
      a.z
    } else {
      b.z
    },
  }
}

///|
pub fn vec3_max(a : Vec3, b : Vec3) -> Vec3 {
  {
    x: if a.x > b.x {
      a.x
    } else {
      b.x
    },
    y: if a.y > b.y {
      a.y
    } else {
      b.y
    },
    z: if a.z > b.z {
      a.z
    } else {
      b.z
    },
  }
}

///|
pub fn identity_mat4() -> Mat4 {
  {
    values: [
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
      1.0,
    ],
  }
}

///|
pub fn mat4_from_trs(translation : Vec3, rotation : Quat, scale : Vec3) -> Mat4 {
  let x2 = rotation.x + rotation.x
  let y2 = rotation.y + rotation.y
  let z2 = rotation.z + rotation.z
  let xx = rotation.x * x2
  let xy = rotation.x * y2
  let xz = rotation.x * z2
  let yy = rotation.y * y2
  let yz = rotation.y * z2
  let zz = rotation.z * z2
  let wx = rotation.w * x2
  let wy = rotation.w * y2
  let wz = rotation.w * z2
  {
    values: [
      (1.0 - (yy + zz)) * scale.x,
      (xy + wz) * scale.x,
      (xz - wy) * scale.x,
      0.0,
      (xy - wz) * scale.y,
      (1.0 - (xx + zz)) * scale.y,
      (yz + wx) * scale.y,
      0.0,
      (xz + wy) * scale.z,
      (yz - wx) * scale.z,
      (1.0 - (xx + yy)) * scale.z,
      0.0,
      translation.x,
      translation.y,
      translation.z,
      1.0,
    ],
  }
}

///|
pub fn mat4_mul(a : Mat4, b : Mat4) -> Mat4 {
  let values : Array[Double] = []
  for row in 0..<4 {
    for col in 0..<4 {
      let mut sum = 0.0
      for k in 0..<4 {
        sum += a.values[row * 4 + k] * b.values[k * 4 + col]
      }
      values.push(sum)
    }
  }
  { values, }
}

///|
pub fn mat4_transform_point(m : Mat4, point : Vec3) -> Vec3 {
  let x = m.values[0] * point.x +
    m.values[4] * point.y +
    m.values[8] * point.z +
    m.values[12]
  let y = m.values[1] * point.x +
    m.values[5] * point.y +
    m.values[9] * point.z +
    m.values[13]
  let z = m.values[2] * point.x +
    m.values[6] * point.y +
    m.values[10] * point.z +
    m.values[14]
  let w = m.values[3] * point.x +
    m.values[7] * point.y +
    m.values[11] * point.z +
    m.values[15]
  if w != 0.0 && w != 1.0 {
    { x: x / w, y: y / w, z: z / w }
  } else {
    { x, y, z }
  }
}

///|
pub fn bounds_empty() -> Bounds3 {
  {
    min: { x: 0.0, y: 0.0, z: 0.0 },
    max: { x: 0.0, y: 0.0, z: 0.0 },
    valid: false,
  }
}

///|
pub fn bounds_include(bounds : Bounds3, point : Vec3) -> Bounds3 {
  if bounds.valid {
    {
      min: vec3_min(bounds.min, point),
      max: vec3_max(bounds.max, point),
      valid: true,
    }
  } else {
    { min: point, max: point, valid: true }
  }
}

///|
pub fn bounds_union(a : Bounds3, b : Bounds3) -> Bounds3 {
  if !a.valid {
    b
  } else if !b.valid {
    a
  } else {
    { min: vec3_min(a.min, b.min), max: vec3_max(a.max, b.max), valid: true }
  }
}

///|
pub fn bounds_center(bounds : Bounds3) -> Vec3 {
  {
    x: (bounds.min.x + bounds.max.x) / 2.0,
    y: (bounds.min.y + bounds.max.y) / 2.0,
    z: (bounds.min.z + bounds.max.z) / 2.0,
  }
}

///|
pub fn bounds_extent(bounds : Bounds3) -> Vec3 {
  vec3_sub(bounds.max, bounds.min)
}

///|
pub fn bounds_surface_area(bounds : Bounds3) -> Double {
  let e = bounds_extent(bounds)
  2.0 * (e.x * e.y + e.y * e.z + e.z * e.x)
}
