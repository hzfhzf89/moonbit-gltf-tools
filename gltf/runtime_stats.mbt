///|
pub(all) struct RuntimeFrameSample {
  frame : Int
  cpu_millis : Double
  gpu_millis : Double
  upload_bytes : Int
  draw_calls : Int
  visible_instances : Int
  triangles : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct RuntimeStats {
  samples : Array[RuntimeFrameSample]
  frame_count : Int
  average_cpu_millis : Double
  average_gpu_millis : Double
  p95_cpu_millis : Double
  p95_gpu_millis : Double
  peak_upload_bytes : Int
  average_draw_calls : Double
  stable : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn runtime_frame_sample(
  frame : Int,
  cpu_millis : Double,
  gpu_millis : Double,
  upload_bytes : Int,
  draw_calls : Int,
  visible_instances : Int,
  triangles : Int,
) -> RuntimeFrameSample {
  {
    frame,
    cpu_millis,
    gpu_millis,
    upload_bytes,
    draw_calls,
    visible_instances,
    triangles,
  }
}

///|
pub fn runtime_sample_average(
  samples : Array[RuntimeFrameSample],
) -> (Double, Double) {
  let mut cpu = 0.0
  let mut gpu = 0.0
  for sample in samples {
    cpu = cpu + sample.cpu_millis
    gpu = gpu + sample.gpu_millis
  }
  let divisor = if samples.length() == 0 {
    1.0
  } else {
    Double::from_int(samples.length())
  }
  (cpu / divisor, gpu / divisor)
}

///|
pub fn runtime_sort_values(values : Array[Double]) -> Unit {
  for pass in 0..<values.length() {
    let limit = values.length() - pass - 1
    for index in 0..<limit {
      if values[index] > values[index + 1] {
        let old = values[index]
        values[index] = values[index + 1]
        values[index + 1] = old
      }
    }
  }
}

///|
pub fn runtime_percentile(
  values : Array[Double],
  percentile : Double,
) -> Double {
  if values.length() == 0 {
    return 0.0
  }
  let sorted = values.copy()
  runtime_sort_values(sorted)
  let p = if percentile < 0.0 {
    0.0
  } else if percentile > 1.0 {
    1.0
  } else {
    percentile
  }
  let index = (p * Double::from_int(sorted.length() - 1)).to_int()
  sorted[index]
}

///|
pub fn runtime_peak_upload(samples : Array[RuntimeFrameSample]) -> Int {
  let mut peak = 0
  for sample in samples {
    if sample.upload_bytes > peak {
      peak = sample.upload_bytes
    }
  }
  peak
}

///|
pub fn runtime_stats(samples : Array[RuntimeFrameSample]) -> RuntimeStats {
  let averages = runtime_sample_average(samples)
  let cpu : Array[Double] = samples.map(fn(sample) { sample.cpu_millis })
  let gpu : Array[Double] = samples.map(fn(sample) { sample.gpu_millis })
  let draw_calls = samples.map(fn(sample) {
    Double::from_int(sample.draw_calls)
  })
  let average_draw = if draw_calls.length() == 0 {
    0.0
  } else {
    draw_calls.fold(init=0.0, fn(total, value) { total + value }) /
    Double::from_int(draw_calls.length())
  }
  let p95_cpu = runtime_percentile(cpu, 0.95)
  let p95_gpu = runtime_percentile(gpu, 0.95)
  {
    samples,
    frame_count: samples.length(),
    average_cpu_millis: averages.0,
    average_gpu_millis: averages.1,
    p95_cpu_millis: p95_cpu,
    p95_gpu_millis: p95_gpu,
    peak_upload_bytes: runtime_peak_upload(samples),
    average_draw_calls: average_draw,
    stable: p95_cpu <= averages.0 * 2.0 && p95_gpu <= averages.1 * 2.0,
  }
}

///|
pub fn runtime_stats_merge(
  left : RuntimeStats,
  right : RuntimeStats,
) -> RuntimeStats {
  let samples = left.samples.copy()
  for sample in right.samples {
    samples.push(sample)
  }
  runtime_stats(samples)
}

///|
pub fn runtime_stats_frame_range(stats : RuntimeStats) -> (Int, Int) {
  match (stats.samples.get(0), stats.samples.get(stats.samples.length() - 1)) {
    (Some(first), Some(last)) => (first.frame, last.frame)
    _ => (0, 0)
  }
}

///|
pub fn runtime_stats_lines(stats : RuntimeStats) -> Array[String] {
  [
    "frames=\{stats.frame_count}",
    "average_cpu_ms=\{stats.average_cpu_millis}",
    "average_gpu_ms=\{stats.average_gpu_millis}",
    "p95_cpu_ms=\{stats.p95_cpu_millis}",
    "p95_gpu_ms=\{stats.p95_gpu_millis}",
    "peak_upload_bytes=\{stats.peak_upload_bytes}",
    "average_draw_calls=\{stats.average_draw_calls}",
    "stable=\{stats.stable}",
  ]
}

///|
pub fn runtime_stats_max_triangles(stats : RuntimeStats) -> Int {
  let mut maximum = 0
  for sample in stats.samples {
    if sample.triangles > maximum {
      maximum = sample.triangles
    }
  }
  maximum
}

///|
pub fn runtime_stats_max_instances(stats : RuntimeStats) -> Int {
  let mut maximum = 0
  for sample in stats.samples {
    if sample.visible_instances > maximum {
      maximum = sample.visible_instances
    }
  }
  maximum
}

///|
pub fn runtime_stats_average_triangles(stats : RuntimeStats) -> Double {
  if stats.samples.length() == 0 {
    return 0.0
  }
  let mut total = 0
  for sample in stats.samples {
    total = total + sample.triangles
  }
  Double::from_int(total) / Double::from_int(stats.samples.length())
}

///|
pub fn runtime_stats_average_instances(stats : RuntimeStats) -> Double {
  if stats.samples.length() == 0 {
    return 0.0
  }
  let mut total = 0
  for sample in stats.samples {
    total = total + sample.visible_instances
  }
  Double::from_int(total) / Double::from_int(stats.samples.length())
}

///|
pub fn runtime_stats_average_upload(stats : RuntimeStats) -> Double {
  if stats.samples.length() == 0 {
    return 0.0
  }
  let mut total = 0
  for sample in stats.samples {
    total = total + sample.upload_bytes
  }
  Double::from_int(total) / Double::from_int(stats.samples.length())
}

///|
pub fn runtime_stats_has_spike(
  stats : RuntimeStats,
  multiplier : Double,
) -> Bool {
  stats.p95_cpu_millis > stats.average_cpu_millis * multiplier ||
  stats.p95_gpu_millis > stats.average_gpu_millis * multiplier
}

///|
pub fn runtime_stats_frame_count(stats : RuntimeStats) -> Int {
  stats.samples.length()
}

///|
pub fn runtime_stats_total_upload(stats : RuntimeStats) -> Int {
  let mut total = 0
  for sample in stats.samples {
    total = total + sample.upload_bytes
  }
  total
}

///|
pub fn runtime_stats_total_draws(stats : RuntimeStats) -> Int {
  let mut total = 0
  for sample in stats.samples {
    total = total + sample.draw_calls
  }
  total
}
