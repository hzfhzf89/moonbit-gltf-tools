///|
pub(all) struct MaterialSample {
  base_color : Color4
  metallic : Double
  roughness : Double
  emissive : Vec3
  alpha : Double
  normal_scale : Double
  occlusion_strength : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct MaterialSampleStats {
  count : Int
  average_color : Color4
  average_metallic : Double
  average_roughness : Double
  transparent_count : Int
  metallic_count : Int
  emissive_count : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct MaterialFeatureKey {
  has_base_texture : Bool
  has_normal_texture : Bool
  has_emissive_texture : Bool
  has_occlusion_texture : Bool
  alpha_mode : String
  double_sided : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn material_sample(
  base_color : Color4,
  metallic : Double,
  roughness : Double,
  emissive : Vec3,
  alpha : Double,
) -> MaterialSample {
  {
    base_color,
    metallic,
    roughness,
    emissive,
    alpha,
    normal_scale: 1.0,
    occlusion_strength: 1.0,
  }
}

///|
pub fn material_clamp(
  value : Double,
  minimum : Double,
  maximum : Double,
) -> Double {
  if value < minimum {
    minimum
  } else if value > maximum {
    maximum
  } else {
    value
  }
}

///|
pub fn material_clamp_color(value : Color4) -> Color4 {
  {
    r: material_clamp(value.r, 0.0, 1.0),
    g: material_clamp(value.g, 0.0, 1.0),
    b: material_clamp(value.b, 0.0, 1.0),
    a: material_clamp(value.a, 0.0, 1.0),
  }
}

///|
pub fn material_sample_normalize(sample : MaterialSample) -> MaterialSample {
  {
    base_color: material_clamp_color(sample.base_color),
    metallic: material_clamp(sample.metallic, 0.0, 1.0),
    roughness: material_clamp(sample.roughness, 0.0, 1.0),
    emissive: sample.emissive,
    alpha: material_clamp(sample.alpha, 0.0, 1.0),
    normal_scale: material_clamp(sample.normal_scale, 0.0, 8.0),
    occlusion_strength: material_clamp(sample.occlusion_strength, 0.0, 1.0),
  }
}

///|
pub fn material_sample_lerp(
  left : MaterialSample,
  right : MaterialSample,
  factor : Double,
) -> MaterialSample {
  let t = material_clamp(factor, 0.0, 1.0)
  material_sample(
    {
      r: left.base_color.r + (right.base_color.r - left.base_color.r) * t,
      g: left.base_color.g + (right.base_color.g - left.base_color.g) * t,
      b: left.base_color.b + (right.base_color.b - left.base_color.b) * t,
      a: left.base_color.a + (right.base_color.a - left.base_color.a) * t,
    },
    left.metallic + (right.metallic - left.metallic) * t,
    left.roughness + (right.roughness - left.roughness) * t,
    {
      x: left.emissive.x + (right.emissive.x - left.emissive.x) * t,
      y: left.emissive.y + (right.emissive.y - left.emissive.y) * t,
      z: left.emissive.z + (right.emissive.z - left.emissive.z) * t,
    },
    left.alpha + (right.alpha - left.alpha) * t,
  )
}

///|
pub fn material_sample_energy(sample : MaterialSample) -> Double {
  let color = (sample.base_color.r + sample.base_color.g + sample.base_color.b) /
    3.0
  color *
  (1.0 - sample.metallic * 0.5) *
  (1.0 - sample.roughness * 0.25) *
  sample.alpha
}

///|
pub fn material_sample_is_transparent(
  sample : MaterialSample,
  threshold : Double,
) -> Bool {
  sample.alpha < threshold
}

///|
pub fn material_sample_is_metallic(
  sample : MaterialSample,
  threshold : Double,
) -> Bool {
  sample.metallic >= threshold
}

///|
pub fn material_sample_is_emissive(
  sample : MaterialSample,
  threshold : Double,
) -> Bool {
  topology_length_squared(sample.emissive) >= threshold * threshold
}

///|
pub fn material_sample_stats(
  samples : Array[MaterialSample],
) -> MaterialSampleStats {
  let count = samples.length()
  let mut color = { r: 0.0, g: 0.0, b: 0.0, a: 0.0 }
  let mut metallic = 0.0
  let mut roughness = 0.0
  let mut transparent = 0
  let mut metallic_count = 0
  let mut emissive = 0
  for sample in samples {
    color = {
      r: color.r + sample.base_color.r,
      g: color.g + sample.base_color.g,
      b: color.b + sample.base_color.b,
      a: color.a + sample.base_color.a,
    }
    metallic = metallic + sample.metallic
    roughness = roughness + sample.roughness
    if material_sample_is_transparent(sample, 0.999) {
      transparent = transparent + 1
    }
    if material_sample_is_metallic(sample, 0.5) {
      metallic_count = metallic_count + 1
    }
    if material_sample_is_emissive(sample, 0.001) {
      emissive = emissive + 1
    }
  }
  let divisor = if count == 0 { 1.0 } else { Double::from_int(count) }
  {
    count,
    average_color: {
      r: color.r / divisor,
      g: color.g / divisor,
      b: color.b / divisor,
      a: color.a / divisor,
    },
    average_metallic: metallic / divisor,
    average_roughness: roughness / divisor,
    transparent_count: transparent,
    metallic_count,
    emissive_count: emissive,
    valid: samples.all(fn(sample) {
      material_sample_normalize(sample) == sample
    }),
  }
}

///|
pub fn material_feature_key(material : GltfMaterial) -> MaterialFeatureKey {
  {
    has_base_texture: material.pbr_metallic_roughness.base_color_texture
    is Some(_),
    has_normal_texture: material.normal_texture is Some(_),
    has_emissive_texture: material.emissive_texture is Some(_),
    has_occlusion_texture: material.occlusion_texture is Some(_),
    alpha_mode: alpha_mode_name(material.alpha_mode),
    double_sided: material.double_sided,
  }
}

///|
pub fn material_feature_key_string(key : MaterialFeatureKey) -> String {
  "base=\{key.has_base_texture};normal=\{key.has_normal_texture};emissive=\{key.has_emissive_texture};occlusion=\{key.has_occlusion_texture};alpha=\{key.alpha_mode};double=\{key.double_sided}"
}

///|
pub fn material_feature_key_equal(
  left : MaterialFeatureKey,
  right : MaterialFeatureKey,
) -> Bool {
  left.has_base_texture == right.has_base_texture &&
  left.has_normal_texture == right.has_normal_texture &&
  left.has_emissive_texture == right.has_emissive_texture &&
  left.has_occlusion_texture == right.has_occlusion_texture &&
  left.alpha_mode == right.alpha_mode &&
  left.double_sided == right.double_sided
}

///|
pub fn material_group_features(
  materials : Array[GltfMaterial],
) -> Map[String, Int] {
  let groups : Map[String, Int] = Map([])
  for material in materials {
    let key = material_feature_key_string(material_feature_key(material))
    groups[key] = match groups.get(key) {
      Some(value) => value + 1
      None => 1
    }
  }
  groups
}

///|
pub fn material_sample_lines(stats : MaterialSampleStats) -> Array[String] {
  [
    "samples=\{stats.count}",
    "average_metallic=\{stats.average_metallic}",
    "average_roughness=\{stats.average_roughness}",
    "transparent=\{stats.transparent_count}",
    "metallic=\{stats.metallic_count}",
    "emissive=\{stats.emissive_count}",
    "valid=\{stats.valid}",
  ]
}
