///|
/// Meshlet, LOD, and vertex quantization planning.
///
/// These algorithms produce renderer-neutral partitioning metadata. They are
/// useful to streaming importers and offline compilers that need bounded
/// clusters, predictable memory, and level-of-detail estimates before a
/// target GPU-specific encoder is selected.

///|
pub(all) struct MeshletLimits {
  max_vertices : Int
  max_triangles : Int
  max_meshlets : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct Meshlet {
  index : Int
  vertices : Array[Int]
  triangles : Array[TriangleIndex]
  bounds : Bounds3
  triangle_count : Int
  vertex_count : Int
  local_index_bytes : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct MeshletBuildReport {
  mesh_index : Int
  primitive_index : Int
  limits : MeshletLimits
  meshlets : Array[Meshlet]
  source_triangles : Int
  source_vertices : Int
  partitioned_triangles : Int
  dropped_triangles : Int
  average_vertices : Double
  average_triangles : Double
  maximum_vertices : Int
  maximum_triangles : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct LodLevel {
  level : Int
  triangle_ratio : Double
  target_triangles : Int
  target_vertices : Int
  screen_error : Double
  suggested : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct LodPlan {
  levels : Array[LodLevel]
  source_triangles : Int
  source_vertices : Int
  memory_reduction_ratio : Double
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct QuantizationPlan {
  attribute : String
  component_count : Int
  bits : Int
  source_bounds : Bounds3
  quantized_min : Array[Int]
  quantized_max : Array[Int]
  max_error : Double
  relative_error : Double
  estimated_bytes_saved : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn default_meshlet_limits() -> MeshletLimits {
  { max_vertices: 64, max_triangles: 126, max_meshlets: 1000000 }
}

///|
pub fn mobile_meshlet_limits() -> MeshletLimits {
  { max_vertices: 32, max_triangles: 64, max_meshlets: 250000 }
}

///|
pub fn meshlet_limits_valid(limits : MeshletLimits) -> Bool {
  limits.max_vertices >= 3 &&
  limits.max_triangles >= 1 &&
  limits.max_meshlets >= 1
}

///|
pub fn meshlet_triangle_index_bytes(limits : MeshletLimits) -> Int {
  if limits.max_vertices <= 256 {
    1
  } else {
    2
  }
}

///|
pub fn meshlet_local_index_bytes(meshlet : Meshlet) -> Int {
  let width = if meshlet.vertices.length() <= 256 { 1 } else { 2 }
  meshlet.triangles.length() * 3 * width
}

///|
fn meshlet_bounds(positions : Array[Vec3], vertices : Array[Int]) -> Bounds3 {
  let mut bounds = bounds_empty()
  for index in vertices {
    match positions.get(index) {
      Some(value) => bounds = bounds_include(bounds, value)
      None => ()
    }
  }
  bounds
}

///|
fn meshlet_from_state(
  index : Int,
  positions : Array[Vec3],
  vertices : Array[Int],
  triangles : Array[TriangleIndex],
  limits : MeshletLimits,
) -> Meshlet {
  let meshlet = {
    index,
    vertices,
    triangles,
    bounds: meshlet_bounds(positions, vertices),
    triangle_count: triangles.length(),
    vertex_count: vertices.length(),
    local_index_bytes: 0,
    valid: vertices.length() <= limits.max_vertices &&
    triangles.length() <= limits.max_triangles,
  }
  { ..meshlet, local_index_bytes: meshlet_local_index_bytes(meshlet) }
}

///|
pub fn meshlet_partition(
  positions : Array[Vec3],
  triangles : Array[TriangleIndex],
  limits : MeshletLimits,
) -> MeshletBuildReport {
  let meshlets : Array[Meshlet] = []
  let current_vertices : Array[Int] = []
  let current_vertex_set : Map[Int, Bool] = Map([])
  let current_triangles : Array[TriangleIndex] = []
  let mut dropped = 0
  let mut meshlet_index = 0
  fn flush() {
    if current_triangles.length() > 0 {
      meshlets.push(
        meshlet_from_state(
          meshlet_index, positions, current_vertices, current_triangles, limits,
        ),
      )
      meshlet_index += 1
      current_vertices.clear()
      current_vertex_set.clear()
      current_triangles.clear()
    }
  }
  for triangle in triangles {
    let mut new_vertices = 0
    for vertex in [triangle.a, triangle.b, triangle.c] {
      if !current_vertex_set.contains(vertex) {
        new_vertices += 1
      }
    }
    let would_overflow = current_triangles.length() >= limits.max_triangles ||
      current_vertices.length() + new_vertices > limits.max_vertices
    if would_overflow {
      flush()
    }
    if triangle_index_is_valid(triangle, positions.length()) &&
      triangle_index_has_duplicate_vertex(triangle) == false &&
      current_triangles.length() < limits.max_triangles {
      for vertex in [triangle.a, triangle.b, triangle.c] {
        if !current_vertex_set.contains(vertex) {
          current_vertex_set[vertex] = true
          current_vertices.push(vertex)
        }
      }
      current_triangles.push(triangle)
    } else {
      dropped += 1
    }
  }
  flush()
  let mut maximum_vertices = 0
  let mut maximum_triangles = 0
  let mut total_vertices = 0
  let mut total_triangles = 0
  for meshlet in meshlets {
    if meshlet.vertex_count > maximum_vertices {
      maximum_vertices = meshlet.vertex_count
    }
    if meshlet.triangle_count > maximum_triangles {
      maximum_triangles = meshlet.triangle_count
    }
    total_vertices += meshlet.vertex_count
    total_triangles += meshlet.triangle_count
  }
  {
    mesh_index: -1,
    primitive_index: -1,
    limits,
    meshlets,
    source_triangles: triangles.length(),
    source_vertices: positions.length(),
    partitioned_triangles: total_triangles,
    dropped_triangles: dropped,
    average_vertices: if meshlet_index == 0 {
      0.0
    } else {
      total_vertices.to_double() / meshlet_index.to_double()
    },
    average_triangles: if meshlet_index == 0 {
      0.0
    } else {
      total_triangles.to_double() / meshlet_index.to_double()
    },
    maximum_vertices,
    maximum_triangles,
    valid: meshlet_limits_valid(limits) &&
    dropped == 0 &&
    meshlet_index <= limits.max_meshlets,
  }
}

///|
pub fn primitive_meshlet_report(
  doc : GltfDocument,
  asset : BinaryAsset,
  mesh_index : Int,
  primitive_index : Int,
  limits : MeshletLimits,
) -> MeshletBuildReport {
  match doc.meshes.get(mesh_index) {
    None => meshlet_partition([], [], limits)
    Some(mesh) =>
      match mesh.primitives.get(primitive_index) {
        None => meshlet_partition([], [], limits)
        Some(primitive) => {
          let positions = primitive_positions(doc, asset, primitive)
          let triangles = primitive_triangles(doc, asset, primitive)
          let report = meshlet_partition(positions, triangles, limits)
          { ..report, mesh_index, primitive_index }
        }
      }
  }
}

///|
pub fn mesh_meshlet_reports(
  doc : GltfDocument,
  asset : BinaryAsset,
  mesh_index : Int,
  limits : MeshletLimits,
) -> Array[MeshletBuildReport] {
  match doc.meshes.get(mesh_index) {
    None => []
    Some(mesh) => {
      let reports : Array[MeshletBuildReport] = []
      for primitive_index in 0..<mesh.primitives.length() {
        reports.push(
          primitive_meshlet_report(
            doc, asset, mesh_index, primitive_index, limits,
          ),
        )
      }
      reports
    }
  }
}

///|
pub fn document_meshlet_reports(
  doc : GltfDocument,
  asset : BinaryAsset,
  limits : MeshletLimits,
) -> Array[MeshletBuildReport] {
  let reports : Array[MeshletBuildReport] = []
  for mesh_index in 0..<doc.meshes.length() {
    for report in mesh_meshlet_reports(doc, asset, mesh_index, limits) {
      reports.push(report)
    }
  }
  reports
}

///|
pub fn meshlet_count(reports : Array[MeshletBuildReport]) -> Int {
  reports.fold(init=0, (sum, report) => sum + report.meshlets.length())
}

///|
pub fn meshlet_dropped_triangle_count(
  reports : Array[MeshletBuildReport],
) -> Int {
  reports.fold(init=0, (sum, report) => sum + report.dropped_triangles)
}

///|
pub fn meshlet_memory_bytes(reports : Array[MeshletBuildReport]) -> Int {
  reports.fold(init=0, (sum, report) => {
    report.meshlets.fold(init=sum, (inner, meshlet) => {
      inner + meshlet.local_index_bytes + meshlet.vertex_count * 4
    })
  })
}

///|
pub fn meshlet_average_occupancy(
  reports : Array[MeshletBuildReport],
) -> (Double, Double) {
  let mut count = 0
  let mut vertices = 0
  let mut triangles = 0
  for report in reports {
    count += report.meshlets.length()
    for meshlet in report.meshlets {
      vertices += meshlet.vertex_count
      triangles += meshlet.triangle_count
    }
  }
  if count == 0 {
    (0.0, 0.0)
  } else {
    (
      vertices.to_double() / count.to_double(),
      triangles.to_double() / count.to_double(),
    )
  }
}

///|
pub fn meshlet_local_index(meshlet : Meshlet, global_vertex : Int) -> Int? {
  let mut result : Int? = None
  for index, vertex in meshlet.vertices {
    if vertex == global_vertex && result is None {
      result = Some(index)
    }
  }
  result
}

///|
pub fn meshlet_global_triangle(
  meshlet : Meshlet,
  local_triangle : TriangleIndex,
) -> TriangleIndex? {
  match
    (
      meshlet.vertices.get(local_triangle.a),
      meshlet.vertices.get(local_triangle.b),
      meshlet.vertices.get(local_triangle.c),
    ) {
    (Some(a), Some(b), Some(c)) => Some({ a, b, c })
    _ => None
  }
}

///|
pub fn lod_level(
  level : Int,
  source_triangles : Int,
  source_vertices : Int,
  ratio : Double,
) -> LodLevel {
  let safe_ratio = if ratio < 0.0 {
    0.0
  } else if ratio > 1.0 {
    1.0
  } else {
    ratio
  }
  {
    level,
    triangle_ratio: safe_ratio,
    target_triangles: (source_triangles.to_double() * safe_ratio).to_int(),
    target_vertices: (source_vertices.to_double() * safe_ratio).to_int(),
    screen_error: 1.0 - safe_ratio,
    suggested: safe_ratio > 0.0 && safe_ratio < 1.0,
  }
}

///|
pub fn lod_plan(
  source_triangles : Int,
  source_vertices : Int,
  ratios : Array[Double],
) -> LodPlan {
  let levels : Array[LodLevel] = []
  let mut previous = 1.0
  for level, ratio in ratios {
    let safe_ratio = if ratio > previous { previous } else { ratio }
    levels.push(
      lod_level(level + 1, source_triangles, source_vertices, safe_ratio),
    )
    previous = safe_ratio
  }
  let last_ratio = match levels.get(levels.length() - 1) {
    Some(value) => value.triangle_ratio
    None => 1.0
  }
  {
    levels,
    source_triangles,
    source_vertices,
    memory_reduction_ratio: 1.0 - last_ratio,
    valid: source_triangles >= 0 && source_vertices >= 0,
  }
}

///|
pub fn default_lod_plan(
  source_triangles : Int,
  source_vertices : Int,
) -> LodPlan {
  lod_plan(source_triangles, source_vertices, [0.5, 0.25, 0.125])
}

///|
pub fn lod_level_for_distance(
  plan : LodPlan,
  distance : Double,
  thresholds : Array[Double],
) -> LodLevel? {
  if plan.levels.length() == 0 {
    None
  } else {
    let mut selected = plan.levels[0]
    for index, threshold in thresholds {
      if distance >= threshold {
        match plan.levels.get(index) {
          Some(level) => selected = level
          None => ()
        }
      }
    }
    Some(selected)
  }
}

///|
pub fn lod_total_triangles(plan : LodPlan) -> Int {
  plan.levels.fold(init=plan.source_triangles, (sum, level) => {
    sum + level.target_triangles
  })
}

///|
pub fn lod_plan_summary_lines(plan : LodPlan) -> Array[String] {
  [
    "source_triangles=\{plan.source_triangles}, source_vertices=\{plan.source_vertices}",
    "levels=\{plan.levels.length()}, memory_reduction=\{plan.memory_reduction_ratio}",
    "targets=\{plan.levels.map(level => "\{level.target_triangles}").join(",")}",
  ]
}

///|
pub fn quantization_plan_for_bounds(
  attribute : String,
  bounds : Bounds3,
  bits : Int,
  source_bytes : Int,
) -> QuantizationPlan {
  let safe_bits = if bits < 1 { 1 } else if bits > 24 { 24 } else { bits }
  let maximum = (1 << safe_bits) - 1
  let extent = bounds_extent(bounds)
  let quantized_min = [0, 0, 0]
  let quantized_max = [maximum, maximum, maximum]
  let max_extent = if extent.x > extent.y && extent.x > extent.z {
    extent.x
  } else if extent.y > extent.z {
    extent.y
  } else {
    extent.z
  }
  let error = if maximum <= 0 {
    max_extent
  } else {
    max_extent / maximum.to_double()
  }
  let target_bytes = source_bytes * safe_bits / 32
  {
    attribute,
    component_count: 3,
    bits: safe_bits,
    source_bounds: bounds,
    quantized_min,
    quantized_max,
    max_error: error,
    relative_error: if max_extent <= 0.0 {
      0.0
    } else {
      error / max_extent
    },
    estimated_bytes_saved: if source_bytes > target_bytes {
      source_bytes - target_bytes
    } else {
      0
    },
    valid: bounds.valid && source_bytes >= 0,
  }
}

///|
pub fn primitive_position_quantization(
  doc : GltfDocument,
  asset : BinaryAsset,
  mesh_index : Int,
  primitive_index : Int,
  bits : Int,
) -> QuantizationPlan {
  let report = primitive_geometry_report(
    doc,
    asset,
    mesh_index,
    primitive_index,
    match doc.meshes.get(mesh_index) {
      Some(mesh) =>
        match mesh.primitives.get(primitive_index) {
          Some(primitive) => primitive
          None =>
            { attributes: {}, indices: None, material: None, mode: Triangles }
        }
      None => { attributes: {}, indices: None, material: None, mode: Triangles }
    },
  )
  quantization_plan_for_bounds(
    "POSITION",
    report.bounds,
    bits,
    report.attribute_bytes,
  )
}

///|
pub fn quantization_error_is_acceptable(
  plan : QuantizationPlan,
  tolerance : Double,
) -> Bool {
  plan.valid && plan.relative_error <= tolerance
}

///|
pub fn meshlet_report_summary_lines(
  report : MeshletBuildReport,
) -> Array[String] {
  [
    "mesh=\{report.mesh_index}, primitive=\{report.primitive_index}",
    "meshlets=\{report.meshlets.length()}, source_triangles=\{report.source_triangles}",
    "partitioned=\{report.partitioned_triangles}, dropped=\{report.dropped_triangles}",
    "average_vertices=\{report.average_vertices}, average_triangles=\{report.average_triangles}",
    "max_vertices=\{report.maximum_vertices}, max_triangles=\{report.maximum_triangles}",
  ]
}
