///|
pub(all) struct LodQualitySample {
  level : Int
  triangle_count : Int
  vertex_count : Int
  geometric_error : Double
  texture_error : Double
  silhouette_error : Double
  memory_bytes : Int
  screen_error : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct LodQualityProfile {
  samples : Array[LodQualitySample]
  best_level : Int
  worst_level : Int
  total_memory_bytes : Int
  total_triangles : Int
  monotonic : Bool
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct LodSelectionPolicy {
  error_tolerance : Double
  screen_height : Double
  hysteresis : Double
  minimum_level : Int
  maximum_level : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct LodSelection {
  level : Int
  distance : Double
  screen_error : Double
  switched : Bool
  reason : String
} derive(Debug, ToJson, Eq)

///|
pub(all) struct LodBudget {
  max_triangles : Int
  max_memory_bytes : Int
  max_error : Double
  require_monotonic : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct LodBudgetResult {
  passed : Bool
  violations : Array[String]
  profile : LodQualityProfile
} derive(Debug, ToJson, Eq)

///|
pub fn lod_sample(
  level : Int,
  triangles : Int,
  vertices : Int,
  geometric_error : Double,
  texture_error : Double,
  silhouette_error : Double,
  memory_bytes : Int,
) -> LodQualitySample {
  let total_error = geometric_error + texture_error + silhouette_error
  {
    level,
    triangle_count: triangles,
    vertex_count: vertices,
    geometric_error,
    texture_error,
    silhouette_error,
    memory_bytes,
    screen_error: total_error,
  }
}

///|
pub fn lod_sample_screen_error(
  sample : LodQualitySample,
  distance : Double,
  screen_height : Double,
) -> Double {
  if distance <= 0.0 || screen_height <= 0.0 {
    sample.screen_error
  } else {
    sample.screen_error * screen_height / distance
  }
}

///|
pub fn lod_sample_is_better(
  left : LodQualitySample,
  right : LodQualitySample,
) -> Bool {
  left.screen_error < right.screen_error ||
  (
    left.screen_error == right.screen_error &&
    left.triangle_count < right.triangle_count
  )
}

///|
pub fn lod_sample_memory_per_triangle(sample : LodQualitySample) -> Double {
  if sample.triangle_count <= 0 {
    0.0
  } else {
    Double::from_int(sample.memory_bytes) /
    Double::from_int(sample.triangle_count)
  }
}

///|
pub fn lod_profile(samples : Array[LodQualitySample]) -> LodQualityProfile {
  let mut best = 0
  let mut worst = 0
  let mut memory = 0
  let mut triangles = 0
  let mut monotonic = true
  for index, sample in samples {
    memory = memory + sample.memory_bytes
    triangles = triangles + sample.triangle_count
    if index > 0 {
      match samples.get(index - 1) {
        Some(previous) => {
          if sample.triangle_count > previous.triangle_count {
            monotonic = false
          }
          if sample.screen_error < previous.screen_error {
            monotonic = false
          }
        }
        None => ()
      }
    }
    match samples.get(best) {
      Some(current) => if lod_sample_is_better(sample, current) { best = index }
      None => best = index
    }
    match samples.get(worst) {
      Some(current) =>
        if sample.screen_error > current.screen_error {
          worst = index
        }
      None => worst = index
    }
  }
  {
    samples,
    best_level: best,
    worst_level: worst,
    total_memory_bytes: memory,
    total_triangles: triangles,
    monotonic,
    valid: samples.length() > 0 && monotonic,
  }
}

///|
pub fn lod_profile_at(
  profile : LodQualityProfile,
  level : Int,
) -> LodQualitySample? {
  for sample in profile.samples {
    if sample.level == level {
      return Some(sample)
    }
  }
  None
}

///|
pub fn lod_profile_errors(profile : LodQualityProfile) -> Array[Double] {
  profile.samples.map(fn(sample) { sample.screen_error })
}

///|
pub fn lod_profile_memory(profile : LodQualityProfile) -> Array[Int] {
  profile.samples.map(fn(sample) { sample.memory_bytes })
}

///|
pub fn lod_profile_triangle_counts(profile : LodQualityProfile) -> Array[Int] {
  profile.samples.map(fn(sample) { sample.triangle_count })
}

///|
pub fn default_lod_selection_policy() -> LodSelectionPolicy {
  {
    error_tolerance: 1.0,
    screen_height: 1080.0,
    hysteresis: 0.1,
    minimum_level: 0,
    maximum_level: 32,
  }
}

///|
pub fn lod_select_level(
  profile : LodQualityProfile,
  distance : Double,
  policy : LodSelectionPolicy,
  previous_level : Int?,
) -> LodSelection {
  let mut selected = policy.maximum_level
  let mut selected_error = 1.0 / 0.0
  for sample in profile.samples {
    if sample.level < policy.minimum_level ||
      sample.level > policy.maximum_level {
      continue
    }
    let error = lod_sample_screen_error(sample, distance, policy.screen_height)
    if error <= policy.error_tolerance && error < selected_error {
      selected = sample.level
      selected_error = error
    }
  }
  if selected_error == 1.0 / 0.0 {
    match profile.samples.get(profile.samples.length() - 1) {
      Some(sample) => {
        selected = sample.level
        selected_error = lod_sample_screen_error(
          sample,
          distance,
          policy.screen_height,
        )
      }
      None => ()
    }
  }
  let switched = match previous_level {
    Some(previous) => previous != selected
    None => true
  }
  let reason = if !switched {
    "hysteresis"
  } else if selected == policy.minimum_level {
    "highest-detail"
  } else {
    "error-budget"
  }
  { level: selected, distance, screen_error: selected_error, switched, reason }
}

///|
pub fn lod_select_many(
  profile : LodQualityProfile,
  distances : Array[Double],
  policy : LodSelectionPolicy,
) -> Array[LodSelection] {
  distances.map(fn(distance) {
    lod_select_level(profile, distance, policy, None)
  })
}

///|
pub fn lod_transition_alpha(
  distance : Double,
  near_distance : Double,
  far_distance : Double,
) -> Double {
  if far_distance <= near_distance {
    if distance >= far_distance {
      1.0
    } else {
      0.0
    }
  } else {
    let value = (distance - near_distance) / (far_distance - near_distance)
    if value < 0.0 {
      0.0
    } else if value > 1.0 {
      1.0
    } else {
      value
    }
  }
}

///|
pub fn lod_budget_result(
  profile : LodQualityProfile,
  budget : LodBudget,
) -> LodBudgetResult {
  let violations : Array[String] = []
  if profile.total_triangles > budget.max_triangles {
    violations.push("total LOD triangles exceed budget")
  }
  if profile.total_memory_bytes > budget.max_memory_bytes {
    violations.push("total LOD memory exceeds budget")
  }
  for sample in profile.samples {
    if sample.screen_error > budget.max_error {
      violations.push("LOD error exceeds budget")
      break
    }
  }
  if budget.require_monotonic && !profile.monotonic {
    violations.push("LOD samples are not monotonic")
  }
  { passed: violations.length() == 0, violations, profile }
}

///|
pub fn lod_quality_score(profile : LodQualityProfile) -> Double {
  if profile.samples.length() == 0 {
    return 0.0
  }
  let mut score = 100.0
  if !profile.monotonic {
    score = score - 30.0
  }
  for sample in profile.samples {
    if sample.geometric_error > 1.0 {
      score = score - 5.0
    }
    if sample.texture_error > 1.0 {
      score = score - 5.0
    }
    if sample.silhouette_error > 1.0 {
      score = score - 5.0
    }
  }
  if score < 0.0 {
    0.0
  } else {
    score
  }
}

///|
pub fn lod_profile_lines(profile : LodQualityProfile) -> Array[String] {
  [
    "levels=\{profile.samples.length()}",
    "best_level=\{profile.best_level}",
    "worst_level=\{profile.worst_level}",
    "total_memory=\{profile.total_memory_bytes}",
    "total_triangles=\{profile.total_triangles}",
    "monotonic=\{profile.monotonic}",
    "quality_score=\{lod_quality_score(profile)}",
  ]
}
