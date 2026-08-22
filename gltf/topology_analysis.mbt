///|
/// Triangle topology analysis used by validators, mesh processors, and exporters.
pub(all) struct TopologyTriangle {
  a : Int
  b : Int
  c : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct TopologyEdge {
  first : Int
  second : Int
  triangle_count : Int
  first_triangle : Int
  second_triangle : Int?
  same_direction : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct TopologyComponent {
  triangle_indices : Array[Int]
  vertex_indices : Array[Int]
  boundary_edge_count : Int
  edge_count : Int
  manifold : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct TopologyReport {
  triangle_count : Int
  vertex_count : Int
  edge_count : Int
  boundary_edge_count : Int
  non_manifold_edge_count : Int
  degenerate_triangle_count : Int
  duplicate_triangle_count : Int
  component_count : Int
  isolated_vertex_count : Int
  winding_conflict_count : Int
  components : Array[TopologyComponent]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct TopologyPolicy {
  allow_boundary : Bool
  allow_non_manifold : Bool
  allow_degenerate : Bool
  max_components : Int
  max_isolated_vertices : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct TopologyBudgetResult {
  passed : Bool
  violations : Array[String]
  report : TopologyReport
} derive(Debug, ToJson, Eq)

///|
pub fn topology_triangle(a : Int, b : Int, c : Int) -> TopologyTriangle {
  { a, b, c }
}

///|
pub fn topology_triangle_vertices(triangle : TopologyTriangle) -> Array[Int] {
  [triangle.a, triangle.b, triangle.c]
}

///|
pub fn topology_triangle_is_degenerate(triangle : TopologyTriangle) -> Bool {
  triangle.a == triangle.b ||
  triangle.b == triangle.c ||
  triangle.a == triangle.c
}

///|
pub fn topology_triangle_has_vertex(
  triangle : TopologyTriangle,
  vertex : Int,
) -> Bool {
  triangle.a == vertex || triangle.b == vertex || triangle.c == vertex
}

///|
pub fn topology_triangle_edge_count(triangle : TopologyTriangle) -> Int {
  if topology_triangle_is_degenerate(triangle) {
    2
  } else {
    3
  }
}

///|
pub fn topology_edge_key(first : Int, second : Int) -> String {
  if first < second {
    "\{first}:\{second}"
  } else {
    "\{second}:\{first}"
  }
}

///|
pub fn topology_edge_endpoints(first : Int, second : Int) -> (Int, Int) {
  if first < second {
    (first, second)
  } else {
    (second, first)
  }
}

///|
pub fn topology_edge_direction(first : Int, second : Int) -> Bool {
  first < second
}

///|
pub fn topology_cross(a : Vec3, b : Vec3) -> Vec3 {
  {
    x: a.y * b.z - a.z * b.y,
    y: a.z * b.x - a.x * b.z,
    z: a.x * b.y - a.y * b.x,
  }
}

///|
pub fn topology_subtract(a : Vec3, b : Vec3) -> Vec3 {
  { x: a.x - b.x, y: a.y - b.y, z: a.z - b.z }
}

///|
pub fn topology_add(a : Vec3, b : Vec3) -> Vec3 {
  { x: a.x + b.x, y: a.y + b.y, z: a.z + b.z }
}

///|
pub fn topology_scale(value : Vec3, factor : Double) -> Vec3 {
  { x: value.x * factor, y: value.y * factor, z: value.z * factor }
}

///|
pub fn topology_dot(a : Vec3, b : Vec3) -> Double {
  a.x * b.x + a.y * b.y + a.z * b.z
}

///|
pub fn topology_length_squared(value : Vec3) -> Double {
  topology_dot(value, value)
}

///|
pub fn topology_distance_squared(a : Vec3, b : Vec3) -> Double {
  topology_length_squared(topology_subtract(a, b))
}

///|
pub fn topology_normalize(value : Vec3) -> Vec3 {
  let length = topology_length_squared(value)
  if length <= 0.0 {
    { x: 0.0, y: 0.0, z: 0.0 }
  } else {
    let inverse = 1.0 / Double::sqrt(length)
    topology_scale(value, inverse)
  }
}

///|
pub fn topology_triangle_area(a : Vec3, b : Vec3, c : Vec3) -> Double {
  let cross = topology_cross(topology_subtract(b, a), topology_subtract(c, a))
  Double::sqrt(topology_length_squared(cross)) * 0.5
}

///|
pub fn topology_triangle_normal(a : Vec3, b : Vec3, c : Vec3) -> Vec3 {
  topology_normalize(
    topology_cross(topology_subtract(b, a), topology_subtract(c, a)),
  )
}

///|
pub fn topology_triangle_signed_volume(a : Vec3, b : Vec3, c : Vec3) -> Double {
  topology_dot(a, topology_cross(b, c)) / 6.0
}

///|
pub fn topology_indexed_triangles(
  indices : Array[Int],
) -> Array[TopologyTriangle] {
  let triangles : Array[TopologyTriangle] = []
  let triangle_count = indices.length() / 3
  for index in 0..<triangle_count {
    let base = index * 3
    match (indices.get(base), indices.get(base + 1), indices.get(base + 2)) {
      (Some(a), Some(b), Some(c)) => triangles.push(topology_triangle(a, b, c))
      _ => ()
    }
  }
  triangles
}

///|
pub fn topology_triangle_index_stream(
  triangles : Array[TopologyTriangle],
) -> Array[Int] {
  let indices : Array[Int] = []
  for triangle in triangles {
    indices.push(triangle.a)
    indices.push(triangle.b)
    indices.push(triangle.c)
  }
  indices
}

///|
pub fn topology_triangle_key(triangle : TopologyTriangle) -> String {
  "\{triangle.a}:\{triangle.b}:\{triangle.c}"
}

///|
pub fn topology_triangle_canonical_key(triangle : TopologyTriangle) -> String {
  let values = [triangle.a, triangle.b, triangle.c]
  let mut first = values[0]
  let mut second = values[1]
  let mut third = values[2]
  if second < first {
    let old = first
    first = second
    second = old
  }
  if third < second {
    let old = second
    second = third
    third = old
  }
  if second < first {
    let old = first
    first = second
    second = old
  }
  "\{first}:\{second}:\{third}"
}

///|
pub fn topology_duplicate_triangle_count(
  triangles : Array[TopologyTriangle],
) -> Int {
  let seen : Map[String, Bool] = Map([])
  let mut duplicates = 0
  for triangle in triangles {
    let key = topology_triangle_canonical_key(triangle)
    if seen.contains(key) {
      duplicates = duplicates + 1
    } else {
      seen[key] = true
    }
  }
  duplicates
}

///|
fn topology_add_edge(
  edges : Map[String, TopologyEdge],
  first : Int,
  second : Int,
  triangle_index : Int,
) -> Unit {
  let endpoints = topology_edge_endpoints(first, second)
  let key = topology_edge_key(first, second)
  match edges.get(key) {
    None =>
      edges[key] = {
        first: endpoints.0,
        second: endpoints.1,
        triangle_count: 1,
        first_triangle: triangle_index,
        second_triangle: None,
        same_direction: topology_edge_direction(first, second),
      }
    Some(edge) =>
      edges[key] = {
        first: edge.first,
        second: edge.second,
        triangle_count: edge.triangle_count + 1,
        first_triangle: edge.first_triangle,
        second_triangle: Some(triangle_index),
        same_direction: edge.same_direction ==
        topology_edge_direction(first, second),
      }
  }
}

///|
pub fn topology_edges(
  triangles : Array[TopologyTriangle],
) -> Array[TopologyEdge] {
  let edges : Map[String, TopologyEdge] = Map([])
  for index, triangle in triangles {
    topology_add_edge(edges, triangle.a, triangle.b, index)
    topology_add_edge(edges, triangle.b, triangle.c, index)
    topology_add_edge(edges, triangle.c, triangle.a, index)
  }
  let result : Array[TopologyEdge] = []
  for _, edge in edges {
    result.push(edge)
  }
  result
}

///|
pub fn topology_boundary_edges(
  triangles : Array[TopologyTriangle],
) -> Array[TopologyEdge] {
  topology_edges(triangles).filter(fn(edge) { edge.triangle_count == 1 })
}

///|
pub fn topology_non_manifold_edges(
  triangles : Array[TopologyTriangle],
) -> Array[TopologyEdge] {
  topology_edges(triangles).filter(fn(edge) { edge.triangle_count > 2 })
}

///|
pub fn topology_winding_conflicts(
  triangles : Array[TopologyTriangle],
) -> Array[TopologyEdge] {
  topology_edges(triangles).filter(fn(edge) {
    edge.triangle_count == 2 && edge.same_direction
  })
}

///|
pub fn topology_vertex_references(
  triangles : Array[TopologyTriangle],
  vertex_count : Int,
) -> Array[Int] {
  let references = Array::make(vertex_count, 0)
  for triangle in triangles {
    if triangle.a >= 0 && triangle.a < vertex_count {
      references[triangle.a] = references[triangle.a] + 1
    }
    if triangle.b >= 0 && triangle.b < vertex_count {
      references[triangle.b] = references[triangle.b] + 1
    }
    if triangle.c >= 0 && triangle.c < vertex_count {
      references[triangle.c] = references[triangle.c] + 1
    }
  }
  references
}

///|
pub fn topology_isolated_vertices(
  triangles : Array[TopologyTriangle],
  vertex_count : Int,
) -> Array[Int] {
  let references = topology_vertex_references(triangles, vertex_count)
  let result : Array[Int] = []
  for index, count in references {
    if count == 0 {
      result.push(index)
    }
  }
  result
}

///|
pub fn topology_triangles_touching_vertex(
  triangles : Array[TopologyTriangle],
  vertex : Int,
) -> Array[Int] {
  let result : Array[Int] = []
  for index, triangle in triangles {
    if topology_triangle_has_vertex(triangle, vertex) {
      result.push(index)
    }
  }
  result
}

///|
pub fn topology_triangles_touching_triangle(
  triangles : Array[TopologyTriangle],
  triangle_index : Int,
) -> Array[Int] {
  let result : Array[Int] = []
  match triangles.get(triangle_index) {
    None => result
    Some(source) => {
      for index, candidate in triangles {
        if index != triangle_index &&
          (
            topology_triangle_has_vertex(candidate, source.a) ||
            topology_triangle_has_vertex(candidate, source.b) ||
            topology_triangle_has_vertex(candidate, source.c)
          ) {
          result.push(index)
        }
      }
      result
    }
  }
}

///|
pub fn topology_connected_components(
  triangles : Array[TopologyTriangle],
) -> Array[TopologyComponent] {
  let visited = Array::make(triangles.length(), false)
  let components : Array[TopologyComponent] = []
  for start, _ in triangles {
    if visited[start] {
      continue
    }
    let triangle_indices : Array[Int] = []
    let vertex_map : Map[Int, Bool] = Map([])
    let frontier : Array[Int] = [start]
    visited[start] = true
    while frontier.length() > 0 {
      let current = frontier.remove(0)
      triangle_indices.push(current)
      match triangles.get(current) {
        None => ()
        Some(triangle) => {
          vertex_map[triangle.a] = true
          vertex_map[triangle.b] = true
          vertex_map[triangle.c] = true
          for
            neighbor in topology_triangles_touching_triangle(triangles, current) {
            if !visited[neighbor] {
              visited[neighbor] = true
              frontier.push(neighbor)
            }
          }
        }
      }
    }
    let vertices : Array[Int] = []
    for vertex, _ in vertex_map {
      vertices.push(vertex)
    }
    let component_edges = topology_edges(
      triangle_indices.map(fn(index) {
        match triangles.get(index) {
          Some(value) => value
          None => topology_triangle(0, 0, 0)
        }
      }),
    )
    let boundary = component_edges
      .filter(fn(edge) { edge.triangle_count == 1 })
      .length()
    let manifold = component_edges.all(fn(edge) { edge.triangle_count <= 2 })
    components.push({
      triangle_indices,
      vertex_indices: vertices,
      boundary_edge_count: boundary,
      edge_count: component_edges.length(),
      manifold,
    })
  }
  components
}

///|
pub fn topology_report(
  triangles : Array[TopologyTriangle],
  vertex_count : Int,
) -> TopologyReport {
  let edges = topology_edges(triangles)
  let boundary = edges.filter(fn(edge) { edge.triangle_count == 1 }).length()
  let non_manifold = edges.filter(fn(edge) { edge.triangle_count > 2 }).length()
  let winding = edges
    .filter(fn(edge) { edge.triangle_count == 2 && edge.same_direction })
    .length()
  {
    triangle_count: triangles.length(),
    vertex_count,
    edge_count: edges.length(),
    boundary_edge_count: boundary,
    non_manifold_edge_count: non_manifold,
    degenerate_triangle_count: triangles
    .filter(topology_triangle_is_degenerate)
    .length(),
    duplicate_triangle_count: topology_duplicate_triangle_count(triangles),
    component_count: topology_connected_components(triangles).length(),
    isolated_vertex_count: topology_isolated_vertices(triangles, vertex_count).length(),
    winding_conflict_count: winding,
    components: topology_connected_components(triangles),
  }
}

///|
pub fn default_topology_policy() -> TopologyPolicy {
  {
    allow_boundary: true,
    allow_non_manifold: false,
    allow_degenerate: false,
    max_components: 10000,
    max_isolated_vertices: 0,
  }
}

///|
pub fn topology_budget_result(
  report : TopologyReport,
  policy : TopologyPolicy,
) -> TopologyBudgetResult {
  let violations : Array[String] = []
  if !policy.allow_boundary && report.boundary_edge_count > 0 {
    violations.push("boundary edges are not allowed")
  }
  if !policy.allow_non_manifold && report.non_manifold_edge_count > 0 {
    violations.push("non-manifold edges exceed policy")
  }
  if !policy.allow_degenerate && report.degenerate_triangle_count > 0 {
    violations.push("degenerate triangles exceed policy")
  }
  if report.component_count > policy.max_components {
    violations.push("component count exceeds policy")
  }
  if report.isolated_vertex_count > policy.max_isolated_vertices {
    violations.push("isolated vertex count exceeds policy")
  }
  { passed: violations.length() == 0, violations, report }
}

///|
pub fn topology_quality_score(report : TopologyReport) -> Double {
  let mut score = 100.0
  if report.triangle_count == 0 {
    return 0.0
  }
  score = score -
    Double::from_int(report.degenerate_triangle_count) *
    25.0 /
    Double::from_int(report.triangle_count)
  score = score -
    Double::from_int(report.duplicate_triangle_count) *
    15.0 /
    Double::from_int(report.triangle_count)
  score = score - Double::from_int(report.non_manifold_edge_count) * 5.0
  score = score - Double::from_int(report.winding_conflict_count) * 2.0
  if score < 0.0 {
    0.0
  } else {
    score
  }
}

///|
pub fn topology_component_largest(
  report : TopologyReport,
) -> TopologyComponent? {
  let mut best : TopologyComponent? = None
  for component in report.components {
    match best {
      None => best = Some(component)
      Some(current) =>
        if component.triangle_indices.length() >
          current.triangle_indices.length() {
          best = Some(component)
        }
    }
  }
  best
}

///|
pub fn topology_component_for_triangle(
  report : TopologyReport,
  triangle_index : Int,
) -> Int? {
  for component_index, component in report.components {
    if component.triangle_indices.contains(triangle_index) {
      return Some(component_index)
    }
  }
  None
}

///|
pub fn topology_report_lines(report : TopologyReport) -> Array[String] {
  [
    "triangles=\{report.triangle_count}",
    "vertices=\{report.vertex_count}",
    "edges=\{report.edge_count}",
    "boundary_edges=\{report.boundary_edge_count}",
    "non_manifold_edges=\{report.non_manifold_edge_count}",
    "degenerate_triangles=\{report.degenerate_triangle_count}",
    "duplicate_triangles=\{report.duplicate_triangle_count}",
    "components=\{report.component_count}",
    "isolated_vertices=\{report.isolated_vertex_count}",
    "winding_conflicts=\{report.winding_conflict_count}",
    "quality_score=\{topology_quality_score(report)}",
  ]
}
