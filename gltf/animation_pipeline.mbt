///|
/// Animation timeline inspection and deterministic sampling.
///
/// Import pipelines need more than a channel count: they need to know whether
/// key times are ordered, how long a clip lasts, whether a target can be
/// sampled safely, and what happens at the ends of a playback interval.

///|
pub(all) enum AnimationPlaybackMode {
  Clamp
  Repeat
  Mirror
} derive(Debug, ToJson, Eq)

///|
pub(all) enum AnimationTrackStatus {
  Valid
  Empty
  InvalidReference
  InvalidTimes
  UnsupportedShape
  DecodeFailed
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AnimationTrack {
  animation_index : Int
  channel_index : Int
  sampler_index : Int
  node : Int?
  path : AnimationPath
  interpolation : Interpolation
  input_accessor : Int
  output_accessor : Int
  times : Array[Double]
  values : Array[Double]
  component_count : Int
  status : AnimationTrackStatus
  errors : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AnimationClipReport {
  animation_index : Int
  name : String?
  channel_count : Int
  sampler_count : Int
  track_count : Int
  duration : Double
  start_time : Double
  end_time : Double
  loopable : Bool
  invalid_track_count : Int
  target_node_count : Int
  animated_path_count : Int
  tracks : Array[AnimationTrack]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AnimationSample {
  time : Double
  track_index : Int
  node : Int?
  path : AnimationPath
  values : Array[Double]
  normalized_time : Double
  clamped : Bool
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AnimationPoseValue {
  node : Int
  translation : Vec3?
  rotation : Quat?
  scale : Vec3?
  weights : Array[Double]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AnimationPose {
  animation_index : Int
  time : Double
  duration : Double
  values : Array[AnimationPoseValue]
  valid : Bool
  errors : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AnimationBudget {
  max_clips : Int
  max_channels : Int
  max_duration : Double
  max_keyframes : Int
  require_monotonic_times : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AnimationBudgetResult {
  passed : Bool
  violations : Array[String]
  clip_overage : Int
  channel_overage : Int
  duration_overage : Double
  keyframe_overage : Int
} derive(Debug, ToJson, Eq)

///|
pub fn default_animation_budget() -> AnimationBudget {
  {
    max_clips: 256,
    max_channels: 10000,
    max_duration: 3600.0,
    max_keyframes: 2_000_000,
    require_monotonic_times: true,
  }
}

///|
pub fn animation_playback_time(
  time : Double,
  duration : Double,
  mode : AnimationPlaybackMode,
) -> (Double, Bool) {
  if duration <= 0.0 {
    (0.0, true)
  } else {
    match mode {
      Clamp =>
        if time < 0.0 {
          (0.0, true)
        } else if time > duration {
          (duration, true)
        } else {
          (time, false)
        }
      Repeat => {
        let cycle = time % duration
        let normalized = if cycle < 0.0 { cycle + duration } else { cycle }
        (normalized, time < 0.0 || time > duration)
      }
      Mirror => {
        let period = duration * 2.0
        let cycle = time % period
        let normalized = if cycle < 0.0 { cycle + period } else { cycle }
        if normalized <= duration {
          (normalized, time < 0.0 || time > duration)
        } else {
          (period - normalized, time < 0.0 || time > duration)
        }
      }
    }
  }
}

///|
pub fn animation_path_name(path : AnimationPath) -> String {
  match path {
    Translation => "translation"
    Rotation => "rotation"
    Scale => "scale"
    Weights => "weights"
  }
}

///|
pub fn interpolation_name(interpolation : Interpolation) -> String {
  match interpolation {
    Linear => "LINEAR"
    Step => "STEP"
    CubicSpline => "CUBICSPLINE"
  }
}

///|
pub fn animation_value_width(path : AnimationPath) -> Int {
  match path {
    Translation | Scale => 3
    Rotation => 4
    Weights => 1
  }
}

///|
fn empty_track(
  animation_index : Int,
  channel_index : Int,
  sampler_index : Int,
  node : Int?,
  path : AnimationPath,
  input_accessor : Int,
  output_accessor : Int,
  status : AnimationTrackStatus,
  error : String,
) -> AnimationTrack {
  {
    animation_index,
    channel_index,
    sampler_index,
    node,
    path,
    interpolation: Linear,
    input_accessor,
    output_accessor,
    times: [],
    values: [],
    component_count: animation_value_width(path),
    status,
    errors: [error],
  }
}

///|
pub fn animation_track(
  doc : GltfDocument,
  asset : BinaryAsset,
  animation_index : Int,
  channel_index : Int,
) -> AnimationTrack {
  match doc.animations.get(animation_index) {
    None =>
      empty_track(
        animation_index,
        channel_index,
        -1,
        None,
        Translation,
        -1,
        -1,
        InvalidReference,
        "animation index is outside the document",
      )
    Some(animation) =>
      match animation.channels.get(channel_index) {
        None =>
          empty_track(
            animation_index,
            channel_index,
            -1,
            None,
            Translation,
            -1,
            -1,
            InvalidReference,
            "channel index is outside the animation",
          )
        Some(channel) =>
          match animation.samplers.get(channel.sampler) {
            None =>
              empty_track(
                animation_index,
                channel_index,
                channel.sampler,
                channel.target.node,
                channel.target.path,
                -1,
                -1,
                InvalidReference,
                "sampler index is outside the animation",
              )
            Some(sampler) => {
              let times = decode_accessor_scalars(doc, asset, sampler.input)
              let decoded = decode_accessor(doc, asset, sampler.output)
              let expected = animation_value_width(channel.target.path)
              let mut status = Valid
              let errors : Array[String] = []
              if times.length() == 0 {
                status = Empty
                errors.push("animation input accessor is empty")
              }
              if !decoded.valid {
                status = DecodeFailed
                for error in decoded.errors {
                  errors.push(error)
                }
              }
              if decoded.component_count != expected &&
                channel.target.path != Weights {
                status = UnsupportedShape
                errors.push(
                  "animation output component count does not match the target path",
                )
              }
              if times.length() != decoded.count &&
                channel.target.path != Weights {
                status = UnsupportedShape
                errors.push("input and output key counts do not match")
              }
              if !animation_times_are_monotonic(times) {
                status = InvalidTimes
                errors.push("animation input times are not monotonic")
              }
              {
                animation_index,
                channel_index,
                sampler_index: channel.sampler,
                node: channel.target.node,
                path: channel.target.path,
                interpolation: sampler.interpolation,
                input_accessor: sampler.input,
                output_accessor: sampler.output,
                times,
                values: decoded.values,
                component_count: decoded.component_count,
                status,
                errors,
              }
            }
          }
      }
  }
}

///|
pub fn animation_tracks(
  doc : GltfDocument,
  asset : BinaryAsset,
  animation_index : Int,
) -> Array[AnimationTrack] {
  match doc.animations.get(animation_index) {
    None => []
    Some(animation) => {
      let tracks : Array[AnimationTrack] = []
      for channel in 0..<animation.channels.length() {
        tracks.push(animation_track(doc, asset, animation_index, channel))
      }
      tracks
    }
  }
}

///|
pub fn all_animation_tracks(
  doc : GltfDocument,
  asset : BinaryAsset,
) -> Array[AnimationTrack] {
  let tracks : Array[AnimationTrack] = []
  for animation in 0..<doc.animations.length() {
    for track in animation_tracks(doc, asset, animation) {
      tracks.push(track)
    }
  }
  tracks
}

///|
pub fn animation_times_are_monotonic(times : Array[Double]) -> Bool {
  let mut result = true
  let mut previous : Double? = None
  for value in times {
    match previous {
      Some(old) => if value < old { result = false }
      None => ()
    }
    previous = Some(value)
  }
  result
}

///|
pub fn animation_times_are_strict(times : Array[Double]) -> Bool {
  let mut result = true
  let mut previous : Double? = None
  for value in times {
    match previous {
      Some(old) => if value <= old { result = false }
      None => ()
    }
    previous = Some(value)
  }
  result
}

///|
pub fn animation_time_start(times : Array[Double]) -> Double {
  match times.get(0) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn animation_time_end(times : Array[Double]) -> Double {
  match times.get(times.length() - 1) {
    Some(value) => value
    None => 0.0
  }
}

///|
pub fn animation_duration_from_times(times : Array[Double]) -> Double {
  let start = animation_time_start(times)
  let end = animation_time_end(times)
  if end > start {
    end - start
  } else {
    0.0
  }
}

///|
pub fn animation_track_duration(track : AnimationTrack) -> Double {
  animation_duration_from_times(track.times)
}

///|
pub fn animation_track_key_count(track : AnimationTrack) -> Int {
  track.times.length()
}

///|
pub fn animation_track_is_valid(track : AnimationTrack) -> Bool {
  track.status == Valid && track.times.length() > 0
}

///|
pub fn animation_track_is_rotation(track : AnimationTrack) -> Bool {
  track.path == Rotation
}

///|
pub fn animation_track_is_transform(track : AnimationTrack) -> Bool {
  track.path == Translation || track.path == Rotation || track.path == Scale
}

///|
pub fn animation_track_value(
  track : AnimationTrack,
  key : Int,
) -> Array[Double] {
  if key < 0 || key >= track.times.length() || track.component_count <= 0 {
    []
  } else {
    let start = key * track.component_count
    let result : Array[Double] = []
    for component in 0..<track.component_count {
      match track.values.get(start + component) {
        Some(value) => result.push(value)
        None => ()
      }
    }
    result
  }
}

///|
pub fn animation_track_find_interval(
  track : AnimationTrack,
  time : Double,
) -> (Int, Int, Double) {
  if track.times.length() == 0 {
    (0, 0, 0.0)
  } else if time <= track.times[0] {
    (0, 0, 0.0)
  } else if time >= track.times[track.times.length() - 1] {
    let last = track.times.length() - 1
    (last, last, 0.0)
  } else {
    let mut left = 0
    let mut right = track.times.length() - 1
    while left + 1 < right {
      let middle = (left + right) / 2
      if track.times[middle] <= time {
        left = middle
      } else {
        right = middle
      }
    }
    let span = track.times[right] - track.times[left]
    let factor = if span <= 0.0 {
      0.0
    } else {
      (time - track.times[left]) / span
    }
    (left, right, factor)
  }
}

///|
pub fn interpolate_scalar(
  left : Double,
  right : Double,
  factor : Double,
) -> Double {
  left + (right - left) * factor
}

///|
pub fn interpolate_array(
  left : Array[Double],
  right : Array[Double],
  factor : Double,
) -> Array[Double] {
  let count = if left.length() < right.length() {
    left.length()
  } else {
    right.length()
  }
  let result : Array[Double] = []
  for index in 0..<count {
    result.push(interpolate_scalar(left[index], right[index], factor))
  }
  result
}

///|
pub fn interpolate_step(track : AnimationTrack, left : Int) -> Array[Double] {
  animation_track_value(track, left)
}

///|
pub fn interpolate_linear(
  track : AnimationTrack,
  left : Int,
  right : Int,
  factor : Double,
) -> Array[Double] {
  if left == right {
    animation_track_value(track, left)
  } else {
    interpolate_array(
      animation_track_value(track, left),
      animation_track_value(track, right),
      factor,
    )
  }
}

///|
pub fn cubic_hermite(
  p0 : Double,
  m0 : Double,
  p1 : Double,
  m1 : Double,
  factor : Double,
  duration : Double,
) -> Double {
  let t = factor
  let t2 = t * t
  let t3 = t2 * t
  let h00 = 2.0 * t3 - 3.0 * t2 + 1.0
  let h10 = t3 - 2.0 * t2 + t
  let h01 = -2.0 * t3 + 3.0 * t2
  let h11 = t3 - t2
  h00 * p0 + h10 * m0 * duration + h01 * p1 + h11 * m1 * duration
}

///|
pub fn interpolate_cubic(
  track : AnimationTrack,
  left : Int,
  right : Int,
  factor : Double,
) -> Array[Double] {
  if track.component_count <= 0 ||
    track.values.length() < track.times.length() * track.component_count * 3 {
    interpolate_linear(track, left, right, factor)
  } else {
    let width = track.component_count
    let left_base = left * width * 3
    let right_base = right * width * 3
    let duration = if right == left {
      0.0
    } else {
      track.times[right] - track.times[left]
    }
    let result : Array[Double] = []
    for component in 0..<width {
      let p0 = track.values[left_base + width + component]
      let m0 = track.values[left_base + width * 2 + component]
      let p1 = track.values[right_base + width + component]
      let m1 = track.values[right_base + component]
      result.push(cubic_hermite(p0, m0, p1, m1, factor, duration))
    }
    result
  }
}

///|
pub fn sample_animation_track_at(
  track : AnimationTrack,
  time : Double,
  mode : AnimationPlaybackMode,
) -> AnimationSample {
  let duration = animation_track_duration(track)
  let (sample_time, clamped) = animation_playback_time(time, duration, mode)
  if !animation_track_is_valid(track) {
    {
      time: sample_time,
      track_index: track.channel_index,
      node: track.node,
      path: track.path,
      values: [],
      normalized_time: 0.0,
      clamped,
      valid: false,
    }
  } else {
    let (left, right, factor) = animation_track_find_interval(
      track, sample_time,
    )
    let values = match track.interpolation {
      Step => interpolate_step(track, left)
      Linear => interpolate_linear(track, left, right, factor)
      CubicSpline => interpolate_cubic(track, left, right, factor)
    }
    let normalized_time = if duration <= 0.0 {
      0.0
    } else {
      (sample_time - animation_time_start(track.times)) / duration
    }
    {
      time: sample_time,
      track_index: track.channel_index,
      node: track.node,
      path: track.path,
      values,
      normalized_time,
      clamped,
      valid: true,
    }
  }
}

///|
pub fn sample_animation_track(
  doc : GltfDocument,
  asset : BinaryAsset,
  animation_index : Int,
  channel_index : Int,
  time : Double,
) -> AnimationSample {
  let track = animation_track(doc, asset, animation_index, channel_index)
  sample_animation_track_at(track, time, Clamp)
}

///|
fn values_to_vec3(values : Array[Double]) -> Vec3? {
  if values.length() < 3 {
    None
  } else {
    Some({ x: values[0], y: values[1], z: values[2] })
  }
}

///|
fn values_to_quat(values : Array[Double]) -> Quat? {
  if values.length() < 4 {
    None
  } else {
    Some({ x: values[0], y: values[1], z: values[2], w: values[3] })
  }
}

///|
pub fn normalize_quaternion(value : Quat) -> Quat {
  let length = Double::sqrt(
    value.x * value.x +
    value.y * value.y +
    value.z * value.z +
    value.w * value.w,
  )
  if length <= 0.0 {
    { x: 0.0, y: 0.0, z: 0.0, w: 1.0 }
  } else {
    {
      x: value.x / length,
      y: value.y / length,
      z: value.z / length,
      w: value.w / length,
    }
  }
}

///|
pub fn quaternion_dot(a : Quat, b : Quat) -> Double {
  a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
}

///|
pub fn quaternion_lerp(a : Quat, b : Quat, factor : Double) -> Quat {
  normalize_quaternion({
    x: interpolate_scalar(a.x, b.x, factor),
    y: interpolate_scalar(a.y, b.y, factor),
    z: interpolate_scalar(a.z, b.z, factor),
    w: interpolate_scalar(a.w, b.w, factor),
  })
}

///|
pub fn animation_pose(
  doc : GltfDocument,
  asset : BinaryAsset,
  animation_index : Int,
  time : Double,
  mode : AnimationPlaybackMode,
) -> AnimationPose {
  let tracks = animation_tracks(doc, asset, animation_index)
  let values : Map[Int, AnimationPoseValue] = Map([])
  let errors : Array[String] = []
  let duration = tracks.fold(init=0.0, (maximum, track) => {
    let value = animation_track_duration(track)
    if value > maximum {
      value
    } else {
      maximum
    }
  })
  let mut valid = true
  for track in tracks {
    let sample = sample_animation_track_at(track, time, mode)
    match sample.node {
      None => {
        valid = false
        errors.push("animation track has no target node")
      }
      Some(node) => {
        let old = match values.get(node) {
          Some(value) => value
          None =>
            {
              node,
              translation: None,
              rotation: None,
              scale: None,
              weights: [],
            }
        }
        let next = match track.path {
          Translation => { ..old, translation: values_to_vec3(sample.values) }
          Rotation => { ..old, rotation: values_to_quat(sample.values) }
          Scale => { ..old, scale: values_to_vec3(sample.values) }
          Weights => { ..old, weights: sample.values }
        }
        values[node] = next
      }
    }
    if !sample.valid {
      valid = false
    }
  }
  let pose_values : Array[AnimationPoseValue] = []
  for _, value in values {
    pose_values.push(value)
  }
  { animation_index, time, duration, values: pose_values, valid, errors }
}

///|
pub fn animation_clip_report(
  doc : GltfDocument,
  asset : BinaryAsset,
  animation_index : Int,
) -> AnimationClipReport {
  let tracks = animation_tracks(doc, asset, animation_index)
  let mut start = 0.0
  let mut end = 0.0
  let mut first = true
  let mut invalid = 0
  let targets : Map[Int, Bool] = Map([])
  let paths : Map[String, Bool] = Map([])
  for track in tracks {
    if !animation_track_is_valid(track) {
      invalid += 1
    }
    if track.times.length() > 0 {
      let one_start = animation_time_start(track.times)
      let one_end = animation_time_end(track.times)
      if first || one_start < start {
        start = one_start
      }
      if first || one_end > end {
        end = one_end
      }
      first = false
    }
    match track.node {
      Some(node) => targets[node] = true
      None => ()
    }
    paths[animation_path_name(track.path)] = true
  }
  let name = match doc.animations.get(animation_index) {
    Some(animation) => animation.name
    None => None
  }
  {
    animation_index,
    name,
    channel_count: match doc.animations.get(animation_index) {
      Some(animation) => animation.channels.length()
      None => 0
    },
    sampler_count: match doc.animations.get(animation_index) {
      Some(animation) => animation.samplers.length()
      None => 0
    },
    track_count: tracks.length(),
    duration: if end > start {
      end - start
    } else {
      0.0
    },
    start_time: start,
    end_time: end,
    loopable: tracks.length() > 0 && invalid == 0,
    invalid_track_count: invalid,
    target_node_count: targets.length(),
    animated_path_count: paths.length(),
    tracks,
  }
}

///|
pub fn all_animation_clip_reports(
  doc : GltfDocument,
  asset : BinaryAsset,
) -> Array[AnimationClipReport] {
  let reports : Array[AnimationClipReport] = []
  for index in 0..<doc.animations.length() {
    reports.push(animation_clip_report(doc, asset, index))
  }
  reports
}

///|
pub fn total_animation_keyframes(reports : Array[AnimationClipReport]) -> Int {
  reports.fold(init=0, (sum, report) => {
    report.tracks.fold(init=sum, (inner, track) => inner + track.times.length())
  })
}

///|
pub fn longest_animation_clip(reports : Array[AnimationClipReport]) -> Int? {
  let mut best : Int? = None
  let mut duration = -1.0
  for report in reports {
    if report.duration > duration {
      duration = report.duration
      best = Some(report.animation_index)
    }
  }
  best
}

///|
pub fn animation_budget_result(
  doc : GltfDocument,
  reports : Array[AnimationClipReport],
  budget : AnimationBudget,
) -> AnimationBudgetResult {
  let clip_overage = if reports.length() > budget.max_clips {
    reports.length() - budget.max_clips
  } else {
    0
  }
  let channels = reports.fold(init=0, (sum, report) => {
    sum + report.channel_count
  })
  let channel_overage = if channels > budget.max_channels {
    channels - budget.max_channels
  } else {
    0
  }
  let duration = reports.fold(init=0.0, (maximum, report) => {
    if report.duration > maximum {
      report.duration
    } else {
      maximum
    }
  })
  let duration_overage = if duration > budget.max_duration {
    duration - budget.max_duration
  } else {
    0.0
  }
  let keyframes = total_animation_keyframes(reports)
  let keyframe_overage = if keyframes > budget.max_keyframes {
    keyframes - budget.max_keyframes
  } else {
    0
  }
  let violations : Array[String] = []
  if clip_overage > 0 {
    violations.push("animation clip budget exceeded by \{clip_overage}")
  }
  if channel_overage > 0 {
    violations.push("animation channel budget exceeded by \{channel_overage}")
  }
  if duration_overage > 0.0 {
    violations.push("animation duration exceeds the configured budget")
  }
  if keyframe_overage > 0 {
    violations.push("animation keyframe budget exceeded by \{keyframe_overage}")
  }
  if budget.require_monotonic_times {
    for track in all_animation_tracks(doc, binary_asset_empty()) {
      if !animation_times_are_monotonic(track.times) {
        violations.push("animation input times are not monotonic")
      }
    }
  }
  {
    passed: violations.length() == 0,
    violations,
    clip_overage,
    channel_overage,
    duration_overage,
    keyframe_overage,
  }
}

///|
pub fn animation_report_summary_lines(
  reports : Array[AnimationClipReport],
) -> Array[String] {
  [
    "clips=\{reports.length()}, keyframes=\{total_animation_keyframes(reports)}",
    "longest=\{Repr(longest_animation_clip(reports))}",
    "durations=\{reports.map(report => "\{report.duration}").join(",")}",
  ]
}
