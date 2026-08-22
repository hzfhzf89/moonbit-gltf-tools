///|
pub(all) struct GeometryPositionStats {
  count : Int
  minimum : Vec3
  maximum : Vec3
  center : Vec3
  variance : Vec3
  average_distance : Double
  maximum_distance : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GeometryNormalStats {
  count : Int
  unit_count : Int
  zero_count : Int
  average : Vec3
  minimum_length : Double
  maximum_length : Double
  deviation : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GeometrySurfaceStats {
  triangle_count : Int
  area : Double
  minimum_area : Double
  maximum_area : Double
  average_area : Double
  zero_area_count : Int
  signed_volume : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GeometryAttributeStats {
  position : GeometryPositionStats
  normal : GeometryNormalStats
  surface : GeometrySurfaceStats
  bounds : SpatialAabb
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GeometryCluster {
  index : Int
  triangle_indices : Array[Int]
  vertex_indices : Array[Int]
  bounds : SpatialAabb
  area : Double
  centroid : Vec3
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GeometryClusterPlan {
  clusters : Array[GeometryCluster]
  target_size : Int
  largest : Int
  smallest : Int
  average : Double
} derive(Debug, ToJson, Eq)

///|
pub fn geometry_zero_vec3() -> Vec3 {
  { x: 0.0, y: 0.0, z: 0.0 }
}

///|
pub fn geometry_one_vec3() -> Vec3 {
  { x: 1.0, y: 1.0, z: 1.0 }
}

///|
pub fn geometry_vec3_equal(
  left : Vec3,
  right : Vec3,
  tolerance : Double,
) -> Bool {
  Double::abs(left.x - right.x) <= tolerance &&
  Double::abs(left.y - right.y) <= tolerance &&
  Double::abs(left.z - right.z) <= tolerance
}

///|
pub fn geometry_vec3_minimum(values : Array[Vec3]) -> Vec3 {
  match values.get(0) {
    None => geometry_zero_vec3()
    Some(first) => {
      let mut result = first
      for value in values {
        result = {
          x: if value.x < result.x {
            value.x
          } else {
            result.x
          },
          y: if value.y < result.y {
            value.y
          } else {
            result.y
          },
          z: if value.z < result.z {
            value.z
          } else {
            result.z
          },
        }
      }
      result
    }
  }
}

///|
pub fn geometry_vec3_maximum(values : Array[Vec3]) -> Vec3 {
  match values.get(0) {
    None => geometry_zero_vec3()
    Some(first) => {
      let mut result = first
      for value in values {
        result = {
          x: if value.x > result.x {
            value.x
          } else {
            result.x
          },
          y: if value.y > result.y {
            value.y
          } else {
            result.y
          },
          z: if value.z > result.z {
            value.z
          } else {
            result.z
          },
        }
      }
      result
    }
  }
}

///|
pub fn geometry_vec3_sum(values : Array[Vec3]) -> Vec3 {
  let mut result = geometry_zero_vec3()
  for value in values {
    result = topology_add(result, value)
  }
  result
}

///|
pub fn geometry_vec3_average(values : Array[Vec3]) -> Vec3 {
  if values.length() == 0 {
    return geometry_zero_vec3()
  }
  topology_scale(
    geometry_vec3_sum(values),
    1.0 / Double::from_int(values.length()),
  )
}

///|
pub fn geometry_vec3_average_weighted(
  values : Array[Vec3],
  weights : Array[Double],
) -> Vec3 {
  let mut result = geometry_zero_vec3()
  let mut total = 0.0
  for index, value in values {
    match weights.get(index) {
      Some(weight) => {
        result = topology_add(result, topology_scale(value, weight))
        total = total + weight
      }
      None => ()
    }
  }
  if total == 0.0 {
    geometry_zero_vec3()
  } else {
    topology_scale(result, 1.0 / total)
  }
}

///|
pub fn geometry_position_stats(values : Array[Vec3]) -> GeometryPositionStats {
  let count = values.length()
  let average = geometry_vec3_average(values)
  let mut variance = geometry_zero_vec3()
  let mut distance = 0.0
  let mut maximum_distance = 0.0
  for value in values {
    let delta = topology_subtract(value, average)
    variance = {
      x: variance.x + delta.x * delta.x,
      y: variance.y + delta.y * delta.y,
      z: variance.z + delta.z * delta.z,
    }
    let current_distance = Double::sqrt(topology_length_squared(delta))
    distance = distance + current_distance
    if current_distance > maximum_distance {
      maximum_distance = current_distance
    }
  }
  if count > 0 {
    variance = topology_scale(variance, 1.0 / Double::from_int(count))
  }
  {
    count,
    minimum: geometry_vec3_minimum(values),
    maximum: geometry_vec3_maximum(values),
    center: average,
    variance,
    average_distance: if count == 0 {
      0.0
    } else {
      distance / Double::from_int(count)
    },
    maximum_distance,
  }
}

///|
pub fn geometry_position_bounds(values : Array[Vec3]) -> SpatialAabb {
  spatial_aabb(geometry_vec3_minimum(values), geometry_vec3_maximum(values))
}

///|
pub fn geometry_position_center(values : Array[Vec3]) -> Vec3 {
  spatial_aabb_center(geometry_position_bounds(values))
}

///|
pub fn geometry_position_extent(values : Array[Vec3]) -> Vec3 {
  spatial_aabb_extent(geometry_position_bounds(values))
}

///|
pub fn geometry_position_diagonal(values : Array[Vec3]) -> Double {
  Double::sqrt(topology_length_squared(geometry_position_extent(values)))
}

///|
pub fn geometry_position_radius(values : Array[Vec3]) -> Double {
  geometry_position_stats(values).maximum_distance
}

///|
pub fn geometry_position_outliers(
  values : Array[Vec3],
  center : Vec3,
  radius : Double,
) -> Array[Int] {
  let result : Array[Int] = []
  for index, value in values {
    if Double::sqrt(topology_distance_squared(value, center)) > radius {
      result.push(index)
    }
  }
  result
}

///|
pub fn geometry_normal_length(value : Vec3) -> Double {
  Double::sqrt(topology_length_squared(value))
}

///|
pub fn geometry_normal_is_unit(value : Vec3, tolerance : Double) -> Bool {
  Double::abs(geometry_normal_length(value) - 1.0) <= tolerance
}

///|
pub fn geometry_normal_is_zero(value : Vec3, tolerance : Double) -> Bool {
  geometry_normal_length(value) <= tolerance
}

///|
pub fn geometry_normal_stats(
  values : Array[Vec3],
  tolerance : Double,
) -> GeometryNormalStats {
  let mut unit_count = 0
  let mut zero_count = 0
  let mut minimum_length = 1.0 / 0.0
  let mut maximum_length = 0.0
  let mut sum = geometry_zero_vec3()
  let mut deviation = 0.0
  for value in values {
    let length = geometry_normal_length(value)
    sum = topology_add(sum, value)
    if geometry_normal_is_unit(value, tolerance) {
      unit_count = unit_count + 1
    }
    if geometry_normal_is_zero(value, tolerance) {
      zero_count = zero_count + 1
    }
    if length < minimum_length {
      minimum_length = length
    }
    if length > maximum_length {
      maximum_length = length
    }
    deviation = deviation + Double::abs(length - 1.0)
  }
  let count = values.length()
  {
    count,
    unit_count,
    zero_count,
    average: if count == 0 {
      geometry_zero_vec3()
    } else {
      topology_scale(sum, 1.0 / Double::from_int(count))
    },
    minimum_length: if count == 0 {
      0.0
    } else {
      minimum_length
    },
    maximum_length,
    deviation: if count == 0 {
      0.0
    } else {
      deviation / Double::from_int(count)
    },
  }
}

///|
pub fn geometry_normalize_all(values : Array[Vec3]) -> Array[Vec3] {
  values.map(topology_normalize)
}

///|
pub fn geometry_normal_flip_count(
  left : Array[Vec3],
  right : Array[Vec3],
) -> Int {
  let mut count = 0
  for index, value in left {
    match right.get(index) {
      Some(other) => if topology_dot(value, other) < 0.0 { count = count + 1 }
      None => ()
    }
  }
  count
}

///|
pub fn geometry_surface_stats(
  positions : Array[Vec3],
  triangles : Array[TopologyTriangle],
) -> GeometrySurfaceStats {
  let mut area = 0.0
  let mut minimum_area = 1.0 / 0.0
  let mut maximum_area = 0.0
  let mut zero_area_count = 0
  let mut signed_volume = 0.0
  for triangle in triangles {
    match
      (
        positions.get(triangle.a),
        positions.get(triangle.b),
        positions.get(triangle.c),
      ) {
      (Some(a), Some(b), Some(c)) => {
        let current = topology_triangle_area(a, b, c)
        area = area + current
        if current < minimum_area {
          minimum_area = current
        }
        if current > maximum_area {
          maximum_area = current
        }
        if current <= 0.0000001 {
          zero_area_count = zero_area_count + 1
        }
        signed_volume = signed_volume + topology_triangle_signed_volume(a, b, c)
      }
      _ => zero_area_count = zero_area_count + 1
    }
  }
  let count = triangles.length()
  {
    triangle_count: count,
    area,
    minimum_area: if count == 0 {
      0.0
    } else {
      minimum_area
    },
    maximum_area,
    average_area: if count == 0 {
      0.0
    } else {
      area / Double::from_int(count)
    },
    zero_area_count,
    signed_volume,
  }
}

///|
pub fn geometry_triangle_centroid(a : Vec3, b : Vec3, c : Vec3) -> Vec3 {
  topology_scale(topology_add(topology_add(a, b), c), 1.0 / 3.0)
}

///|
pub fn geometry_centroids(
  positions : Array[Vec3],
  triangles : Array[TopologyTriangle],
) -> Array[Vec3] {
  let result : Array[Vec3] = []
  for triangle in triangles {
    match
      (
        positions.get(triangle.a),
        positions.get(triangle.b),
        positions.get(triangle.c),
      ) {
      (Some(a), Some(b), Some(c)) =>
        result.push(geometry_triangle_centroid(a, b, c))
      _ => result.push(geometry_zero_vec3())
    }
  }
  result
}

///|
pub fn geometry_attribute_stats(
  positions : Array[Vec3],
  normals : Array[Vec3],
  triangles : Array[TopologyTriangle],
) -> GeometryAttributeStats {
  let position = geometry_position_stats(positions)
  let normal = geometry_normal_stats(normals, 0.001)
  let surface = geometry_surface_stats(positions, triangles)
  {
    position,
    normal,
    surface,
    bounds: geometry_position_bounds(positions),
    valid: positions.length() > 0 && surface.zero_area_count == 0,
  }
}

///|
pub fn geometry_cluster_bounds(
  positions : Array[Vec3],
  triangles : Array[TopologyTriangle],
) -> SpatialAabb {
  let points : Array[Vec3] = []
  for triangle in triangles {
    match
      (
        positions.get(triangle.a),
        positions.get(triangle.b),
        positions.get(triangle.c),
      ) {
      (Some(a), Some(b), Some(c)) => {
        points.push(a)
        points.push(b)
        points.push(c)
      }
      _ => ()
    }
  }
  geometry_position_bounds(points)
}

///|
pub fn geometry_cluster_area(
  positions : Array[Vec3],
  triangles : Array[TopologyTriangle],
) -> Double {
  geometry_surface_stats(positions, triangles).area
}

///|
pub fn geometry_make_cluster(
  index : Int,
  positions : Array[Vec3],
  triangles : Array[TopologyTriangle],
) -> GeometryCluster {
  let vertices : Map[Int, Bool] = Map([])
  for triangle in triangles {
    vertices[triangle.a] = true
    vertices[triangle.b] = true
    vertices[triangle.c] = true
  }
  let vertex_indices : Array[Int] = []
  for value, _ in vertices {
    vertex_indices.push(value)
  }
  let centroids = geometry_centroids(positions, triangles)
  {
    index,
    triangle_indices: [],
    vertex_indices,
    bounds: geometry_cluster_bounds(positions, triangles),
    area: geometry_cluster_area(positions, triangles),
    centroid: geometry_vec3_average(centroids),
  }
}

///|
pub fn geometry_cluster_plan(
  positions : Array[Vec3],
  triangles : Array[TopologyTriangle],
  target_size : Int,
) -> GeometryClusterPlan {
  let size = if target_size < 1 { 1 } else { target_size }
  let clusters : Array[GeometryCluster] = []
  let mut start = 0
  let mut cluster_index = 0
  while start < triangles.length() {
    let end = if start + size < triangles.length() {
      start + size
    } else {
      triangles.length()
    }
    let subset : Array[TopologyTriangle] = []
    let triangle_indices : Array[Int] = []
    for index in start..<end {
      match triangles.get(index) {
        Some(value) => {
          subset.push(value)
          triangle_indices.push(index)
        }
        None => ()
      }
    }
    let cluster = {
      ..geometry_make_cluster(cluster_index, positions, subset),
      triangle_indices,
    }
    clusters.push(cluster)
    start = end
    cluster_index = cluster_index + 1
  }
  let mut largest = 0
  let mut smallest = if clusters.length() == 0 { 0 } else { 1000000000 }
  let mut total = 0
  for cluster in clusters {
    let count = cluster.triangle_indices.length()
    if count > largest {
      largest = count
    }
    if count < smallest {
      smallest = count
    }
    total = total + count
  }
  {
    clusters,
    target_size: size,
    largest,
    smallest,
    average: if clusters.length() == 0 {
      0.0
    } else {
      Double::from_int(total) / Double::from_int(clusters.length())
    },
  }
}

///|
pub fn geometry_cluster_largest(plan : GeometryClusterPlan) -> GeometryCluster? {
  let mut result : GeometryCluster? = None
  for cluster in plan.clusters {
    match result {
      None => result = Some(cluster)
      Some(current) =>
        if cluster.triangle_indices.length() > current.triangle_indices.length() {
          result = Some(cluster)
        }
    }
  }
  result
}

///|
pub fn geometry_cluster_find(
  plan : GeometryClusterPlan,
  triangle_index : Int,
) -> Int? {
  for cluster in plan.clusters {
    if cluster.triangle_indices.contains(triangle_index) {
      return Some(cluster.index)
    }
  }
  None
}

///|
pub fn geometry_cluster_centers(plan : GeometryClusterPlan) -> Array[Vec3] {
  plan.clusters.map(fn(cluster) { cluster.centroid })
}

///|
pub fn geometry_attribute_lines(
  stats : GeometryAttributeStats,
) -> Array[String] {
  [
    "positions=\{stats.position.count}",
    "normals=\{stats.normal.count}",
    "unit_normals=\{stats.normal.unit_count}",
    "triangles=\{stats.surface.triangle_count}",
    "area=\{stats.surface.area}",
    "zero_area=\{stats.surface.zero_area_count}",
    "valid=\{stats.valid}",
  ]
}
