///|
/// Material and texture policy analysis for asset build systems.
///
/// The parser exposes the core PBR structures. This module turns them into
/// operational checks: texture slot reachability, sampler compatibility,
/// alpha policy, numerical ranges, duplicate material signatures, and memory
/// budgets that can be used by an importer or CI quality gate.

///|
pub(all) enum TextureSemantic {
  BaseColor
  MetallicRoughness
  Normal
  Occlusion
  Emissive
} derive(Debug, ToJson, Eq)

///|
pub(all) struct TextureSlotReport {
  material : Int
  semantic : TextureSemantic
  texture : Int
  image : Int?
  sampler : Int?
  tex_coord : Int
  uri : String?
  embedded : Bool
  external : Bool
  valid : Bool
  issues : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct MaterialIssue {
  material : Int
  severity : DiagnosticSeverity
  code : String
  path : String
  message : String
  hint : String?
} derive(Debug, ToJson, Eq)

///|
pub(all) struct MaterialReport {
  material : Int
  name : String?
  alpha_mode : AlphaMode
  texture_slot_count : Int
  texcoord_set_count : Int
  has_normal_map : Bool
  has_emissive : Bool
  has_transparency : Bool
  double_sided : Bool
  metallic_factor : Double
  roughness_factor : Double
  base_color : Color4
  texture_slots : Array[TextureSlotReport]
  issues : Array[MaterialIssue]
  signature : String
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct TextureReport {
  texture : Int
  name : String?
  source_image : Int?
  sampler : Int?
  uri : String?
  uri_kind : UriKind?
  semantic_count : Int
  semantic_names : Array[String]
  texcoord_count : Int
  valid : Bool
  issues : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct MaterialBudget {
  max_materials : Int
  max_texture_slots : Int
  max_unique_images : Int
  max_external_images : Int
  max_texcoord_sets : Int
  allow_double_sided : Bool
  allow_blend : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct MaterialBudgetResult {
  passed : Bool
  violations : Array[String]
  material_overage : Int
  texture_slot_overage : Int
  image_overage : Int
  external_image_overage : Int
  texcoord_overage : Int
} derive(Debug, ToJson, Eq)

///|
pub fn default_material_budget() -> MaterialBudget {
  {
    max_materials: 4096,
    max_texture_slots: 20000,
    max_unique_images: 4096,
    max_external_images: 4096,
    max_texcoord_sets: 4,
    allow_double_sided: true,
    allow_blend: true,
  }
}

///|
pub fn mobile_material_budget() -> MaterialBudget {
  {
    max_materials: 512,
    max_texture_slots: 4096,
    max_unique_images: 1024,
    max_external_images: 1024,
    max_texcoord_sets: 2,
    allow_double_sided: false,
    allow_blend: true,
  }
}

///|
pub fn texture_semantic_name(value : TextureSemantic) -> String {
  match value {
    BaseColor => "baseColor"
    MetallicRoughness => "metallicRoughness"
    Normal => "normal"
    Occlusion => "occlusion"
    Emissive => "emissive"
  }
}

///|
pub fn alpha_mode_name(value : AlphaMode) -> String {
  match value {
    Opaque => "OPAQUE"
    Mask => "MASK"
    Blend => "BLEND"
  }
}

///|
pub fn material_name(doc : GltfDocument, material : Int) -> String {
  match doc.materials.get(material) {
    Some(value) =>
      match value.name {
        Some(name) => name
        None => "material[\{material}]"
      }
    None => "material[\{material}]"
  }
}

///|
pub fn texture_name(doc : GltfDocument, texture : Int) -> String {
  match doc.textures.get(texture) {
    Some(value) =>
      match value.name {
        Some(name) => name
        None => "texture[\{texture}]"
      }
    None => "texture[\{texture}]"
  }
}

///|
pub fn material_texture_info(
  material : GltfMaterial,
  semantic : TextureSemantic,
) -> TextureInfo? {
  match semantic {
    BaseColor => material.pbr_metallic_roughness.base_color_texture
    MetallicRoughness =>
      material.pbr_metallic_roughness.metallic_roughness_texture
    Normal => material.normal_texture
    Occlusion => material.occlusion_texture
    Emissive => material.emissive_texture
  }
}

///|
pub fn material_texture_count_by_semantic(
  material : GltfMaterial,
  semantic : TextureSemantic,
) -> Int {
  if material_texture_info(material, semantic) is Some(_) {
    1
  } else {
    0
  }
}

///|
pub fn material_texture_semantics(
  material : GltfMaterial,
) -> Array[TextureSemantic] {
  let result : Array[TextureSemantic] = []
  for semantic in [BaseColor, MetallicRoughness, Normal, Occlusion, Emissive] {
    if material_texture_info(material, semantic) is Some(_) {
      result.push(semantic)
    }
  }
  result
}

///|
pub fn material_texcoord_sets(material : GltfMaterial) -> Array[Int] {
  let result : Array[Int] = []
  for semantic in material_texture_semantics(material) {
    match material_texture_info(material, semantic) {
      Some(info) =>
        if !result.contains(info.tex_coord) {
          result.push(info.tex_coord)
        }
      None => ()
    }
  }
  result
}

///|
pub fn material_has_texture(
  material : GltfMaterial,
  semantic : TextureSemantic,
) -> Bool {
  material_texture_info(material, semantic) is Some(_)
}

///|
pub fn material_has_normal_map(material : GltfMaterial) -> Bool {
  material_has_texture(material, Normal)
}

///|
pub fn material_has_emissive_map(material : GltfMaterial) -> Bool {
  material_has_texture(material, Emissive)
}

///|
pub fn material_is_transparent(material : GltfMaterial) -> Bool {
  material.alpha_mode == Blend ||
  (
    material.alpha_mode == Mask &&
    material.pbr_metallic_roughness.base_color_factor.a < 1.0
  )
}

///|
pub fn material_is_opaque(material : GltfMaterial) -> Bool {
  material.alpha_mode == Opaque &&
  material.pbr_metallic_roughness.base_color_factor.a >= 1.0
}

///|
pub fn material_uses_nonzero_texcoord(material : GltfMaterial) -> Bool {
  for value in material_texcoord_sets(material) {
    if value != 0 {
      return true
    }
  }
  false
}

///|
pub fn material_pbr_parameter_error_count(material : GltfMaterial) -> Int {
  let pbr = material.pbr_metallic_roughness
  let mut errors = 0
  if pbr.metallic_factor < 0.0 || pbr.metallic_factor > 1.0 {
    errors += 1
  }
  if pbr.roughness_factor < 0.0 || pbr.roughness_factor > 1.0 {
    errors += 1
  }
  if material.alpha_cutoff < 0.0 || material.alpha_cutoff > 1.0 {
    errors += 1
  }
  if !color_is_valid(pbr.base_color_factor) {
    errors += 1
  }
  errors
}

///|
pub fn material_signature(material : GltfMaterial) -> String {
  let pbr = material.pbr_metallic_roughness
  let texture_signature = material_texture_semantics(material)
    .map(texture_semantic_name)
    .join(",")
  "\{pbr.base_color_factor.r}:\{pbr.base_color_factor.g}:\{pbr.base_color_factor.b}:\{pbr.base_color_factor.a}:\{pbr.metallic_factor}:\{pbr.roughness_factor}:\{alpha_mode_name(material.alpha_mode)}:\{material.alpha_cutoff}:\{material.double_sided}:\{texture_signature}"
}

///|
fn image_uri(doc : GltfDocument, image : Int) -> String? {
  match doc.images.get(image) {
    Some(value) => value.uri
    None => None
  }
}

///|
fn texture_slot_report(
  doc : GltfDocument,
  material_index : Int,
  semantic : TextureSemantic,
  info : TextureInfo,
) -> TextureSlotReport {
  let issues : Array[String] = []
  let texture = info.index
  let texture_value = doc.textures.get(texture)
  let image = match texture_value {
    Some(value) => value.source
    None => None
  }
  let sampler = match texture_value {
    Some(value) => value.sampler
    None => None
  }
  if texture_value is None {
    issues.push("texture index is outside the document")
  }
  match image {
    Some(index) =>
      if index < 0 || index >= doc.images.length() {
        issues.push("image index is outside the document")
      }
    None => issues.push("texture has no source image")
  }
  if info.tex_coord < 0 {
    issues.push("texCoord cannot be negative")
  }
  let uri = match image {
    Some(index) => image_uri(doc, index)
    None => None
  }
  let embedded = match uri {
    Some(value) => value.has_prefix("data:")
    None => false
  }
  let external = match uri {
    Some(value) => !value.has_prefix("data:")
    None => false
  }
  {
    material: material_index,
    semantic,
    texture,
    image,
    sampler,
    tex_coord: info.tex_coord,
    uri,
    embedded,
    external,
    valid: issues.length() == 0,
    issues,
  }
}

///|
pub fn material_texture_slot_reports(
  doc : GltfDocument,
  material_index : Int,
) -> Array[TextureSlotReport] {
  match doc.materials.get(material_index) {
    None => []
    Some(material) => {
      let result : Array[TextureSlotReport] = []
      for semantic in material_texture_semantics(material) {
        match material_texture_info(material, semantic) {
          Some(info) =>
            result.push(
              texture_slot_report(doc, material_index, semantic, info),
            )
          None => ()
        }
      }
      result
    }
  }
}

///|
fn material_issue(
  material : Int,
  severity : DiagnosticSeverity,
  code : String,
  path : String,
  message : String,
  hint : String?,
) -> MaterialIssue {
  { material, severity, code, path, message, hint }
}

///|
pub fn material_report(
  doc : GltfDocument,
  material_index : Int,
) -> MaterialReport {
  match doc.materials.get(material_index) {
    None =>
      {
        material: material_index,
        name: None,
        alpha_mode: Opaque,
        texture_slot_count: 0,
        texcoord_set_count: 0,
        has_normal_map: false,
        has_emissive: false,
        has_transparency: false,
        double_sided: false,
        metallic_factor: 0.0,
        roughness_factor: 1.0,
        base_color: { r: 1.0, g: 1.0, b: 1.0, a: 1.0 },
        texture_slots: [],
        issues: [
          material_issue(
            material_index,
            Error,
            "INVALID_MATERIAL",
            "materials[\{material_index}]",
            "material index is outside the document",
            None,
          ),
        ],
        signature: "",
        valid: false,
      }
    Some(material) => {
      let slots = material_texture_slot_reports(doc, material_index)
      let issues : Array[MaterialIssue] = []
      let pbr_errors = material_pbr_parameter_error_count(material)
      if pbr_errors > 0 {
        issues.push(
          material_issue(
            material_index,
            Error,
            "PBR_RANGE",
            "materials[\{material_index}]",
            "one or more PBR factors are outside their legal range",
            Some("clamp metallic, roughness, alpha cutoff, and color values"),
          ),
        )
      }
      if material.double_sided {
        issues.push(
          material_issue(
            material_index,
            Info,
            "DOUBLE_SIDED",
            "materials[\{material_index}].doubleSided",
            "material disables back-face culling",
            Some("use double-sided only for intentionally thin surfaces"),
          ),
        )
      }
      if material.alpha_mode == Mask &&
        (material.alpha_cutoff < 0.0 || material.alpha_cutoff > 1.0) {
        issues.push(
          material_issue(
            material_index,
            Error,
            "ALPHA_CUTOFF",
            "materials[\{material_index}].alphaCutoff",
            "alpha cutoff must be between zero and one",
            None,
          ),
        )
      }
      for slot in slots {
        for text in slot.issues {
          issues.push(
            material_issue(
              material_index,
              Error,
              "TEXTURE_REFERENCE",
              "materials[\{material_index}]",
              text,
              Some("repair texture, image, and sampler references"),
            ),
          )
        }
      }
      {
        material: material_index,
        name: material.name,
        alpha_mode: material.alpha_mode,
        texture_slot_count: slots.length(),
        texcoord_set_count: material_texcoord_sets(material).length(),
        has_normal_map: material_has_normal_map(material),
        has_emissive: material_has_emissive_map(material),
        has_transparency: material_is_transparent(material),
        double_sided: material.double_sided,
        metallic_factor: material.pbr_metallic_roughness.metallic_factor,
        roughness_factor: material.pbr_metallic_roughness.roughness_factor,
        base_color: material.pbr_metallic_roughness.base_color_factor,
        texture_slots: slots,
        issues,
        signature: material_signature(material),
        valid: issues.fold(init=true, (passed, issue) => {
          passed && issue.severity != Error
        }),
      }
    }
  }
}

///|
pub fn all_material_reports(doc : GltfDocument) -> Array[MaterialReport] {
  let reports : Array[MaterialReport] = []
  for index in 0..<doc.materials.length() {
    reports.push(material_report(doc, index))
  }
  reports
}

///|
pub fn material_usage_counts_by_mesh(doc : GltfDocument) -> Array[Int] {
  let counts : Array[Int] = []
  for _ in doc.materials {
    counts.push(0)
  }
  for mesh in doc.meshes {
    for primitive in mesh.primitives {
      match primitive.material {
        Some(index) =>
          if index >= 0 && index < counts.length() {
            counts[index] += 1
          }
        None => ()
      }
    }
  }
  counts
}

///|
pub fn unused_material_indices(doc : GltfDocument) -> Array[Int] {
  let counts = material_usage_counts_by_mesh(doc)
  let result : Array[Int] = []
  for index, count in counts {
    if count == 0 {
      result.push(index)
    }
  }
  result
}

///|
pub fn duplicate_material_groups(doc : GltfDocument) -> Array[Array[Int]] {
  let groups : Map[String, Array[Int]] = Map([])
  for index, material in doc.materials {
    let signature = material_signature(material)
    match groups.get(signature) {
      Some(values) => values.push(index)
      None => groups[signature] = [index]
    }
  }
  let result : Array[Array[Int]] = []
  for _, values in groups {
    if values.length() > 1 {
      result.push(values)
    }
  }
  result
}

///|
fn texture_semantic_usage(
  doc : GltfDocument,
  texture_index : Int,
) -> Array[TextureSemantic] {
  let result : Array[TextureSemantic] = []
  for material in doc.materials {
    for semantic in material_texture_semantics(material) {
      match material_texture_info(material, semantic) {
        Some(info) =>
          if info.index == texture_index && !result.contains(semantic) {
            result.push(semantic)
          }
        None => ()
      }
    }
  }
  result
}

///|
pub fn texture_report(doc : GltfDocument, texture_index : Int) -> TextureReport {
  match doc.textures.get(texture_index) {
    None =>
      {
        texture: texture_index,
        name: None,
        source_image: None,
        sampler: None,
        uri: None,
        uri_kind: None,
        semantic_count: 0,
        semantic_names: [],
        texcoord_count: 0,
        valid: false,
        issues: ["texture index is outside the document"],
      }
    Some(texture) => {
      let issues : Array[String] = []
      let uri = match texture.source {
        Some(image) => image_uri(doc, image)
        None => None
      }
      if texture.source is None {
        issues.push("texture has no source image")
      }
      let semantics = texture_semantic_usage(doc, texture_index)
      let names = semantics.map(texture_semantic_name)
      let texcoords : Map[Int, Bool] = Map([])
      for material in doc.materials {
        for semantic in material_texture_semantics(material) {
          match material_texture_info(material, semantic) {
            Some(info) =>
              if info.index == texture_index {
                texcoords[info.tex_coord] = true
              }
            None => ()
          }
        }
      }
      {
        texture: texture_index,
        name: texture.name,
        source_image: texture.source,
        sampler: texture.sampler,
        uri,
        uri_kind: uri.map(classify_uri),
        semantic_count: semantics.length(),
        semantic_names: names,
        texcoord_count: texcoords.length(),
        valid: issues.length() == 0,
        issues,
      }
    }
  }
}

///|
pub fn all_texture_reports(doc : GltfDocument) -> Array[TextureReport] {
  let reports : Array[TextureReport] = []
  for index in 0..<doc.textures.length() {
    reports.push(texture_report(doc, index))
  }
  reports
}

///|
pub fn texture_external_count(doc : GltfDocument) -> Int {
  all_texture_reports(doc).fold(init=0, (count, report) => {
    match report.uri {
      Some(uri) => if !uri.has_prefix("data:") { count + 1 } else { count }
      None => count
    }
  })
}

///|
pub fn texture_embedded_count(doc : GltfDocument) -> Int {
  all_texture_reports(doc).fold(init=0, (count, report) => {
    match report.uri {
      Some(uri) => if uri.has_prefix("data:") { count + 1 } else { count }
      None => count
    }
  })
}

///|
pub fn material_alpha_mode_count(doc : GltfDocument, mode : AlphaMode) -> Int {
  doc.materials.fold(init=0, (count, material) => {
    if material.alpha_mode == mode {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn material_double_sided_count(doc : GltfDocument) -> Int {
  doc.materials.fold(init=0, (count, material) => {
    if material.double_sided {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn material_texcoord_max(doc : GltfDocument) -> Int {
  let mut maximum = 0
  for material in doc.materials {
    for value in material_texcoord_sets(material) {
      if value > maximum {
        maximum = value
      }
    }
  }
  maximum
}

///|
pub fn material_invalid_count(doc : GltfDocument) -> Int {
  all_material_reports(doc).fold(init=0, (count, report) => {
    if report.valid {
      count
    } else {
      count + 1
    }
  })
}

///|
pub fn material_budget_result(
  doc : GltfDocument,
  budget : MaterialBudget,
) -> MaterialBudgetResult {
  let reports = all_material_reports(doc)
  let texture_slots = reports.fold(init=0, (sum, report) => {
    sum + report.texture_slot_count
  })
  let images : Map[Int, Bool] = Map([])
  for texture in doc.textures {
    match texture.source {
      Some(image) => images[image] = true
      None => ()
    }
  }
  let external_images = doc.images.fold(init=0, (count, image) => {
    match image.uri {
      Some(uri) => if !uri.has_prefix("data:") { count + 1 } else { count }
      None => count
    }
  })
  material_budget_result_from_values(
    doc.materials.length(),
    texture_slots,
    images.length(),
    external_images,
    material_texcoord_max(doc) + 1,
    material_double_sided_count(doc) > 0,
    material_alpha_mode_count(doc, Blend) > 0,
    budget,
  )
}

///|
/// Evaluate a material policy from reports when the original document is not
/// available. Report data includes the resources actually referenced by
/// material slots, so this remains useful for cached or streamed analyses.
pub fn material_budget_result_from_reports(
  reports : Array[MaterialReport],
  budget : MaterialBudget,
) -> MaterialBudgetResult {
  let texture_slots = reports.fold(init=0, (sum, report) => {
    sum + report.texture_slot_count
  })
  let images : Map[Int, Bool] = Map([])
  let external_images : Map[Int, Bool] = Map([])
  let mut max_texcoord_sets = 0
  let mut has_double_sided = false
  let mut has_blend = false
  for report in reports {
    if report.texcoord_set_count > max_texcoord_sets {
      max_texcoord_sets = report.texcoord_set_count
    }
    if report.double_sided {
      has_double_sided = true
    }
    if report.alpha_mode == Blend {
      has_blend = true
    }
    for slot in report.texture_slots {
      match slot.image {
        Some(image) => {
          images[image] = true
          if slot.external {
            external_images[image] = true
          }
        }
        None => ()
      }
    }
  }
  material_budget_result_from_values(
    reports.length(),
    texture_slots,
    images.length(),
    external_images.length(),
    max_texcoord_sets,
    has_double_sided,
    has_blend,
    budget,
  )
}

///|
fn material_budget_result_from_values(
  material_count : Int,
  texture_slots : Int,
  unique_images : Int,
  external_images : Int,
  texcoord_sets : Int,
  has_double_sided : Bool,
  has_blend : Bool,
  budget : MaterialBudget,
) -> MaterialBudgetResult {
  let material_overage = if material_count > budget.max_materials {
    material_count - budget.max_materials
  } else {
    0
  }
  let texture_slot_overage = if texture_slots > budget.max_texture_slots {
    texture_slots - budget.max_texture_slots
  } else {
    0
  }
  let image_overage = if unique_images > budget.max_unique_images {
    unique_images - budget.max_unique_images
  } else {
    0
  }
  let external_image_overage = if external_images > budget.max_external_images {
    external_images - budget.max_external_images
  } else {
    0
  }
  let texcoord_overage = if texcoord_sets > budget.max_texcoord_sets {
    texcoord_sets - budget.max_texcoord_sets
  } else {
    0
  }
  let violations : Array[String] = []
  if material_overage > 0 {
    violations.push("material budget exceeded by \{material_overage}")
  }
  if texture_slot_overage > 0 {
    violations.push("texture slot budget exceeded by \{texture_slot_overage}")
  }
  if image_overage > 0 {
    violations.push("unique image budget exceeded by \{image_overage}")
  }
  if external_image_overage > 0 {
    violations.push(
      "external image budget exceeded by \{external_image_overage}",
    )
  }
  if texcoord_overage > 0 {
    violations.push(
      "texture coordinate set budget exceeded by \{texcoord_overage}",
    )
  }
  if !budget.allow_double_sided && has_double_sided {
    violations.push("double-sided materials are disabled by policy")
  }
  if !budget.allow_blend && has_blend {
    violations.push("blend materials are disabled by policy")
  }
  {
    passed: violations.length() == 0,
    violations,
    material_overage,
    texture_slot_overage,
    image_overage,
    external_image_overage,
    texcoord_overage,
  }
}

///|
pub fn material_report_summary_lines(
  reports : Array[MaterialReport],
) -> Array[String] {
  let transparent = reports.fold(init=0, (count, report) => {
    if report.has_transparency {
      count + 1
    } else {
      count
    }
  })
  let normal = reports.fold(init=0, (count, report) => {
    if report.has_normal_map {
      count + 1
    } else {
      count
    }
  })
  [
    "materials=\{reports.length()}, transparent=\{transparent}",
    "normal_maps=\{normal}, invalid=\{reports.fold(init=0, (count, report) => if report.valid { count } else { count + 1 })}",
    "textures=\{reports.fold(init=0, (sum, report) => sum + report.texture_slot_count)}",
  ]
}
