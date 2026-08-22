///|
/// Deterministic spatial queries for picking, visibility checks, and streaming.
pub(all) struct SpatialAabb {
  minimum : Vec3
  maximum : Vec3
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SpatialRay {
  origin : Vec3
  direction : Vec3
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SpatialPlane {
  normal : Vec3
  distance : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SpatialFrustum {
  planes : Array[SpatialPlane]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SpatialItem {
  id : Int
  bounds : SpatialAabb
  center : Vec3
  radius : Double
  layer : Int
  active : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SpatialHit {
  id : Int
  distance : Double
  point : Vec3
  normal : Vec3
  inside : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SpatialQueryStats {
  candidates : Int
  accepted : Int
  rejected_layer : Int
  rejected_bounds : Int
  rejected_distance : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SpatialQueryResult {
  hits : Array[SpatialHit]
  stats : SpatialQueryStats
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SpatialIndex {
  items : Array[SpatialItem]
  cell_size : Double
  world_bounds : SpatialAabb
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SpatialPolicy {
  max_items : Int
  max_query_results : Int
  min_cell_size : Double
  max_cell_size : Double
  require_finite_bounds : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SpatialBudgetResult {
  passed : Bool
  violations : Array[String]
  item_count : Int
  index : SpatialIndex
} derive(Debug, ToJson, Eq)

///|
pub fn spatial_vec3(x : Double, y : Double, z : Double) -> Vec3 {
  { x, y, z }
}

///|
pub fn spatial_aabb(minimum : Vec3, maximum : Vec3) -> SpatialAabb {
  {
    minimum: spatial_component_minimum(minimum, maximum),
    maximum: spatial_component_maximum(minimum, maximum),
  }
}

///|
fn spatial_component_minimum(a : Vec3, b : Vec3) -> Vec3 {
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
fn spatial_component_maximum(a : Vec3, b : Vec3) -> Vec3 {
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
pub fn spatial_aabb_empty() -> SpatialAabb {
  { minimum: { x: 0.0, y: 0.0, z: 0.0 }, maximum: { x: 0.0, y: 0.0, z: 0.0 } }
}

///|
pub fn spatial_aabb_from_points(points : Array[Vec3]) -> SpatialAabb {
  match points.get(0) {
    None => spatial_aabb_empty()
    Some(first) => {
      let mut minimum = first
      let mut maximum = first
      for point in points {
        minimum = spatial_component_minimum(minimum, point)
        maximum = spatial_component_maximum(maximum, point)
      }
      { minimum, maximum }
    }
  }
}

///|
pub fn spatial_aabb_center(bounds : SpatialAabb) -> Vec3 {
  {
    x: (bounds.minimum.x + bounds.maximum.x) * 0.5,
    y: (bounds.minimum.y + bounds.maximum.y) * 0.5,
    z: (bounds.minimum.z + bounds.maximum.z) * 0.5,
  }
}

///|
pub fn spatial_aabb_extent(bounds : SpatialAabb) -> Vec3 {
  {
    x: bounds.maximum.x - bounds.minimum.x,
    y: bounds.maximum.y - bounds.minimum.y,
    z: bounds.maximum.z - bounds.minimum.z,
  }
}

///|
pub fn spatial_aabb_half_extent(bounds : SpatialAabb) -> Vec3 {
  topology_scale(spatial_aabb_extent(bounds), 0.5)
}

///|
pub fn spatial_aabb_volume(bounds : SpatialAabb) -> Double {
  let extent = spatial_aabb_extent(bounds)
  extent.x * extent.y * extent.z
}

///|
pub fn spatial_aabb_surface_area(bounds : SpatialAabb) -> Double {
  let extent = spatial_aabb_extent(bounds)
  2.0 * (extent.x * extent.y + extent.y * extent.z + extent.z * extent.x)
}

///|
pub fn spatial_aabb_is_valid(bounds : SpatialAabb) -> Bool {
  bounds.minimum.x <= bounds.maximum.x &&
  bounds.minimum.y <= bounds.maximum.y &&
  bounds.minimum.z <= bounds.maximum.z
}

///|
pub fn spatial_aabb_contains_point(bounds : SpatialAabb, point : Vec3) -> Bool {
  point.x >= bounds.minimum.x &&
  point.x <= bounds.maximum.x &&
  point.y >= bounds.minimum.y &&
  point.y <= bounds.maximum.y &&
  point.z >= bounds.minimum.z &&
  point.z <= bounds.maximum.z
}

///|
pub fn spatial_aabb_contains_bounds(
  outer : SpatialAabb,
  inner : SpatialAabb,
) -> Bool {
  spatial_aabb_contains_point(outer, inner.minimum) &&
  spatial_aabb_contains_point(outer, inner.maximum)
}

///|
pub fn spatial_aabb_overlaps(left : SpatialAabb, right : SpatialAabb) -> Bool {
  left.minimum.x <= right.maximum.x &&
  left.maximum.x >= right.minimum.x &&
  left.minimum.y <= right.maximum.y &&
  left.maximum.y >= right.minimum.y &&
  left.minimum.z <= right.maximum.z &&
  left.maximum.z >= right.minimum.z
}

///|
pub fn spatial_aabb_intersection(
  left : SpatialAabb,
  right : SpatialAabb,
) -> SpatialAabb? {
  if !spatial_aabb_overlaps(left, right) {
    None
  } else {
    Some({
      minimum: spatial_component_maximum(left.minimum, right.minimum),
      maximum: spatial_component_minimum(left.maximum, right.maximum),
    })
  }
}

///|
pub fn spatial_aabb_union(
  left : SpatialAabb,
  right : SpatialAabb,
) -> SpatialAabb {
  {
    minimum: spatial_component_minimum(left.minimum, right.minimum),
    maximum: spatial_component_maximum(left.maximum, right.maximum),
  }
}

///|
pub fn spatial_aabb_expand(
  bounds : SpatialAabb,
  margin : Double,
) -> SpatialAabb {
  {
    minimum: {
      x: bounds.minimum.x - margin,
      y: bounds.minimum.y - margin,
      z: bounds.minimum.z - margin,
    },
    maximum: {
      x: bounds.maximum.x + margin,
      y: bounds.maximum.y + margin,
      z: bounds.maximum.z + margin,
    },
  }
}

///|
pub fn spatial_aabb_clamp_point(bounds : SpatialAabb, point : Vec3) -> Vec3 {
  {
    x: if point.x < bounds.minimum.x {
      bounds.minimum.x
    } else if point.x > bounds.maximum.x {
      bounds.maximum.x
    } else {
      point.x
    },
    y: if point.y < bounds.minimum.y {
      bounds.minimum.y
    } else if point.y > bounds.maximum.y {
      bounds.maximum.y
    } else {
      point.y
    },
    z: if point.z < bounds.minimum.z {
      bounds.minimum.z
    } else if point.z > bounds.maximum.z {
      bounds.maximum.z
    } else {
      point.z
    },
  }
}

///|
pub fn spatial_distance_squared(a : Vec3, b : Vec3) -> Double {
  topology_distance_squared(a, b)
}

///|
pub fn spatial_point_aabb_distance_squared(
  point : Vec3,
  bounds : SpatialAabb,
) -> Double {
  spatial_distance_squared(point, spatial_aabb_clamp_point(bounds, point))
}

///|
pub fn spatial_item(id : Int, bounds : SpatialAabb, layer : Int) -> SpatialItem {
  let extent = spatial_aabb_extent(bounds)
  let radius = Double::sqrt(
      extent.x * extent.x + extent.y * extent.y + extent.z * extent.z,
    ) *
    0.5
  {
    id,
    bounds,
    center: spatial_aabb_center(bounds),
    radius,
    layer,
    active: true,
  }
}

///|
pub fn spatial_item_with_radius(
  id : Int,
  bounds : SpatialAabb,
  radius : Double,
  layer : Int,
) -> SpatialItem {
  {
    id,
    bounds,
    center: spatial_aabb_center(bounds),
    radius,
    layer,
    active: true,
  }
}

///|
pub fn spatial_item_set_active(
  item : SpatialItem,
  active : Bool,
) -> SpatialItem {
  { ..item, active, }
}

///|
pub fn spatial_item_distance_squared(
  item : SpatialItem,
  point : Vec3,
) -> Double {
  spatial_distance_squared(item.center, point)
}

///|
pub fn spatial_ray(origin : Vec3, direction : Vec3) -> SpatialRay {
  { origin, direction: topology_normalize(direction) }
}

///|
pub fn spatial_ray_point(ray : SpatialRay, distance : Double) -> Vec3 {
  topology_add(ray.origin, topology_scale(ray.direction, distance))
}

///|
pub fn spatial_ray_aabb_distance(
  ray : SpatialRay,
  bounds : SpatialAabb,
) -> Double? {
  let mut near = 0.0
  let mut far = 1.0 / 0.0
  let origins = [ray.origin.x, ray.origin.y, ray.origin.z]
  let directions = [ray.direction.x, ray.direction.y, ray.direction.z]
  let minimums = [bounds.minimum.x, bounds.minimum.y, bounds.minimum.z]
  let maximums = [bounds.maximum.x, bounds.maximum.y, bounds.maximum.z]
  for axis in 0..<3 {
    let origin = origins[axis]
    let direction = directions[axis]
    let minimum = minimums[axis]
    let maximum = maximums[axis]
    if direction == 0.0 {
      if origin < minimum || origin > maximum {
        return None
      }
    } else {
      let inverse = 1.0 / direction
      let mut first = (minimum - origin) * inverse
      let mut second = (maximum - origin) * inverse
      if first > second {
        let old = first
        first = second
        second = old
      }
      if first > near {
        near = first
      }
      if second < far {
        far = second
      }
      if near > far || far < 0.0 {
        return None
      }
    }
  }
  Some(if near < 0.0 { 0.0 } else { near })
}

///|
pub fn spatial_ray_sphere_distance(
  ray : SpatialRay,
  center : Vec3,
  radius : Double,
) -> Double? {
  let offset = topology_subtract(center, ray.origin)
  let projection = topology_dot(offset, ray.direction)
  let closest = topology_subtract(
    offset,
    topology_scale(ray.direction, projection),
  )
  let radius_squared = radius * radius
  let distance_squared = topology_length_squared(closest)
  if distance_squared > radius_squared {
    return None
  }
  let delta = Double::sqrt(radius_squared - distance_squared)
  let distance = projection - delta
  Some(if distance < 0.0 { 0.0 } else { distance })
}

///|
pub fn spatial_ray_item_hit(
  ray : SpatialRay,
  item : SpatialItem,
) -> SpatialHit? {
  match spatial_ray_aabb_distance(ray, item.bounds) {
    None => None
    Some(distance) => {
      let point = spatial_ray_point(ray, distance)
      let inside = spatial_aabb_contains_point(item.bounds, ray.origin)
      let normal = spatial_aabb_surface_normal(item.bounds, point)
      Some({ id: item.id, distance, point, normal, inside })
    }
  }
}

///|
pub fn spatial_aabb_surface_normal(bounds : SpatialAabb, point : Vec3) -> Vec3 {
  let distances = [
    (point.x - bounds.minimum.x, { x: -1.0, y: 0.0, z: 0.0 }),
    (bounds.maximum.x - point.x, { x: 1.0, y: 0.0, z: 0.0 }),
    (point.y - bounds.minimum.y, { x: 0.0, y: -1.0, z: 0.0 }),
    (bounds.maximum.y - point.y, { x: 0.0, y: 1.0, z: 0.0 }),
    (point.z - bounds.minimum.z, { x: 0.0, y: 0.0, z: -1.0 }),
    (bounds.maximum.z - point.z, { x: 0.0, y: 0.0, z: 1.0 }),
  ]
  let mut best = distances[0]
  for candidate in distances {
    if candidate.0 < best.0 {
      best = candidate
    }
  }
  best.1
}

///|
pub fn spatial_plane(normal : Vec3, distance : Double) -> SpatialPlane {
  { normal: topology_normalize(normal), distance }
}

///|
pub fn spatial_plane_signed_distance(
  plane : SpatialPlane,
  point : Vec3,
) -> Double {
  topology_dot(plane.normal, point) + plane.distance
}

///|
pub fn spatial_plane_aabb_distance(
  plane : SpatialPlane,
  bounds : SpatialAabb,
) -> Double {
  let positive = {
    x: if plane.normal.x >= 0.0 {
      bounds.maximum.x
    } else {
      bounds.minimum.x
    },
    y: if plane.normal.y >= 0.0 {
      bounds.maximum.y
    } else {
      bounds.minimum.y
    },
    z: if plane.normal.z >= 0.0 {
      bounds.maximum.z
    } else {
      bounds.minimum.z
    },
  }
  spatial_plane_signed_distance(plane, positive)
}

///|
pub fn spatial_frustum(planes : Array[SpatialPlane]) -> SpatialFrustum {
  { planes, }
}

///|
pub fn spatial_frustum_contains_point(
  frustum : SpatialFrustum,
  point : Vec3,
) -> Bool {
  frustum.planes.all(fn(plane) {
    spatial_plane_signed_distance(plane, point) >= 0.0
  })
}

///|
pub fn spatial_frustum_intersects_bounds(
  frustum : SpatialFrustum,
  bounds : SpatialAabb,
) -> Bool {
  frustum.planes.all(fn(plane) {
    spatial_plane_aabb_distance(plane, bounds) >= 0.0
  })
}

///|
pub fn spatial_frustum_intersects_sphere(
  frustum : SpatialFrustum,
  center : Vec3,
  radius : Double,
) -> Bool {
  frustum.planes.all(fn(plane) {
    spatial_plane_signed_distance(plane, center) >= -radius
  })
}

///|
pub fn default_spatial_policy() -> SpatialPolicy {
  {
    max_items: 1000000,
    max_query_results: 10000,
    min_cell_size: 0.001,
    max_cell_size: 1000000.0,
    require_finite_bounds: true,
  }
}

///|
pub fn spatial_index(
  items : Array[SpatialItem],
  cell_size : Double,
  world_bounds : SpatialAabb,
) -> SpatialIndex {
  { items, cell_size, world_bounds }
}

///|
pub fn spatial_index_empty() -> SpatialIndex {
  spatial_index([], 1.0, spatial_aabb_empty())
}

///|
pub fn spatial_index_insert(
  index : SpatialIndex,
  item : SpatialItem,
) -> SpatialIndex {
  let items = index.items.copy()
  items.push(item)
  {
    items,
    cell_size: index.cell_size,
    world_bounds: spatial_aabb_union(index.world_bounds, item.bounds),
  }
}

///|
pub fn spatial_index_insert_many(
  index : SpatialIndex,
  items : Array[SpatialItem],
) -> SpatialIndex {
  let mut result = index
  for item in items {
    result = spatial_index_insert(result, item)
  }
  result
}

///|
pub fn spatial_index_remove(index : SpatialIndex, id : Int) -> SpatialIndex {
  let items : Array[SpatialItem] = []
  for item in index.items {
    if item.id != id {
      items.push(item)
    }
  }
  { ..index, items, }
}

///|
pub fn spatial_index_update(
  index : SpatialIndex,
  item : SpatialItem,
) -> SpatialIndex {
  spatial_index_insert(spatial_index_remove(index, item.id), item)
}

///|
pub fn spatial_index_find(index : SpatialIndex, id : Int) -> SpatialItem? {
  for item in index.items {
    if item.id == id {
      return Some(item)
    }
  }
  None
}

///|
pub fn spatial_index_active_items(index : SpatialIndex) -> Array[SpatialItem] {
  index.items.filter(fn(item) { item.active })
}

///|
pub fn spatial_query_ray(
  index : SpatialIndex,
  ray : SpatialRay,
  layer_mask : Int,
  max_distance : Double,
) -> SpatialQueryResult {
  let hits : Array[SpatialHit] = []
  let mut rejected_layer = 0
  let mut rejected_bounds = 0
  let mut rejected_distance = 0
  for item in index.items {
    if !item.active {
      continue
    }
    if (item.layer & layer_mask) == 0 {
      rejected_layer = rejected_layer + 1
      continue
    }
    match spatial_ray_item_hit(ray, item) {
      None => rejected_bounds = rejected_bounds + 1
      Some(hit) =>
        if hit.distance > max_distance {
          rejected_distance = rejected_distance + 1
        } else {
          hits.push(hit)
        }
    }
  }
  spatial_sort_hits_by_distance(hits)
  {
    hits,
    stats: {
      candidates: index.items.length(),
      accepted: hits.length(),
      rejected_layer,
      rejected_bounds,
      rejected_distance,
    },
  }
}

///|
pub fn spatial_query_bounds(
  index : SpatialIndex,
  bounds : SpatialAabb,
  layer_mask : Int,
) -> SpatialQueryResult {
  let hits : Array[SpatialHit] = []
  let mut rejected_layer = 0
  let mut rejected_bounds = 0
  for item in index.items {
    if !item.active {
      continue
    }
    if (item.layer & layer_mask) == 0 {
      rejected_layer = rejected_layer + 1
    } else if spatial_aabb_overlaps(item.bounds, bounds) {
      let point = spatial_aabb_center(item.bounds)
      hits.push({
        id: item.id,
        distance: spatial_point_aabb_distance_squared(point, bounds),
        point,
        normal: { x: 0.0, y: 1.0, z: 0.0 },
        inside: spatial_aabb_contains_bounds(bounds, item.bounds),
      })
    } else {
      rejected_bounds = rejected_bounds + 1
    }
  }
  {
    hits,
    stats: {
      candidates: index.items.length(),
      accepted: hits.length(),
      rejected_layer,
      rejected_bounds,
      rejected_distance: 0,
    },
  }
}

///|
pub fn spatial_query_sphere(
  index : SpatialIndex,
  center : Vec3,
  radius : Double,
  layer_mask : Int,
) -> SpatialQueryResult {
  let radius_squared = radius * radius
  let hits : Array[SpatialHit] = []
  let mut rejected_layer = 0
  let mut rejected_distance = 0
  for item in index.items {
    if !item.active {
      continue
    }
    if (item.layer & layer_mask) == 0 {
      rejected_layer = rejected_layer + 1
      continue
    }
    let distance = spatial_point_aabb_distance_squared(center, item.bounds)
    if distance <= radius_squared {
      hits.push({
        id: item.id,
        distance: Double::sqrt(distance),
        point: spatial_aabb_clamp_point(item.bounds, center),
        normal: topology_normalize(topology_subtract(item.center, center)),
        inside: distance == 0.0,
      })
    } else {
      rejected_distance = rejected_distance + 1
    }
  }
  spatial_sort_hits_by_distance(hits)
  {
    hits,
    stats: {
      candidates: index.items.length(),
      accepted: hits.length(),
      rejected_layer,
      rejected_bounds: 0,
      rejected_distance,
    },
  }
}

///|
pub fn spatial_query_frustum(
  index : SpatialIndex,
  frustum : SpatialFrustum,
  layer_mask : Int,
) -> SpatialQueryResult {
  let hits : Array[SpatialHit] = []
  let mut rejected_layer = 0
  let mut rejected_bounds = 0
  for item in index.items {
    if !item.active {
      continue
    }
    if (item.layer & layer_mask) == 0 {
      rejected_layer = rejected_layer + 1
    } else if spatial_frustum_intersects_bounds(frustum, item.bounds) {
      hits.push({
        id: item.id,
        distance: 0.0,
        point: item.center,
        normal: { x: 0.0, y: 0.0, z: 0.0 },
        inside: spatial_frustum_contains_point(frustum, item.center),
      })
    } else {
      rejected_bounds = rejected_bounds + 1
    }
  }
  {
    hits,
    stats: {
      candidates: index.items.length(),
      accepted: hits.length(),
      rejected_layer,
      rejected_bounds,
      rejected_distance: 0,
    },
  }
}

///|
fn spatial_sort_hits_by_distance(hits : Array[SpatialHit]) -> Unit {
  let count = hits.length()
  if count < 2 {
    return
  }
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
pub fn spatial_nearest(
  index : SpatialIndex,
  point : Vec3,
  layer_mask : Int,
) -> SpatialHit? {
  let mut best : SpatialHit? = None
  for item in index.items {
    if !item.active || (item.layer & layer_mask) == 0 {
      continue
    }
    let closest = spatial_aabb_clamp_point(item.bounds, point)
    let distance = Double::sqrt(spatial_distance_squared(closest, point))
    let hit = SpatialHit::{
      id: item.id,
      distance,
      point: closest,
      normal: topology_normalize(topology_subtract(item.center, point)),
      inside: distance == 0.0,
    }
    match best {
      None => best = Some(hit)
      Some(current) => if distance < current.distance { best = Some(hit) }
    }
  }
  best
}

///|
pub fn spatial_visible_items(
  index : SpatialIndex,
  frustum : SpatialFrustum,
  layer_mask : Int,
) -> Array[Int] {
  spatial_query_frustum(index, frustum, layer_mask).hits.map(fn(hit) { hit.id })
}

///|
pub fn spatial_validate_index(
  index : SpatialIndex,
  policy : SpatialPolicy,
) -> SpatialBudgetResult {
  let violations : Array[String] = []
  if index.items.length() > policy.max_items {
    violations.push("spatial item count exceeds policy")
  }
  if index.cell_size < policy.min_cell_size ||
    index.cell_size > policy.max_cell_size {
    violations.push("cell size is outside policy")
  }
  if policy.require_finite_bounds {
    for item in index.items {
      if !spatial_aabb_is_valid(item.bounds) {
        violations.push("invalid item bounds")
        break
      }
    }
  }
  {
    passed: violations.length() == 0,
    violations,
    item_count: index.items.length(),
    index,
  }
}

///|
pub fn spatial_index_bounds(index : SpatialIndex) -> SpatialAabb {
  let mut result = spatial_aabb_empty()
  match index.items.get(0) {
    None => result
    Some(first) => {
      result = first.bounds
      for item in index.items {
        result = spatial_aabb_union(result, item.bounds)
      }
      result
    }
  }
}

///|
pub fn spatial_query_stats_lines(stats : SpatialQueryStats) -> Array[String] {
  [
    "candidates=\{stats.candidates}",
    "accepted=\{stats.accepted}",
    "rejected_layer=\{stats.rejected_layer}",
    "rejected_bounds=\{stats.rejected_bounds}",
    "rejected_distance=\{stats.rejected_distance}",
  ]
}

///|
pub fn spatial_index_summary_lines(index : SpatialIndex) -> Array[String] {
  [
    "items=\{index.items.length()}",
    "cell_size=\{index.cell_size}",
    "world_volume=\{spatial_aabb_volume(index.world_bounds)}",
    "world_surface_area=\{spatial_aabb_surface_area(index.world_bounds)}",
  ]
}
