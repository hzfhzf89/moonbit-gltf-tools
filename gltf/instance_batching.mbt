///|
/// Runtime instance transforms and draw-batch planning.
pub(all) struct InstanceTransform {
  translation : Vec3
  rotation : Quat
  scale : Vec3
} derive(Debug, ToJson, Eq)

///|
pub(all) struct InstanceRecord {
  id : Int
  mesh : Int
  material : Int
  transform : InstanceTransform
  bounds : SpatialAabb
  layer : Int
  visible : Bool
  lod_bias : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct InstanceBatchKey {
  mesh : Int
  material : Int
  lod : Int
  layer : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct InstanceBatch {
  key : InstanceBatchKey
  instance_ids : Array[Int]
  bounds : SpatialAabb
  visible_count : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct DrawCommand {
  mesh : Int
  material : Int
  lod : Int
  first_instance : Int
  instance_count : Int
  bounds : SpatialAabb
} derive(Debug, ToJson, Eq)

///|
pub(all) struct InstancePlan {
  instances : Array[InstanceRecord]
  batches : Array[InstanceBatch]
  commands : Array[DrawCommand]
  visible_instances : Int
  culled_instances : Int
  batch_count : Int
  draw_count : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct InstancePolicy {
  max_instances : Int
  max_batches : Int
  max_draws : Int
  max_lod : Int
  allow_negative_scale : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct InstanceBudgetResult {
  passed : Bool
  violations : Array[String]
  plan : InstancePlan
} derive(Debug, ToJson, Eq)

///|
pub fn instance_transform_identity() -> InstanceTransform {
  {
    translation: { x: 0.0, y: 0.0, z: 0.0 },
    rotation: { x: 0.0, y: 0.0, z: 0.0, w: 1.0 },
    scale: { x: 1.0, y: 1.0, z: 1.0 },
  }
}

///|
pub fn instance_transform(
  translation : Vec3,
  rotation : Quat,
  scale : Vec3,
) -> InstanceTransform {
  { translation, rotation: instance_quaternion_normalize(rotation), scale }
}

///|
pub fn instance_quaternion_normalize(value : Quat) -> Quat {
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
pub fn instance_quaternion_multiply(a : Quat, b : Quat) -> Quat {
  instance_quaternion_normalize({
    x: a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
    y: a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
    z: a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
    w: a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
  })
}

///|
pub fn instance_quaternion_rotate(rotation : Quat, vector : Vec3) -> Vec3 {
  let pure = Quat::{ x: vector.x, y: vector.y, z: vector.z, w: 0.0 }
  let inverse : Quat = {
    x: -rotation.x,
    y: -rotation.y,
    z: -rotation.z,
    w: rotation.w,
  }
  let result = instance_quaternion_multiply(
    instance_quaternion_multiply(rotation, pure),
    inverse,
  )
  { x: result.x, y: result.y, z: result.z }
}

///|
pub fn instance_transform_point(
  transform : InstanceTransform,
  point : Vec3,
) -> Vec3 {
  let scaled = {
    x: point.x * transform.scale.x,
    y: point.y * transform.scale.y,
    z: point.z * transform.scale.z,
  }
  topology_add(
    instance_quaternion_rotate(transform.rotation, scaled),
    transform.translation,
  )
}

///|
pub fn instance_transform_bounds(
  transform : InstanceTransform,
  bounds : SpatialAabb,
) -> SpatialAabb {
  let corners = [
    { x: bounds.minimum.x, y: bounds.minimum.y, z: bounds.minimum.z },
    { x: bounds.minimum.x, y: bounds.minimum.y, z: bounds.maximum.z },
    { x: bounds.minimum.x, y: bounds.maximum.y, z: bounds.minimum.z },
    { x: bounds.minimum.x, y: bounds.maximum.y, z: bounds.maximum.z },
    { x: bounds.maximum.x, y: bounds.minimum.y, z: bounds.minimum.z },
    { x: bounds.maximum.x, y: bounds.minimum.y, z: bounds.maximum.z },
    { x: bounds.maximum.x, y: bounds.maximum.y, z: bounds.minimum.z },
    { x: bounds.maximum.x, y: bounds.maximum.y, z: bounds.maximum.z },
  ]
  spatial_aabb_from_points(
    corners.map(fn(point) { instance_transform_point(transform, point) }),
  )
}

///|
pub fn instance_transform_combine(
  parent : InstanceTransform,
  child : InstanceTransform,
) -> InstanceTransform {
  let translation = instance_transform_point(parent, child.translation)
  let rotation = instance_quaternion_multiply(parent.rotation, child.rotation)
  let scale = {
    x: parent.scale.x * child.scale.x,
    y: parent.scale.y * child.scale.y,
    z: parent.scale.z * child.scale.z,
  }
  { translation, rotation, scale }
}

///|
pub fn instance_transform_lerp(
  left : InstanceTransform,
  right : InstanceTransform,
  factor : Double,
) -> InstanceTransform {
  let t = if factor < 0.0 { 0.0 } else if factor > 1.0 { 1.0 } else { factor }
  let rotation = instance_quaternion_normalize({
    x: left.rotation.x + (right.rotation.x - left.rotation.x) * t,
    y: left.rotation.y + (right.rotation.y - left.rotation.y) * t,
    z: left.rotation.z + (right.rotation.z - left.rotation.z) * t,
    w: left.rotation.w + (right.rotation.w - left.rotation.w) * t,
  })
  {
    translation: {
      x: left.translation.x + (right.translation.x - left.translation.x) * t,
      y: left.translation.y + (right.translation.y - left.translation.y) * t,
      z: left.translation.z + (right.translation.z - left.translation.z) * t,
    },
    rotation,
    scale: {
      x: left.scale.x + (right.scale.x - left.scale.x) * t,
      y: left.scale.y + (right.scale.y - left.scale.y) * t,
      z: left.scale.z + (right.scale.z - left.scale.z) * t,
    },
  }
}

///|
pub fn instance_record(
  id : Int,
  mesh : Int,
  material : Int,
  transform : InstanceTransform,
  local_bounds : SpatialAabb,
  layer : Int,
) -> InstanceRecord {
  {
    id,
    mesh,
    material,
    transform,
    bounds: instance_transform_bounds(transform, local_bounds),
    layer,
    visible: true,
    lod_bias: 0.0,
  }
}

///|
pub fn instance_set_visible(
  instance : InstanceRecord,
  visible : Bool,
) -> InstanceRecord {
  { ..instance, visible, }
}

///|
pub fn instance_set_lod_bias(
  instance : InstanceRecord,
  lod_bias : Double,
) -> InstanceRecord {
  { ..instance, lod_bias, }
}

///|
pub fn instance_key(instance : InstanceRecord, lod : Int) -> InstanceBatchKey {
  {
    mesh: instance.mesh,
    material: instance.material,
    lod,
    layer: instance.layer,
  }
}

///|
pub fn instance_key_equal(
  left : InstanceBatchKey,
  right : InstanceBatchKey,
) -> Bool {
  left.mesh == right.mesh &&
  left.material == right.material &&
  left.lod == right.lod &&
  left.layer == right.layer
}

///|
pub fn instance_lod_for_distance(
  distance : Double,
  thresholds : Array[Double],
  bias : Double,
) -> Int {
  let adjusted = distance + bias
  let mut lod = 0
  for threshold in thresholds {
    if adjusted >= threshold {
      lod = lod + 1
    }
  }
  lod
}

///|
pub fn instance_lod_for_screen_size(
  radius : Double,
  distance : Double,
  thresholds : Array[Double],
) -> Int {
  if distance <= 0.0 {
    return 0
  }
  instance_lod_for_distance(radius / distance, thresholds, 0.0)
}

///|
pub fn instance_batch_bounds(
  instances : Array[InstanceRecord],
  ids : Array[Int],
) -> SpatialAabb {
  match ids.get(0) {
    None => spatial_aabb_empty()
    Some(first_id) => {
      let mut result = spatial_aabb_empty()
      for instance in instances {
        if instance.id == first_id {
          result = instance.bounds
          break
        }
      }
      for id in ids {
        for instance in instances {
          if instance.id == id {
            result = spatial_aabb_union(result, instance.bounds)
            break
          }
        }
      }
      result
    }
  }
}

///|
pub fn instance_build_batches(
  instances : Array[InstanceRecord],
  lods : Array[Int],
) -> Array[InstanceBatch] {
  let batches : Array[InstanceBatch] = []
  for index, instance in instances {
    let lod = match lods.get(index) {
      Some(value) => value
      None => 0
    }
    if !instance.visible {
      continue
    }
    let key = instance_key(instance, lod)
    let mut found : Int? = None
    for batch_index, batch in batches {
      if instance_key_equal(batch.key, key) {
        found = Some(batch_index)
        break
      }
    }
    match found {
      None =>
        batches.push({
          key,
          instance_ids: [instance.id],
          bounds: instance.bounds,
          visible_count: 1,
        })
      Some(batch_index) =>
        match batches.get(batch_index) {
          None => ()
          Some(batch) => {
            let ids = batch.instance_ids.copy()
            ids.push(instance.id)
            batches[batch_index] = {
              ..batch,
              instance_ids: ids,
              bounds: spatial_aabb_union(batch.bounds, instance.bounds),
              visible_count: batch.visible_count + 1,
            }
          }
        }
    }
  }
  batches
}

///|
pub fn instance_build_commands(
  batches : Array[InstanceBatch],
) -> Array[DrawCommand] {
  let commands : Array[DrawCommand] = []
  let mut first_instance = 0
  for batch in batches {
    commands.push({
      mesh: batch.key.mesh,
      material: batch.key.material,
      lod: batch.key.lod,
      first_instance,
      instance_count: batch.instance_ids.length(),
      bounds: batch.bounds,
    })
    first_instance = first_instance + batch.instance_ids.length()
  }
  commands
}

///|
pub fn default_instance_policy() -> InstancePolicy {
  {
    max_instances: 1000000,
    max_batches: 100000,
    max_draws: 100000,
    max_lod: 8,
    allow_negative_scale: true,
  }
}

///|
pub fn instance_plan(
  instances : Array[InstanceRecord],
  lods : Array[Int],
) -> InstancePlan {
  let batches = instance_build_batches(instances, lods)
  let commands = instance_build_commands(batches)
  let visible = instances.filter(fn(instance) { instance.visible }).length()
  {
    instances,
    batches,
    commands,
    visible_instances: visible,
    culled_instances: instances.length() - visible,
    batch_count: batches.length(),
    draw_count: commands.length(),
  }
}

///|
pub fn instance_plan_cull(
  instances : Array[InstanceRecord],
  frustum : SpatialFrustum,
  layer_mask : Int,
  thresholds : Array[Double],
  camera : Vec3,
) -> InstancePlan {
  let prepared : Array[InstanceRecord] = []
  let lods : Array[Int] = []
  for instance in instances {
    let visible = instance.visible &&
      (instance.layer & layer_mask) != 0 &&
      spatial_frustum_intersects_bounds(frustum, instance.bounds)
    let distance = Double::sqrt(
      spatial_distance_squared(spatial_aabb_center(instance.bounds), camera),
    )
    let lod = instance_lod_for_distance(distance, thresholds, instance.lod_bias)
    prepared.push({ ..instance, visible, })
    lods.push(lod)
  }
  instance_plan(prepared, lods)
}

///|
pub fn instance_validate_plan(
  plan : InstancePlan,
  policy : InstancePolicy,
) -> InstanceBudgetResult {
  let violations : Array[String] = []
  if plan.instances.length() > policy.max_instances {
    violations.push("instance count exceeds policy")
  }
  if plan.batch_count > policy.max_batches {
    violations.push("batch count exceeds policy")
  }
  if plan.draw_count > policy.max_draws {
    violations.push("draw count exceeds policy")
  }
  for instance in plan.instances {
    if !policy.allow_negative_scale &&
      (
        instance.transform.scale.x < 0.0 ||
        instance.transform.scale.y < 0.0 ||
        instance.transform.scale.z < 0.0
      ) {
      violations.push("negative scale is not allowed")
      break
    }
  }
  { passed: violations.length() == 0, violations, plan }
}

///|
pub fn instance_batch_reduction(plan : InstancePlan) -> Double {
  if plan.visible_instances == 0 {
    return 0.0
  }
  1.0 -
  Double::from_int(plan.draw_count) / Double::from_int(plan.visible_instances)
}

///|
pub fn instance_plan_lines(plan : InstancePlan) -> Array[String] {
  [
    "instances=\{plan.instances.length()}",
    "visible_instances=\{plan.visible_instances}",
    "culled_instances=\{plan.culled_instances}",
    "batches=\{plan.batch_count}",
    "draws=\{plan.draw_count}",
    "batch_reduction=\{instance_batch_reduction(plan)}",
  ]
}
