///|
/// Production geometry inspection built on top of the checked binary reader.
///
/// These routines are deliberately renderer-independent. Importers and asset
/// build jobs can use the same triangle accounting, bounds, channel coverage,
/// and cache estimates before a mesh reaches a runtime-specific upload path.

///|
pub(all) struct TriangleIndex {
  a : Int
  b : Int
  c : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) enum PrimitiveWinding {
  Unknown
  Clockwise
  CounterClockwise
  Degenerate
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GeometryChannelSummary {
  position : Bool
  normal : Bool
  tangent : Bool
  texcoord_0 : Bool
  texcoord_1 : Bool
  color_0 : Bool
  joints_0 : Bool
  weights_0 : Bool
  custom_count : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct TriangleMetrics {
  triangle_count : Int
  degenerate_count : Int
  area : Double
  min_area : Double
  max_area : Double
  winding : PrimitiveWinding
  valid_index_count : Int
  invalid_index_count : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct PrimitiveGeometryReport {
  mesh_index : Int
  primitive_index : Int
  topology : String
  vertex_count : Int
  index_count : Int
  triangle_count : Int
  bounds : Bounds3
  channels : GeometryChannelSummary
  triangles : TriangleMetrics
  attribute_bytes : Int
  indexed : Bool
  cache_hit_ratio : Double
  overdraw_proxy : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct MeshGeometryReport {
  mesh_index : Int
  primitive_count : Int
  vertex_count : Int
  index_count : Int
  triangle_count : Int
  degenerate_triangle_count : Int
  bounds : Bounds3
  attribute_bytes : Int
  cache_hit_ratio : Double
  primitives : Array[PrimitiveGeometryReport]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct DocumentGeometryReport {
  mesh_count : Int
  primitive_count : Int
  vertex_count : Int
  index_count : Int
  triangle_count : Int
  degenerate_triangle_count : Int
  bounds : Bounds3
  attribute_bytes : Int
  indexed_ratio : Double
  cache_hit_ratio : Double
  meshes : Array[MeshGeometryReport]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GeometryBudget {
  max_vertices : Int
  max_indices : Int
  max_triangles : Int
  max_draw_calls : Int
  max_attribute_bytes : Int
  min_cache_hit_ratio : Double
  reject_degenerate_triangles : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GeometryBudgetResult {
  passed : Bool
  violations : Array[String]
  vertex_overage : Int
  index_overage : Int
  triangle_overage : Int
  draw_call_overage : Int
  attribute_byte_overage : Int
  cache_ratio_shortfall : Double
} derive(Debug, ToJson, Eq)

///|
pub fn default_geometry_budget() -> GeometryBudget {
  {
    max_vertices: 10_000_000,
    max_indices: 30_000_000,
    max_triangles: 10_000_000,
    max_draw_calls: 20_000,
    max_attribute_bytes: 512 * 1024 * 1024,
    min_cache_hit_ratio: 0.35,
    reject_degenerate_triangles: false,
  }
}

///|
pub fn mobile_geometry_budget() -> GeometryBudget {
  {
    max_vertices: 250_000,
    max_indices: 750_000,
    max_triangles: 250_000,
    max_draw_calls: 1_000,
    max_attribute_bytes: 64 * 1024 * 1024,
    min_cache_hit_ratio: 0.55,
    reject_degenerate_triangles: true,
  }
}

///|
pub fn primitive_attribute_accessor(
  primitive : GltfPrimitive,
  name : String,
) -> Int? {
  primitive.attributes.get(name)
}

///|
pub fn primitive_has_attribute(
  primitive : GltfPrimitive,
  name : String,
) -> Bool {
  primitive.attributes.get(name) is Some(_)
}

///|
pub fn primitive_channel_summary(
  primitive : GltfPrimitive,
) -> GeometryChannelSummary {
  let known : Map[String, Bool] = Map([])
  let position = primitive_has_attribute(primitive, "POSITION")
  let normal = primitive_has_attribute(primitive, "NORMAL")
  let tangent = primitive_has_attribute(primitive, "TANGENT")
  let texcoord_0 = primitive_has_attribute(primitive, "TEXCOORD_0")
  let texcoord_1 = primitive_has_attribute(primitive, "TEXCOORD_1")
  let color_0 = primitive_has_attribute(primitive, "COLOR_0")
  let joints_0 = primitive_has_attribute(primitive, "JOINTS_0")
  let weights_0 = primitive_has_attribute(primitive, "WEIGHTS_0")
  known["POSITION"] = true
  known["NORMAL"] = true
  known["TANGENT"] = true
  known["TEXCOORD_0"] = true
  known["TEXCOORD_1"] = true
  known["COLOR_0"] = true
  known["JOINTS_0"] = true
  known["WEIGHTS_0"] = true
  let mut custom_count = 0
  for name, _ in primitive.attributes {
    if !known.contains(name) {
      custom_count += 1
    }
  }
  {
    position,
    normal,
    tangent,
    texcoord_0,
    texcoord_1,
    color_0,
    joints_0,
    weights_0,
    custom_count,
  }
}

///|
pub fn primitive_positions(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
) -> Array[Vec3] {
  match primitive_attribute_accessor(primitive, "POSITION") {
    Some(accessor) => decode_position_values(doc, asset, accessor)
    None => []
  }
}

///|
pub fn primitive_normals(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
) -> Array[Vec3] {
  match primitive_attribute_accessor(primitive, "NORMAL") {
    Some(accessor) => decode_normal_values(doc, asset, accessor)
    None => []
  }
}

///|
pub fn primitive_tangents(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
) -> Array[Vec4] {
  match primitive_attribute_accessor(primitive, "TANGENT") {
    Some(accessor) => decode_accessor_vectors(doc, asset, accessor).values
    None => []
  }
}

///|
pub fn primitive_texcoords(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
  set : Int,
) -> Array[Vec2] {
  let name = "TEXCOORD_\{set}"
  match primitive_attribute_accessor(primitive, name) {
    Some(accessor) => decode_texcoord_values(doc, asset, accessor)
    None => []
  }
}

///|
pub fn primitive_colors(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
) -> Array[Vec4] {
  match primitive_attribute_accessor(primitive, "COLOR_0") {
    Some(accessor) => decode_accessor_vectors(doc, asset, accessor).values
    None => []
  }
}

///|
pub fn primitive_indices(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
) -> Array[Int] {
  match primitive.indices {
    Some(accessor) => decode_index_values(doc, asset, accessor)
    None => {
      let count = primitive_vertex_count(doc, primitive)
      let values : Array[Int] = []
      for index in 0..<count {
        values.push(index)
      }
      values
    }
  }
}

///|
pub fn primitive_index_count_from_data(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
) -> Int {
  primitive_indices(doc, asset, primitive).length()
}

///|
pub fn triangle_index_is_valid(
  triangle : TriangleIndex,
  vertex_count : Int,
) -> Bool {
  triangle.a >= 0 &&
  triangle.b >= 0 &&
  triangle.c >= 0 &&
  triangle.a < vertex_count &&
  triangle.b < vertex_count &&
  triangle.c < vertex_count
}

///|
pub fn triangle_index_has_duplicate_vertex(triangle : TriangleIndex) -> Bool {
  triangle.a == triangle.b ||
  triangle.b == triangle.c ||
  triangle.a == triangle.c
}

///|
fn triangle_array_from_indices(
  indices : Array[Int],
  mode : PrimitiveMode,
) -> Array[TriangleIndex] {
  let triangles : Array[TriangleIndex] = []
  match mode {
    Triangles => {
      let limit = indices.length() - indices.length() % 3
      for index in 0..<((if limit < 0 { 0 } else { limit }) / 3) {
        triangles.push({
          a: indices[index * 3],
          b: indices[index * 3 + 1],
          c: indices[index * 3 + 2],
        })
      }
    }
    TriangleStrip =>
      if indices.length() >= 3 {
        for index in 0..<(indices.length() - 2) {
          let a = indices[index]
          let b = indices[index + 1]
          let c = indices[index + 2]
          if index % 2 == 0 {
            triangles.push({ a, b, c })
          } else {
            triangles.push({ a: b, b: a, c })
          }
        }
      }
    TriangleFan =>
      if indices.length() >= 3 {
        let root = indices[0]
        for index in 1..<(indices.length() - 1) {
          triangles.push({ a: root, b: indices[index], c: indices[index + 1] })
        }
      }
    _ => ()
  }
  triangles
}

///|
pub fn primitive_triangles(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
) -> Array[TriangleIndex] {
  triangle_array_from_indices(
    primitive_indices(doc, asset, primitive),
    primitive.mode,
  )
}

///|
pub fn triangle_position(
  positions : Array[Vec3],
  triangle : TriangleIndex,
  vertex : Int,
) -> Vec3? {
  let index = match vertex {
    0 => triangle.a
    1 => triangle.b
    _ => triangle.c
  }
  positions.get(index)
}

///|
pub fn triangle_edge_ab(
  positions : Array[Vec3],
  triangle : TriangleIndex,
) -> Vec3? {
  match (positions.get(triangle.a), positions.get(triangle.b)) {
    (Some(a), Some(b)) => Some(vec3_sub(b, a))
    _ => None
  }
}

///|
pub fn triangle_edge_ac(
  positions : Array[Vec3],
  triangle : TriangleIndex,
) -> Vec3? {
  match (positions.get(triangle.a), positions.get(triangle.c)) {
    (Some(a), Some(c)) => Some(vec3_sub(c, a))
    _ => None
  }
}

///|
pub fn triangle_cross(
  positions : Array[Vec3],
  triangle : TriangleIndex,
) -> Vec3? {
  match
    (
      triangle_edge_ab(positions, triangle),
      triangle_edge_ac(positions, triangle),
    ) {
    (Some(ab), Some(ac)) => Some(vec3_cross(ab, ac))
    _ => None
  }
}

///|
pub fn triangle_area(
  positions : Array[Vec3],
  triangle : TriangleIndex,
) -> Double {
  match triangle_cross(positions, triangle) {
    Some(cross) => Double::sqrt(vec3_length_squared(cross)) * 0.5
    None => 0.0
  }
}

///|
pub fn triangle_normal(
  positions : Array[Vec3],
  triangle : TriangleIndex,
) -> Vec3 {
  match triangle_cross(positions, triangle) {
    None => { x: 0.0, y: 0.0, z: 0.0 }
    Some(cross) => {
      let length = Double::sqrt(vec3_length_squared(cross))
      if length <= 0.0 {
        { x: 0.0, y: 0.0, z: 0.0 }
      } else {
        vec3_scale(cross, 1.0 / length)
      }
    }
  }
}

///|
pub fn triangle_winding(
  positions : Array[Vec3],
  triangle : TriangleIndex,
) -> PrimitiveWinding {
  match triangle_cross(positions, triangle) {
    None => Degenerate
    Some(cross) => {
      let magnitude = vec3_length_squared(cross)
      if magnitude <= 0.0000000001 {
        Degenerate
      } else if cross.z < 0.0 {
        Clockwise
      } else {
        CounterClockwise
      }
    }
  }
}

///|
pub fn positions_bounds(positions : Array[Vec3]) -> Bounds3 {
  let mut bounds = bounds_empty()
  for position in positions {
    bounds = bounds_include(bounds, position)
  }
  bounds
}

///|
pub fn bounds_contains_point(bounds : Bounds3, point : Vec3) -> Bool {
  bounds.valid &&
  point.x >= bounds.min.x &&
  point.x <= bounds.max.x &&
  point.y >= bounds.min.y &&
  point.y <= bounds.max.y &&
  point.z >= bounds.min.z &&
  point.z <= bounds.max.z
}

///|
pub fn bounds_contains_bounds(outer : Bounds3, inner : Bounds3) -> Bool {
  if !inner.valid {
    true
  } else {
    bounds_contains_point(outer, inner.min) &&
    bounds_contains_point(outer, inner.max)
  }
}

///|
pub fn bounds_volume(bounds : Bounds3) -> Double {
  if !bounds.valid {
    0.0
  } else {
    let extent = bounds_extent(bounds)
    extent.x * extent.y * extent.z
  }
}

///|
pub fn bounds_diagonal_length(bounds : Bounds3) -> Double {
  if !bounds.valid {
    0.0
  } else {
    Double::sqrt(vec3_length_squared(bounds_extent(bounds)))
  }
}

///|
pub fn bounds_distance_to_point(bounds : Bounds3, point : Vec3) -> Double {
  if !bounds.valid {
    0.0
  } else {
    let dx = if point.x < bounds.min.x {
      bounds.min.x - point.x
    } else if point.x > bounds.max.x {
      point.x - bounds.max.x
    } else {
      0.0
    }
    let dy = if point.y < bounds.min.y {
      bounds.min.y - point.y
    } else if point.y > bounds.max.y {
      point.y - bounds.max.y
    } else {
      0.0
    }
    let dz = if point.z < bounds.min.z {
      bounds.min.z - point.z
    } else if point.z > bounds.max.z {
      point.z - bounds.max.z
    } else {
      0.0
    }
    Double::sqrt(dx * dx + dy * dy + dz * dz)
  }
}

///|
fn metrics_for_triangles(
  positions : Array[Vec3],
  triangles : Array[TriangleIndex],
) -> TriangleMetrics {
  let mut area = 0.0
  let mut min_area = 0.0
  let mut max_area = 0.0
  let mut degenerate = 0
  let mut valid_indices = 0
  let mut invalid_indices = 0
  let mut first_winding : PrimitiveWinding = Unknown
  for triangle in triangles {
    if triangle_index_is_valid(triangle, positions.length()) {
      valid_indices += 3
      let value = triangle_area(positions, triangle)
      area += value
      if value <= 0.0000000001 {
        degenerate += 1
      }
      if min_area == 0.0 || value < min_area {
        min_area = value
      }
      if value > max_area {
        max_area = value
      }
      let winding = triangle_winding(positions, triangle)
      if first_winding == Unknown {
        first_winding = winding
      } else if first_winding != winding && winding != Degenerate {
        first_winding = Unknown
      }
    } else {
      invalid_indices += 3
    }
  }
  {
    triangle_count: triangles.length(),
    degenerate_count: degenerate,
    area,
    min_area,
    max_area,
    winding: if triangles.length() == 0 {
      Unknown
    } else {
      first_winding
    },
    valid_index_count: valid_indices,
    invalid_index_count: invalid_indices,
  }
}

///|
pub fn primitive_triangle_metrics(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
) -> TriangleMetrics {
  let positions = primitive_positions(doc, asset, primitive)
  let triangles = primitive_triangles(doc, asset, primitive)
  metrics_for_triangles(positions, triangles)
}

///|
pub fn triangle_count_for_mode(
  mode : PrimitiveMode,
  element_count : Int,
) -> Int {
  if element_count < 0 {
    0
  } else {
    match mode {
      Triangles => element_count / 3
      TriangleStrip | TriangleFan =>
        if element_count >= 3 {
          element_count - 2
        } else {
          0
        }
      _ => 0
    }
  }
}

///|
pub fn line_count_for_mode(mode : PrimitiveMode, element_count : Int) -> Int {
  if element_count < 0 {
    0
  } else {
    match mode {
      Lines => element_count / 2
      LineLoop => element_count
      LineStrip => if element_count >= 2 { element_count - 1 } else { 0 }
      _ => 0
    }
  }
}

///|
pub fn point_count_for_mode(mode : PrimitiveMode, element_count : Int) -> Int {
  match mode {
    Points => if element_count < 0 { 0 } else { element_count }
    _ => 0
  }
}

///|
pub fn primitive_attribute_bytes(
  doc : GltfDocument,
  primitive : GltfPrimitive,
) -> Int {
  let mut total = 0
  for _, accessor_index in primitive.attributes {
    match doc.accessors.get(accessor_index) {
      Some(accessor) =>
        total += accessor_element_size(accessor) * accessor.count
      None => ()
    }
  }
  total
}

///|
pub fn primitive_index_bytes(
  doc : GltfDocument,
  primitive : GltfPrimitive,
) -> Int {
  match primitive.indices {
    Some(accessor_index) =>
      match doc.accessors.get(accessor_index) {
        Some(accessor) => accessor_element_size(accessor) * accessor.count
        None => 0
      }
    None => 0
  }
}

///|
pub fn primitive_total_bytes(
  doc : GltfDocument,
  primitive : GltfPrimitive,
) -> Int {
  primitive_attribute_bytes(doc, primitive) +
  primitive_index_bytes(doc, primitive)
}

///|
pub fn primitive_vertex_reuse_ratio(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
) -> Double {
  let indices = primitive_indices(doc, asset, primitive)
  if indices.length() == 0 {
    0.0
  } else {
    let unique : Map[Int, Bool] = Map([])
    for index in indices {
      unique[index] = true
    }
    1.0 - unique.length().to_double() / indices.length().to_double()
  }
}

///|
pub fn simulate_vertex_cache(indices : Array[Int], cache_size : Int) -> Double {
  if indices.length() == 0 || cache_size <= 0 {
    0.0
  } else {
    let cache : Array[Int] = []
    let mut hits = 0
    for index in indices {
      let mut found = false
      for old in cache {
        if old == index {
          found = true
        }
      }
      if found {
        hits += 1
      } else {
        cache.push(index)
        if cache.length() > cache_size {
          ignore(cache.remove(0))
        }
      }
    }
    hits.to_double() / indices.length().to_double()
  }
}

///|
pub fn primitive_cache_hit_ratio(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
  cache_size? : Int = 16,
) -> Double {
  simulate_vertex_cache(primitive_indices(doc, asset, primitive), cache_size)
}

///|
pub fn primitive_overdraw_proxy(
  positions : Array[Vec3],
  triangles : Array[TriangleIndex],
) -> Double {
  if triangles.length() == 0 || positions.length() == 0 {
    0.0
  } else {
    let bounds = positions_bounds(positions)
    let surface = bounds_surface_area(bounds)
    let average_area = triangles.fold(init=0.0, (sum, triangle) => {
        sum + triangle_area(positions, triangle)
      }) /
      triangles.length().to_double()
    if surface <= 0.0 {
      0.0
    } else {
      average_area / surface
    }
  }
}

///|
pub fn primitive_geometry_report(
  doc : GltfDocument,
  asset : BinaryAsset,
  mesh_index : Int,
  primitive_index : Int,
  primitive : GltfPrimitive,
) -> PrimitiveGeometryReport {
  let positions = primitive_positions(doc, asset, primitive)
  let indices = primitive_indices(doc, asset, primitive)
  let triangles = triangle_array_from_indices(indices, primitive.mode)
  let triangle_metrics = metrics_for_triangles(positions, triangles)
  {
    mesh_index,
    primitive_index,
    topology: primitive_topology_name(primitive.mode),
    vertex_count: positions.length(),
    index_count: indices.length(),
    triangle_count: triangles.length(),
    bounds: positions_bounds(positions),
    channels: primitive_channel_summary(primitive),
    triangles: triangle_metrics,
    attribute_bytes: primitive_total_bytes(doc, primitive),
    indexed: primitive.indices is Some(_),
    cache_hit_ratio: simulate_vertex_cache(indices, 16),
    overdraw_proxy: primitive_overdraw_proxy(positions, triangles),
  }
}

///|
pub fn mesh_geometry_report(
  doc : GltfDocument,
  asset : BinaryAsset,
  mesh_index : Int,
) -> MeshGeometryReport {
  match doc.meshes.get(mesh_index) {
    None =>
      {
        mesh_index,
        primitive_count: 0,
        vertex_count: 0,
        index_count: 0,
        triangle_count: 0,
        degenerate_triangle_count: 0,
        bounds: bounds_empty(),
        attribute_bytes: 0,
        cache_hit_ratio: 0.0,
        primitives: [],
      }
    Some(mesh) => {
      let reports : Array[PrimitiveGeometryReport] = []
      let mut vertices = 0
      let mut indices = 0
      let mut triangles = 0
      let mut degenerates = 0
      let mut bytes = 0
      let mut cache_weight = 0.0
      let mut bounds = bounds_empty()
      for index, primitive in mesh.primitives {
        let report = primitive_geometry_report(
          doc, asset, mesh_index, index, primitive,
        )
        reports.push(report)
        vertices += report.vertex_count
        indices += report.index_count
        triangles += report.triangle_count
        degenerates += report.triangles.degenerate_count
        bytes += report.attribute_bytes
        cache_weight += report.cache_hit_ratio * report.index_count.to_double()
        bounds = bounds_union(bounds, report.bounds)
      }
      let cache_ratio = if indices == 0 {
        0.0
      } else {
        cache_weight / indices.to_double()
      }
      {
        mesh_index,
        primitive_count: mesh.primitives.length(),
        vertex_count: vertices,
        index_count: indices,
        triangle_count: triangles,
        degenerate_triangle_count: degenerates,
        bounds,
        attribute_bytes: bytes,
        cache_hit_ratio: cache_ratio,
        primitives: reports,
      }
    }
  }
}

///|
pub fn all_mesh_geometry_reports(
  doc : GltfDocument,
  asset : BinaryAsset,
) -> Array[MeshGeometryReport] {
  let reports : Array[MeshGeometryReport] = []
  for index in 0..<doc.meshes.length() {
    reports.push(mesh_geometry_report(doc, asset, index))
  }
  reports
}

///|
pub fn document_geometry_report(
  doc : GltfDocument,
  asset : BinaryAsset,
) -> DocumentGeometryReport {
  let meshes = all_mesh_geometry_reports(doc, asset)
  let mut vertices = 0
  let mut indices = 0
  let mut triangles = 0
  let mut degenerates = 0
  let mut bytes = 0
  let mut cache_weight = 0.0
  let mut primitive_count = 0
  let mut indexed = 0
  let mut bounds = bounds_empty()
  for mesh in meshes {
    vertices += mesh.vertex_count
    indices += mesh.index_count
    triangles += mesh.triangle_count
    degenerates += mesh.degenerate_triangle_count
    bytes += mesh.attribute_bytes
    primitive_count += mesh.primitive_count
    cache_weight += mesh.cache_hit_ratio * mesh.index_count.to_double()
    bounds = bounds_union(bounds, mesh.bounds)
  }
  for mesh in doc.meshes {
    for primitive in mesh.primitives {
      if primitive.indices is Some(_) {
        indexed += 1
      }
    }
  }
  {
    mesh_count: doc.meshes.length(),
    primitive_count,
    vertex_count: vertices,
    index_count: indices,
    triangle_count: triangles,
    degenerate_triangle_count: degenerates,
    bounds,
    attribute_bytes: bytes,
    indexed_ratio: if primitive_count == 0 {
      0.0
    } else {
      indexed.to_double() / primitive_count.to_double()
    },
    cache_hit_ratio: if indices == 0 {
      0.0
    } else {
      cache_weight / indices.to_double()
    },
    meshes,
  }
}

///|
pub fn geometry_budget_result(
  report : DocumentGeometryReport,
  budget : GeometryBudget,
) -> GeometryBudgetResult {
  let vertex_overage = if report.vertex_count > budget.max_vertices {
    report.vertex_count - budget.max_vertices
  } else {
    0
  }
  let index_overage = if report.index_count > budget.max_indices {
    report.index_count - budget.max_indices
  } else {
    0
  }
  let triangle_overage = if report.triangle_count > budget.max_triangles {
    report.triangle_count - budget.max_triangles
  } else {
    0
  }
  let draw_calls = report.primitive_count
  let draw_call_overage = if draw_calls > budget.max_draw_calls {
    draw_calls - budget.max_draw_calls
  } else {
    0
  }
  let attribute_byte_overage = if report.attribute_bytes >
    budget.max_attribute_bytes {
    report.attribute_bytes - budget.max_attribute_bytes
  } else {
    0
  }
  let cache_ratio_shortfall = if report.cache_hit_ratio <
    budget.min_cache_hit_ratio {
    budget.min_cache_hit_ratio - report.cache_hit_ratio
  } else {
    0.0
  }
  let violations : Array[String] = []
  if vertex_overage > 0 {
    violations.push("vertex budget exceeded by \{vertex_overage}")
  }
  if index_overage > 0 {
    violations.push("index budget exceeded by \{index_overage}")
  }
  if triangle_overage > 0 {
    violations.push("triangle budget exceeded by \{triangle_overage}")
  }
  if draw_call_overage > 0 {
    violations.push("draw-call budget exceeded by \{draw_call_overage}")
  }
  if attribute_byte_overage > 0 {
    violations.push(
      "attribute memory budget exceeded by \{attribute_byte_overage} bytes",
    )
  }
  if cache_ratio_shortfall > 0.0 {
    violations.push("vertex cache ratio is below the configured minimum")
  }
  if budget.reject_degenerate_triangles && report.degenerate_triangle_count > 0 {
    violations.push(
      "geometry contains \{report.degenerate_triangle_count} degenerate triangles",
    )
  }
  {
    passed: violations.length() == 0,
    violations,
    vertex_overage,
    index_overage,
    triangle_overage,
    draw_call_overage,
    attribute_byte_overage,
    cache_ratio_shortfall,
  }
}

///|
pub fn primitive_missing_channel_count(summary : GeometryChannelSummary) -> Int {
  let mut count = 0
  if !summary.position {
    count += 1
  }
  if !summary.normal {
    count += 1
  }
  if !summary.texcoord_0 {
    count += 1
  }
  if !summary.weights_0 && summary.joints_0 {
    count += 1
  }
  if summary.weights_0 && !summary.joints_0 {
    count += 1
  }
  count
}

///|
pub fn primitive_channel_is_complete(
  summary : GeometryChannelSummary,
  skinned : Bool,
) -> Bool {
  summary.position && (!skinned || (summary.joints_0 && summary.weights_0))
}

///|
pub fn primitive_has_custom_channels(summary : GeometryChannelSummary) -> Bool {
  summary.custom_count > 0
}

///|
pub fn mesh_bounds_with_transforms(
  doc : GltfDocument,
  asset : BinaryAsset,
  mesh_index : Int,
) -> Bounds3 {
  let report = mesh_geometry_report(doc, asset, mesh_index)
  report.bounds
}

///|
pub fn geometry_report_summary_lines(
  report : DocumentGeometryReport,
) -> Array[String] {
  [
    "meshes=\{report.mesh_count}, primitives=\{report.primitive_count}",
    "vertices=\{report.vertex_count}, indices=\{report.index_count}",
    "triangles=\{report.triangle_count}, degenerates=\{report.degenerate_triangle_count}",
    "attribute_bytes=\{report.attribute_bytes}",
    "indexed_ratio=\{report.indexed_ratio}, cache_hit_ratio=\{report.cache_hit_ratio}",
  ]
}

///|
pub fn geometry_report_is_empty(report : DocumentGeometryReport) -> Bool {
  report.mesh_count == 0 || report.primitive_count == 0
}

///|
pub fn geometry_report_has_invalid_indices(
  report : DocumentGeometryReport,
) -> Bool {
  for mesh in report.meshes {
    for primitive in mesh.primitives {
      if primitive.triangles.invalid_index_count > 0 {
        return true
      }
    }
  }
  false
}

///|
pub fn geometry_report_has_degenerate_triangles(
  report : DocumentGeometryReport,
) -> Bool {
  report.degenerate_triangle_count > 0
}

///|
pub fn geometry_report_average_triangles_per_mesh(
  report : DocumentGeometryReport,
) -> Double {
  if report.mesh_count == 0 {
    0.0
  } else {
    report.triangle_count.to_double() / report.mesh_count.to_double()
  }
}

///|
pub fn geometry_report_average_vertices_per_triangle(
  report : DocumentGeometryReport,
) -> Double {
  if report.triangle_count == 0 {
    0.0
  } else {
    report.vertex_count.to_double() / report.triangle_count.to_double()
  }
}

///|
pub fn geometry_report_largest_mesh(report : DocumentGeometryReport) -> Int? {
  let mut best : Int? = None
  let mut best_triangles = -1
  for mesh in report.meshes {
    if mesh.triangle_count > best_triangles {
      best_triangles = mesh.triangle_count
      best = Some(mesh.mesh_index)
    }
  }
  best
}

///|
pub fn geometry_report_largest_bounds(
  report : DocumentGeometryReport,
) -> Bounds3 {
  match geometry_report_largest_mesh(report) {
    None => bounds_empty()
    Some(index) =>
      match report.meshes.get(index) {
        Some(mesh) => mesh.bounds
        None => bounds_empty()
      }
  }
}
