///|
/// Runtime residency and streaming budget estimates.
///
/// A build service needs a conservative memory estimate before uploading an
/// asset. These values are derived from declared layouts and analysis results;
/// they do not assume a particular graphics API format.

///|
pub(all) struct RuntimeBudget {
  max_vertex_bytes : Int
  max_index_bytes : Int
  max_texture_bytes : Int
  max_animation_bytes : Int
  max_skin_bytes : Int
  max_total_bytes : Int
  max_stream_chunks : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct RuntimeEstimate {
  vertex_bytes : Int
  index_bytes : Int
  texture_bytes : Int
  animation_bytes : Int
  skin_bytes : Int
  metadata_bytes : Int
  total_bytes : Int
  resident_bytes : Int
  streamable_bytes : Int
  stream_chunks : Int
  peak_bytes : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct RuntimeBudgetResult {
  passed : Bool
  violations : Array[String]
  vertex_overage : Int
  index_overage : Int
  texture_overage : Int
  animation_overage : Int
  skin_overage : Int
  total_overage : Int
  chunk_overage : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct StreamChunk {
  index : Int
  offset : Int
  length : Int
  kind : String
  resident : Bool
  dependencies : Array[Int]
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn default_runtime_budget() -> RuntimeBudget {
  {
    max_vertex_bytes: 256 * 1024 * 1024,
    max_index_bytes: 128 * 1024 * 1024,
    max_texture_bytes: 512 * 1024 * 1024,
    max_animation_bytes: 128 * 1024 * 1024,
    max_skin_bytes: 64 * 1024 * 1024,
    max_total_bytes: 1024 * 1024 * 1024,
    max_stream_chunks: 4096,
  }
}

///|
pub fn mobile_runtime_budget() -> RuntimeBudget {
  {
    max_vertex_bytes: 64 * 1024 * 1024,
    max_index_bytes: 32 * 1024 * 1024,
    max_texture_bytes: 256 * 1024 * 1024,
    max_animation_bytes: 32 * 1024 * 1024,
    max_skin_bytes: 16 * 1024 * 1024,
    max_total_bytes: 384 * 1024 * 1024,
    max_stream_chunks: 1024,
  }
}

///|
pub fn runtime_estimate(profile : ProductionProfile) -> RuntimeEstimate {
  let vertex = profile.geometry.attribute_bytes
  let index = profile.geometry.index_count * 4
  let texture = profile.resources.resources.fold(init=0, (sum, resource) => {
    if resource.kind == Image || resource.kind == EmbeddedImage {
      sum + resource.declared_bytes
    } else {
      sum
    }
  })
  let animation = profile.animations.fold(init=0, (sum, report) => {
    sum +
    report.tracks.fold(init=0, (inner, track) => {
      inner + track.values.length() * 4 + track.times.length() * 4
    })
  })
  let skin = profile.skins.fold(init=0, (sum, report) => {
    sum + report.joint_count * 64
  })
  let metadata = profile.metrics.scene_nodes * 64 +
    profile.metrics.materials * 256
  let total = vertex + index + texture + animation + skin + metadata
  let streamable = if profile.resources.external_count > 0 {
    profile.resources.declared_bytes
  } else {
    0
  }
  {
    vertex_bytes: vertex,
    index_bytes: index,
    texture_bytes: texture,
    animation_bytes: animation,
    skin_bytes: skin,
    metadata_bytes: metadata,
    total_bytes: total,
    resident_bytes: total - streamable,
    streamable_bytes: streamable,
    stream_chunks: profile.resources.resources.length(),
    peak_bytes: total,
  }
}

///|
pub fn runtime_budget_result(
  estimate : RuntimeEstimate,
  budget : RuntimeBudget,
) -> RuntimeBudgetResult {
  let vertex_overage = if estimate.vertex_bytes > budget.max_vertex_bytes {
    estimate.vertex_bytes - budget.max_vertex_bytes
  } else {
    0
  }
  let index_overage = if estimate.index_bytes > budget.max_index_bytes {
    estimate.index_bytes - budget.max_index_bytes
  } else {
    0
  }
  let texture_overage = if estimate.texture_bytes > budget.max_texture_bytes {
    estimate.texture_bytes - budget.max_texture_bytes
  } else {
    0
  }
  let animation_overage = if estimate.animation_bytes >
    budget.max_animation_bytes {
    estimate.animation_bytes - budget.max_animation_bytes
  } else {
    0
  }
  let skin_overage = if estimate.skin_bytes > budget.max_skin_bytes {
    estimate.skin_bytes - budget.max_skin_bytes
  } else {
    0
  }
  let total_overage = if estimate.total_bytes > budget.max_total_bytes {
    estimate.total_bytes - budget.max_total_bytes
  } else {
    0
  }
  let chunk_overage = if estimate.stream_chunks > budget.max_stream_chunks {
    estimate.stream_chunks - budget.max_stream_chunks
  } else {
    0
  }
  let violations : Array[String] = []
  if vertex_overage > 0 {
    violations.push("vertex memory budget exceeded")
  }
  if index_overage > 0 {
    violations.push("index memory budget exceeded")
  }
  if texture_overage > 0 {
    violations.push("texture memory budget exceeded")
  }
  if animation_overage > 0 {
    violations.push("animation memory budget exceeded")
  }
  if skin_overage > 0 {
    violations.push("skin memory budget exceeded")
  }
  if total_overage > 0 {
    violations.push("total runtime memory budget exceeded")
  }
  if chunk_overage > 0 {
    violations.push("stream chunk budget exceeded")
  }
  {
    passed: violations.length() == 0,
    violations,
    vertex_overage,
    index_overage,
    texture_overage,
    animation_overage,
    skin_overage,
    total_overage,
    chunk_overage,
  }
}

///|
pub fn build_stream_chunks(
  profile : ProductionProfile,
  chunk_size : Int,
) -> Array[StreamChunk] {
  let safe_size = if chunk_size < 1 { 1 } else { chunk_size }
  let chunks : Array[StreamChunk] = []
  let mut offset = 0
  let mut index = 0
  for resource in profile.resources.resources {
    let length = if resource.declared_bytes <= 0 {
      1
    } else {
      resource.declared_bytes
    }
    let mut consumed = 0
    while consumed < length {
      let remaining = length - consumed
      let size = if remaining < safe_size { remaining } else { safe_size }
      chunks.push({
        index,
        offset,
        length: size,
        kind: resource_kind_name(resource.kind),
        resident: !resource.external,
        dependencies: if index == 0 {
          []
        } else {
          [index - 1]
        },
        valid: size > 0,
      })
      offset += size
      consumed += size
      index += 1
    }
  }
  chunks
}

///|
pub fn stream_chunk_total_bytes(chunks : Array[StreamChunk]) -> Int {
  chunks.fold(init=0, (sum, chunk) => sum + chunk.length)
}

///|
pub fn stream_chunk_resident_bytes(chunks : Array[StreamChunk]) -> Int {
  chunks.fold(init=0, (sum, chunk) => {
    if chunk.resident {
      sum + chunk.length
    } else {
      sum
    }
  })
}

///|
pub fn stream_chunk_summary_lines(chunks : Array[StreamChunk]) -> Array[String] {
  [
    "chunks=\{chunks.length()}, total_bytes=\{stream_chunk_total_bytes(chunks)}",
    "resident_bytes=\{stream_chunk_resident_bytes(chunks)}",
  ]
}
