///|
/// Geometric sampling helpers for picking, probes, and collision diagnostics.
pub(all) struct GeometryBarycentric {
  u : Double
  v : Double
  w : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GeometryRayHit {
  triangle_index : Int
  distance : Double
  position : Vec3
  normal : Vec3
  barycentric : GeometryBarycentric
  front_facing : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GeometrySample {
  triangle_index : Int
  position : Vec3
  normal : Vec3
  area : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GeometrySamplingReport {
  triangle_count : Int
  sampled_count : Int
  total_area : Double
  average_area : Double
  degenerate_count : Int
  hits : Array[GeometryRayHit]
} derive(Debug, ToJson, Eq)

///|
pub fn geometry_barycentric(
  u : Double,
  v : Double,
  w : Double,
) -> GeometryBarycentric {
  { u, v, w }
}

///|
pub fn geometry_barycentric_sum(value : GeometryBarycentric) -> Double {
  value.u + value.v + value.w
}

///|
pub fn geometry_barycentric_valid(
  value : GeometryBarycentric,
  tolerance : Double,
) -> Bool {
  value.u >= -tolerance &&
  value.v >= -tolerance &&
  value.w >= -tolerance &&
  Double::abs(geometry_barycentric_sum(value) - 1.0) <= tolerance
}

///|
pub fn geometry_interpolate_vec3(
  a : Vec3,
  b : Vec3,
  c : Vec3,
  barycentric : GeometryBarycentric,
) -> Vec3 {
  {
    x: a.x * barycentric.u + b.x * barycentric.v + c.x * barycentric.w,
    y: a.y * barycentric.u + b.y * barycentric.v + c.y * barycentric.w,
    z: a.z * barycentric.u + b.z * barycentric.v + c.z * barycentric.w,
  }
}

///|
pub fn geometry_triangle_sample(
  triangle_index : Int,
  a : Vec3,
  b : Vec3,
  c : Vec3,
  u : Double,
  v : Double,
) -> GeometrySample {
  let root = if u < 0.0 { 0.0 } else if u > 1.0 { 1.0 } else { u }
  let second_limit = 1.0 - root
  let second = if v < 0.0 {
    0.0
  } else if v > second_limit {
    second_limit
  } else {
    v
  }
  let barycentric = geometry_barycentric(1.0 - root - second, root, second)
  {
    triangle_index,
    position: geometry_interpolate_vec3(a, b, c, barycentric),
    normal: topology_triangle_normal(a, b, c),
    area: topology_triangle_area(a, b, c),
  }
}

///|
pub fn geometry_ray_triangle(
  ray : SpatialRay,
  a : Vec3,
  b : Vec3,
  c : Vec3,
  triangle_index : Int,
  cull_backface : Bool,
) -> GeometryRayHit? {
  let edge_a = topology_subtract(b, a)
  let edge_b = topology_subtract(c, a)
  let cross = topology_cross(ray.direction, edge_b)
  let determinant = topology_dot(edge_a, cross)
  let epsilon = 0.0000001
  if cull_backface && determinant <= epsilon {
    return None
  }
  if !cull_backface && Double::abs(determinant) <= epsilon {
    return None
  }
  let inverse = 1.0 / determinant
  let offset = topology_subtract(ray.origin, a)
  let v = topology_dot(offset, cross) * inverse
  if v < 0.0 || v > 1.0 {
    return None
  }
  let offset_cross = topology_cross(offset, edge_a)
  let w = topology_dot(ray.direction, offset_cross) * inverse
  if w < 0.0 || v + w > 1.0 {
    return None
  }
  let distance = topology_dot(edge_b, offset_cross) * inverse
  if distance < 0.0 {
    return None
  }
  let barycentric = geometry_barycentric(1.0 - v - w, v, w)
  Some({
    triangle_index,
    distance,
    position: spatial_ray_point(ray, distance),
    normal: topology_triangle_normal(a, b, c),
    barycentric,
    front_facing: determinant > 0.0,
  })
}

///|
pub fn geometry_raycast_mesh(
  ray : SpatialRay,
  positions : Array[Vec3],
  triangles : Array[TopologyTriangle],
  cull_backface : Bool,
) -> Array[GeometryRayHit] {
  let hits : Array[GeometryRayHit] = []
  for triangle_index, triangle in triangles {
    match
      (
        positions.get(triangle.a),
        positions.get(triangle.b),
        positions.get(triangle.c),
      ) {
      (Some(a), Some(b), Some(c)) =>
        match
          geometry_ray_triangle(ray, a, b, c, triangle_index, cull_backface) {
          Some(hit) => hits.push(hit)
          None => ()
        }
      _ => ()
    }
  }
  geometry_sort_hits(hits)
  hits
}

///|
fn geometry_sort_hits(hits : Array[GeometryRayHit]) -> Unit {
  let count = hits.length()
  for pass in 0..<count {
    let limit = count - pass - 1
    for index in 0..<limit {
      match (hits.get(index), hits.get(index + 1)) {
        (Some(left), Some(right)) =>
          if left.distance > right.distance {
            hits[index] = right
            hits[index + 1] = left
          }
        _ => ()
      }
    }
  }
}

///|
pub fn geometry_total_area(
  positions : Array[Vec3],
  triangles : Array[TopologyTriangle],
) -> Double {
  let mut total = 0.0
  for triangle in triangles {
    match
      (
        positions.get(triangle.a),
        positions.get(triangle.b),
        positions.get(triangle.c),
      ) {
      (Some(a), Some(b), Some(c)) =>
        total = total + topology_triangle_area(a, b, c)
      _ => ()
    }
  }
  total
}

///|
pub fn geometry_degenerate_count(
  positions : Array[Vec3],
  triangles : Array[TopologyTriangle],
  epsilon : Double,
) -> Int {
  let mut count = 0
  for triangle in triangles {
    match
      (
        positions.get(triangle.a),
        positions.get(triangle.b),
        positions.get(triangle.c),
      ) {
      (Some(a), Some(b), Some(c)) =>
        if topology_triangle_area(a, b, c) <= epsilon {
          count = count + 1
        }
      _ => count = count + 1
    }
  }
  count
}

///|
pub fn geometry_sampling_report(
  positions : Array[Vec3],
  triangles : Array[TopologyTriangle],
  ray : SpatialRay?,
) -> GeometrySamplingReport {
  let area = geometry_total_area(positions, triangles)
  let hits = match ray {
    Some(value) => geometry_raycast_mesh(value, positions, triangles, false)
    None => []
  }
  let count = triangles.length()
  {
    triangle_count: count,
    sampled_count: hits.length(),
    total_area: area,
    average_area: if count == 0 {
      0.0
    } else {
      area / Double::from_int(count)
    },
    degenerate_count: geometry_degenerate_count(positions, triangles, 0.0000001),
    hits,
  }
}

///|
pub fn geometry_hit_closest(hits : Array[GeometryRayHit]) -> GeometryRayHit? {
  match hits.get(0) {
    Some(hit) => Some(hit)
    None => None
  }
}

///|
pub fn geometry_hit_uv(
  hit : GeometryRayHit,
  uv_a : Vec3,
  uv_b : Vec3,
  uv_c : Vec3,
) -> Vec3 {
  geometry_interpolate_vec3(uv_a, uv_b, uv_c, hit.barycentric)
}

///|
pub fn geometry_report_lines(report : GeometrySamplingReport) -> Array[String] {
  [
    "triangles=\{report.triangle_count}",
    "sampled=\{report.sampled_count}",
    "total_area=\{report.total_area}",
    "average_area=\{report.average_area}",
    "degenerate=\{report.degenerate_count}",
  ]
}
