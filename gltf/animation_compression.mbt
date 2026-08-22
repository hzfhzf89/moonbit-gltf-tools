///|
pub(all) enum AnimationCompressionMode {
  KeepAll
  RemoveLinear
  Quantize16
  Quantize8
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AnimationCompressionPolicy {
  mode : AnimationCompressionMode
  tolerance : Double
  minimum_keys : Int
  preserve_endpoints : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AnimationCompressionStats {
  source_keys : Int
  output_keys : Int
  removed_keys : Int
  source_components : Int
  output_components : Int
  maximum_error : Double
  average_error : Double
  compression_ratio : Double
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AnimationCompressedTrack {
  times : Array[Double]
  values : Array[Double]
  component_count : Int
  stats : AnimationCompressionStats
  source_indices : Array[Int]
} derive(Debug, ToJson, Eq)

///|
pub fn animation_compression_mode_name(
  mode : AnimationCompressionMode,
) -> String {
  match mode {
    KeepAll => "keep-all"
    RemoveLinear => "remove-linear"
    Quantize16 => "quantize-16"
    Quantize8 => "quantize-8"
  }
}

///|
pub fn default_animation_compression_policy() -> AnimationCompressionPolicy {
  {
    mode: RemoveLinear,
    tolerance: 0.0001,
    minimum_keys: 2,
    preserve_endpoints: true,
  }
}

///|
pub fn animation_quantize(
  value : Double,
  mode : AnimationCompressionMode,
) -> Double {
  let steps = match mode {
    Quantize16 => 65535.0
    Quantize8 => 255.0
    _ => 0.0
  }
  if steps == 0.0 {
    value
  } else {
    Double::round(value * steps) / steps
  }
}

///|
pub fn animation_value_at(
  values : Array[Double],
  key : Int,
  component : Int,
  width : Int,
) -> Double {
  match values.get(key * width + component) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn animation_linear_value(
  times : Array[Double],
  values : Array[Double],
  left : Int,
  time : Double,
  width : Int,
  component : Int,
) -> Double {
  let right = left + 1
  let left_time = match times.get(left) {
    Some(value) => value
    None => 0.0
  }
  let right_time = match times.get(right) {
    Some(value) => value
    None => left_time
  }
  let factor = if right_time <= left_time {
    0.0
  } else {
    (time - left_time) / (right_time - left_time)
  }
  let a = animation_value_at(values, left, component, width)
  let b = animation_value_at(values, right, component, width)
  a + (b - a) * factor
}

///|
pub fn animation_key_error(
  times : Array[Double],
  values : Array[Double],
  key : Int,
  width : Int,
) -> Double {
  if key <= 0 || key + 1 >= times.length() {
    return 0.0
  }
  let time = match times.get(key) {
    Some(value) => value
    None => 0.0
  }
  let mut squared = 0.0
  for component in 0..<width {
    let expected = animation_value_at(values, key, component, width)
    let actual = animation_linear_value(
      times,
      values,
      key - 1,
      time,
      width,
      component,
    )
    let delta = expected - actual
    squared = squared + delta * delta
  }
  Double::sqrt(squared)
}

///|
pub fn animation_reducible_keys(
  times : Array[Double],
  values : Array[Double],
  width : Int,
  tolerance : Double,
  minimum_keys : Int,
) -> Array[Bool] {
  let keep = Array::make(times.length(), true)
  let minimum = if minimum_keys < 2 { 2 } else { minimum_keys }
  if times.length() <= minimum {
    return keep
  }
  let limit = times.length() - 1
  for key in 1..<limit {
    if animation_key_error(times, values, key, width) <= tolerance {
      keep[key] = false
    }
  }
  let mut kept = keep.filter(fn(value) { value }).length()
  if kept < minimum {
    for key in 1..<limit {
      if !keep[key] {
        keep[key] = true
        kept = kept + 1
      }
      if kept >= minimum {
        break
      }
    }
  }
  keep
}

///|
pub fn animation_compress_track(
  track : AnimationTrack,
  policy : AnimationCompressionPolicy,
) -> AnimationCompressedTrack {
  let width = if track.component_count < 1 { 1 } else { track.component_count }
  let keep = match policy.mode {
    RemoveLinear =>
      animation_reducible_keys(
        track.times,
        track.values,
        width,
        policy.tolerance,
        policy.minimum_keys,
      )
    _ => Array::make(track.times.length(), true)
  }
  if policy.preserve_endpoints && keep.length() > 0 {
    keep[0] = true
    keep[keep.length() - 1] = true
  }
  let times : Array[Double] = []
  let values : Array[Double] = []
  let source_indices : Array[Int] = []
  let mut maximum_error = 0.0
  let mut error_sum = 0.0
  for key, keep_key in keep {
    if keep_key {
      match track.times.get(key) {
        Some(value) => times.push(value)
        None => ()
      }
      for component in 0..<width {
        let value = animation_value_at(track.values, key, component, width)
        values.push(animation_quantize(value, policy.mode))
      }
      source_indices.push(key)
    } else {
      let error = animation_key_error(track.times, track.values, key, width)
      if error > maximum_error {
        maximum_error = error
      }
      error_sum = error_sum + error
    }
  }
  let source_keys = track.times.length()
  let output_keys = times.length()
  let source_components = track.values.length()
  let output_components = values.length()
  {
    times,
    values,
    component_count: width,
    stats: {
      source_keys,
      output_keys,
      removed_keys: source_keys - output_keys,
      source_components,
      output_components,
      maximum_error,
      average_error: if source_keys == output_keys {
        0.0
      } else {
        error_sum / Double::from_int(source_keys - output_keys)
      },
      compression_ratio: if source_components == 0 {
        1.0
      } else {
        Double::from_int(output_components) /
        Double::from_int(source_components)
      },
      valid: output_keys >= policy.minimum_keys,
    },
    source_indices,
  }
}

///|
pub fn animation_compress_tracks(
  tracks : Array[AnimationTrack],
  policy : AnimationCompressionPolicy,
) -> Array[AnimationCompressedTrack] {
  tracks.map(fn(track) { animation_compress_track(track, policy) })
}

///|
pub fn animation_compression_total(
  results : Array[AnimationCompressedTrack],
) -> AnimationCompressionStats {
  let mut source_keys = 0
  let mut output_keys = 0
  let mut source_components = 0
  let mut output_components = 0
  let mut maximum_error = 0.0
  let mut error_sum = 0.0
  for result in results {
    source_keys = source_keys + result.stats.source_keys
    output_keys = output_keys + result.stats.output_keys
    source_components = source_components + result.stats.source_components
    output_components = output_components + result.stats.output_components
    if result.stats.maximum_error > maximum_error {
      maximum_error = result.stats.maximum_error
    }
    error_sum = error_sum + result.stats.average_error
  }
  let removed = source_keys - output_keys
  {
    source_keys,
    output_keys,
    removed_keys: removed,
    source_components,
    output_components,
    maximum_error,
    average_error: if results.length() == 0 {
      0.0
    } else {
      error_sum / Double::from_int(results.length())
    },
    compression_ratio: if source_components == 0 {
      1.0
    } else {
      Double::from_int(output_components) / Double::from_int(source_components)
    },
    valid: results.all(fn(result) { result.stats.valid }),
  }
}

///|
pub fn animation_compressed_value(
  track : AnimationCompressedTrack,
  key : Int,
  component : Int,
) -> Double {
  animation_value_at(track.values, key, component, track.component_count)
}

///|
pub fn animation_compressed_duration(
  track : AnimationCompressedTrack,
) -> Double {
  match (track.times.get(0), track.times.get(track.times.length() - 1)) {
    (Some(first), Some(last)) => last - first
    _ => 0.0
  }
}

///|
pub fn animation_compressed_monotonic(track : AnimationCompressedTrack) -> Bool {
  animation_times_are_monotonic(track.times)
}

///|
pub fn animation_compressed_expand(
  track : AnimationCompressedTrack,
  count : Int,
) -> Array[Double] {
  let result : Array[Double] = []
  if count <= 0 || track.times.length() == 0 {
    return result
  }
  for sample in 0..<count {
    let factor = if count == 1 {
      0.0
    } else {
      Double::from_int(sample) / Double::from_int(count - 1)
    }
    let time = track.times[0] + animation_compressed_duration(track) * factor
    let mut left = 0
    for index, value in track.times {
      if value <= time {
        left = index
      }
    }
    for component in 0..<track.component_count {
      if left + 1 < track.times.length() {
        result.push(
          animation_linear_value(
            track.times,
            track.values,
            left,
            time,
            track.component_count,
            component,
          ),
        )
      } else {
        result.push(animation_compressed_value(track, left, component))
      }
    }
  }
  result
}

///|
pub fn animation_compression_lines(
  stats : AnimationCompressionStats,
) -> Array[String] {
  [
    "source_keys=\{stats.source_keys}",
    "output_keys=\{stats.output_keys}",
    "removed_keys=\{stats.removed_keys}",
    "source_components=\{stats.source_components}",
    "output_components=\{stats.output_components}",
    "maximum_error=\{stats.maximum_error}",
    "average_error=\{stats.average_error}",
    "compression_ratio=\{stats.compression_ratio}",
    "valid=\{stats.valid}",
  ]
}
