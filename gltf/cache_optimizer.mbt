///|
/// Vertex-cache analysis and deterministic triangle reordering.
pub(all) struct CachePolicy {
  cache_size : Int
  max_reorder_passes : Int
  preserve_winding : Bool
  reject_degenerate : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct CacheMetrics {
  triangle_count : Int
  index_count : Int
  vertex_count : Int
  transformed_vertices : Int
  cache_hits : Int
  cache_misses : Int
  cache_hit_rate : Double
  acmr : Double
  atvr : Double
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct CacheReorderResult {
  indices : Array[Int]
  source_triangle_order : Array[Int]
  before : CacheMetrics
  after : CacheMetrics
  improvement : Double
  warnings : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct CacheCandidateScore {
  triangle_index : Int
  cache_hits : Int
  new_vertices : Int
  score : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct CacheBudget {
  max_acmr : Double
  max_atvr : Double
  min_hit_rate : Double
  require_indexed : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct CacheBudgetResult {
  passed : Bool
  violations : Array[String]
  metrics : CacheMetrics
} derive(Debug, ToJson, Eq)

///|
pub fn default_cache_policy() -> CachePolicy {
  {
    cache_size: 16,
    max_reorder_passes: 3,
    preserve_winding: true,
    reject_degenerate: true,
  }
}

///|
pub fn default_cache_budget() -> CacheBudget {
  { max_acmr: 3.0, max_atvr: 1.5, min_hit_rate: 0.25, require_indexed: false }
}

///|
pub fn cache_triangle_count(indices : Array[Int]) -> Int {
  indices.length() / 3
}

///|
pub fn cache_is_triangle_stream(indices : Array[Int]) -> Bool {
  indices.length() % 3 == 0
}

///|
pub fn cache_index_max(indices : Array[Int]) -> Int {
  let mut maximum = -1
  for index in indices {
    if index > maximum {
      maximum = index
    }
  }
  maximum
}

///|
pub fn cache_vertex_count(indices : Array[Int]) -> Int {
  cache_index_max(indices) + 1
}

///|
pub fn cache_index_is_valid(indices : Array[Int], vertex_count : Int) -> Bool {
  if !cache_is_triangle_stream(indices) {
    return false
  }
  indices.all(fn(index) { index >= 0 && index < vertex_count })
}

///|
pub fn cache_triangle_at(
  indices : Array[Int],
  triangle_index : Int,
) -> TopologyTriangle? {
  let base = triangle_index * 3
  match (indices.get(base), indices.get(base + 1), indices.get(base + 2)) {
    (Some(a), Some(b), Some(c)) => Some(topology_triangle(a, b, c))
    _ => None
  }
}

///|
pub fn cache_triangle_vertices(
  indices : Array[Int],
  triangle_index : Int,
) -> Array[Int] {
  match cache_triangle_at(indices, triangle_index) {
    Some(triangle) => topology_triangle_vertices(triangle)
    None => []
  }
}

///|
pub fn cache_triangle_has_vertex(
  indices : Array[Int],
  triangle_index : Int,
  vertex : Int,
) -> Bool {
  match cache_triangle_at(indices, triangle_index) {
    Some(triangle) => topology_triangle_has_vertex(triangle, vertex)
    None => false
  }
}

///|
pub fn cache_triangle_new_vertices(
  indices : Array[Int],
  triangle_index : Int,
  cache : Array[Int],
) -> Int {
  let mut count = 0
  for vertex in cache_triangle_vertices(indices, triangle_index) {
    if !cache.contains(vertex) {
      count = count + 1
    }
  }
  count
}

///|
pub fn cache_triangle_cache_hits(
  indices : Array[Int],
  triangle_index : Int,
  cache : Array[Int],
) -> Int {
  let mut count = 0
  for vertex in cache_triangle_vertices(indices, triangle_index) {
    if cache.contains(vertex) {
      count = count + 1
    }
  }
  count
}

///|
pub fn cache_triangle_score(
  indices : Array[Int],
  triangle_index : Int,
  cache : Array[Int],
) -> CacheCandidateScore {
  let hits = cache_triangle_cache_hits(indices, triangle_index, cache)
  let new_vertices = cache_triangle_new_vertices(indices, triangle_index, cache)
  let score = Double::from_int(hits) * 2.0 - Double::from_int(new_vertices)
  { triangle_index, cache_hits: hits, new_vertices, score }
}

///|
pub fn cache_push_vertex(
  cache : Array[Int],
  vertex : Int,
  cache_size : Int,
) -> Unit {
  let mut existing : Int? = None
  for index, value in cache {
    if value == vertex {
      existing = Some(index)
      break
    }
  }
  match existing {
    Some(index) => {
      ignore(cache.remove(index))
      cache.push(vertex)
    }
    None => cache.push(vertex)
  }
  while cache.length() > cache_size {
    ignore(cache.remove(0))
  }
}

///|
pub fn cache_push_triangle(
  cache : Array[Int],
  triangle : TopologyTriangle,
  cache_size : Int,
) -> Unit {
  cache_push_vertex(cache, triangle.a, cache_size)
  cache_push_vertex(cache, triangle.b, cache_size)
  cache_push_vertex(cache, triangle.c, cache_size)
}

///|
pub fn cache_simulate(
  indices : Array[Int],
  cache_size : Int,
  vertex_count : Int,
) -> CacheMetrics {
  let cache : Array[Int] = []
  let mut hits = 0
  let mut misses = 0
  let valid = cache_size > 0 && cache_index_is_valid(indices, vertex_count)
  let triangles = cache_triangle_count(indices)
  for triangle_index in 0..<triangles {
    match cache_triangle_at(indices, triangle_index) {
      None => ()
      Some(triangle) => {
        for vertex in topology_triangle_vertices(triangle) {
          if cache.contains(vertex) {
            hits = hits + 1
          } else {
            misses = misses + 1
          }
        }
        cache_push_triangle(cache, triangle, cache_size)
      }
    }
  }
  let references = hits + misses
  let hit_rate = if references == 0 {
    0.0
  } else {
    Double::from_int(hits) / Double::from_int(references)
  }
  let acmr = if triangles == 0 {
    0.0
  } else {
    Double::from_int(misses) / Double::from_int(triangles)
  }
  let atvr = if vertex_count == 0 {
    0.0
  } else {
    Double::from_int(misses) / Double::from_int(vertex_count)
  }
  {
    triangle_count: triangles,
    index_count: indices.length(),
    vertex_count,
    transformed_vertices: misses,
    cache_hits: hits,
    cache_misses: misses,
    cache_hit_rate: hit_rate,
    acmr,
    atvr,
    valid,
  }
}

///|
pub fn cache_metrics_for_triangles(
  triangles : Array[TopologyTriangle],
  cache_size : Int,
  vertex_count : Int,
) -> CacheMetrics {
  cache_simulate(
    topology_triangle_index_stream(triangles),
    cache_size,
    vertex_count,
  )
}

///|
pub fn cache_triangle_candidates(
  indices : Array[Int],
  selected : Array[Bool],
  cache : Array[Int],
) -> Array[CacheCandidateScore] {
  let result : Array[CacheCandidateScore] = []
  for triangle_index in 0..<cache_triangle_count(indices) {
    if !selected[triangle_index] {
      result.push(cache_triangle_score(indices, triangle_index, cache))
    }
  }
  result
}

///|
pub fn cache_best_candidate(
  candidates : Array[CacheCandidateScore],
) -> CacheCandidateScore? {
  let mut best : CacheCandidateScore? = None
  for candidate in candidates {
    match best {
      None => best = Some(candidate)
      Some(current) =>
        if candidate.score > current.score ||
          (
            candidate.score == current.score &&
            candidate.triangle_index < current.triangle_index
          ) {
          best = Some(candidate)
        }
    }
  }
  best
}

///|
pub fn cache_reorder_greedy(
  indices : Array[Int],
  vertex_count : Int,
  policy : CachePolicy,
) -> CacheReorderResult {
  let before = cache_simulate(indices, policy.cache_size, vertex_count)
  let warnings : Array[String] = []
  if !cache_is_triangle_stream(indices) {
    warnings.push("index stream is not divisible by three")
  }
  if policy.cache_size <= 0 {
    warnings.push("cache size must be positive")
  }
  let triangle_count = cache_triangle_count(indices)
  let selected = Array::make(triangle_count, false)
  let cache : Array[Int] = []
  let reordered : Array[Int] = []
  let order : Array[Int] = []
  for _ in 0..<triangle_count {
    let candidates = cache_triangle_candidates(indices, selected, cache)
    match cache_best_candidate(candidates) {
      None => ()
      Some(candidate) => {
        selected[candidate.triangle_index] = true
        order.push(candidate.triangle_index)
        match cache_triangle_at(indices, candidate.triangle_index) {
          None => ()
          Some(triangle) => {
            reordered.push(triangle.a)
            reordered.push(triangle.b)
            reordered.push(triangle.c)
            cache_push_triangle(cache, triangle, policy.cache_size)
          }
        }
      }
    }
  }
  let after = cache_simulate(reordered, policy.cache_size, vertex_count)
  let improvement = if before.acmr <= 0.0 {
    0.0
  } else {
    (before.acmr - after.acmr) / before.acmr
  }
  {
    indices: reordered,
    source_triangle_order: order,
    before,
    after,
    improvement,
    warnings,
  }
}

///|
pub fn cache_reorder_preserving_groups(
  indices : Array[Int],
  vertex_count : Int,
  policy : CachePolicy,
  group_size : Int,
) -> CacheReorderResult {
  if group_size <= 0 {
    return cache_reorder_greedy(indices, vertex_count, policy)
  }
  let before = cache_simulate(indices, policy.cache_size, vertex_count)
  let output : Array[Int] = []
  let order : Array[Int] = []
  let triangle_count = cache_triangle_count(indices)
  let mut start = 0
  while start < triangle_count {
    let end = if start + group_size < triangle_count {
      start + group_size
    } else {
      triangle_count
    }
    let group : Array[Int] = []
    for triangle_index in start..<end {
      match cache_triangle_at(indices, triangle_index) {
        Some(triangle) => {
          group.push(triangle.a)
          group.push(triangle.b)
          group.push(triangle.c)
          order.push(triangle_index)
        }
        None => ()
      }
    }
    for index in group {
      output.push(index)
    }
    start = end
  }
  let after = cache_simulate(output, policy.cache_size, vertex_count)
  let improvement = if before.acmr == 0.0 {
    0.0
  } else {
    (before.acmr - after.acmr) / before.acmr
  }
  {
    indices: output,
    source_triangle_order: order,
    before,
    after,
    improvement,
    warnings: [],
  }
}

///|
pub fn cache_duplicate_index_count(indices : Array[Int]) -> Int {
  let mut duplicates = 0
  for left in 0..<indices.length() {
    let first = left + 1
    for right in first..<indices.length() {
      if indices[left] == indices[right] {
        duplicates = duplicates + 1
      }
    }
  }
  duplicates
}

///|
pub fn cache_unique_index_count(indices : Array[Int]) -> Int {
  let seen : Map[Int, Bool] = Map([])
  for index in indices {
    seen[index] = true
  }
  let mut count = 0
  for _, _ in seen {
    count = count + 1
  }
  count
}

///|
pub fn cache_vertex_reuse_ratio(indices : Array[Int]) -> Double {
  if indices.length() == 0 {
    return 0.0
  }
  Double::from_int(indices.length() - cache_unique_index_count(indices)) /
  Double::from_int(indices.length())
}

///|
pub fn cache_degenerate_triangle_count(indices : Array[Int]) -> Int {
  topology_indexed_triangles(indices)
  .filter(topology_triangle_is_degenerate)
  .length()
}

///|
pub fn cache_validate_reorder(
  source : Array[Int],
  reordered : Array[Int],
) -> Bool {
  if source.length() != reordered.length() {
    return false
  }
  let source_keys : Map[String, Int] = Map([])
  let reordered_keys : Map[String, Int] = Map([])
  for triangle in topology_indexed_triangles(source) {
    let key = topology_triangle_canonical_key(triangle)
    source_keys[key] = match source_keys.get(key) {
      Some(value) => value + 1
      None => 1
    }
  }
  for triangle in topology_indexed_triangles(reordered) {
    let key = topology_triangle_canonical_key(triangle)
    reordered_keys[key] = match reordered_keys.get(key) {
      Some(value) => value + 1
      None => 1
    }
  }
  if source_keys.length() != reordered_keys.length() {
    return false
  }
  for key, count in source_keys {
    match reordered_keys.get(key) {
      Some(value) => if value != count { return false }
      None => return false
    }
  }
  true
}

///|
pub fn cache_budget_result(
  metrics : CacheMetrics,
  budget : CacheBudget,
) -> CacheBudgetResult {
  let violations : Array[String] = []
  if budget.require_indexed &&
    metrics.triangle_count == 0 &&
    metrics.index_count > 0 {
    violations.push("index data does not contain complete triangles")
  }
  if metrics.acmr > budget.max_acmr {
    violations.push("ACMR exceeds budget")
  }
  if metrics.atvr > budget.max_atvr {
    violations.push("ATVR exceeds budget")
  }
  if metrics.cache_hit_rate < budget.min_hit_rate {
    violations.push("vertex cache hit rate is below budget")
  }
  { passed: violations.length() == 0, violations, metrics }
}

///|
pub fn cache_metrics_delta(
  before : CacheMetrics,
  after : CacheMetrics,
) -> Array[Double] {
  [
    Double::from_int(after.cache_misses - before.cache_misses),
    after.cache_hit_rate - before.cache_hit_rate,
    after.acmr - before.acmr,
    after.atvr - before.atvr,
  ]
}

///|
pub fn cache_report_lines(metrics : CacheMetrics) -> Array[String] {
  [
    "triangles=\{metrics.triangle_count}",
    "indices=\{metrics.index_count}",
    "vertices=\{metrics.vertex_count}",
    "transformed_vertices=\{metrics.transformed_vertices}",
    "cache_hits=\{metrics.cache_hits}",
    "cache_misses=\{metrics.cache_misses}",
    "cache_hit_rate=\{metrics.cache_hit_rate}",
    "acmr=\{metrics.acmr}",
    "atvr=\{metrics.atvr}",
    "valid=\{metrics.valid}",
  ]
}

///|
pub fn cache_result_summary(result : CacheReorderResult) -> Array[String] {
  [
    "before_acmr=\{result.before.acmr}",
    "after_acmr=\{result.after.acmr}",
    "improvement=\{result.improvement}",
    "triangles_reordered=\{result.source_triangle_order.length()}",
    "warnings=\{result.warnings.length()}",
  ]
}
