///|
/// Quality gates for automated asset pipelines. The functions are pure and
/// deterministic, making them suitable for pre-commit hooks and CI policies.

///|
pub(all) struct QualityThresholds {
  max_draw_calls : Int
  max_vertices : Int
  max_triangles : Int
  min_indexed_ratio : Double
  max_external_uris : Int
  max_depth : Int
  max_errors : Int
  max_warnings : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct QualityViolation {
  rule : String
  actual : String
  expected : String
  severity : DiagnosticSeverity
} derive(Debug, ToJson, Eq)

///|
pub(all) struct QualityGate {
  passed : Bool
  violations : Array[QualityViolation]
  score : Int
} derive(Debug, ToJson, Eq)

///|
pub fn default_quality_thresholds() -> QualityThresholds {
  {
    max_draw_calls: 2048,
    max_vertices: 5_000_000,
    max_triangles: 10_000_000,
    min_indexed_ratio: 0.8,
    max_external_uris: 512,
    max_depth: 128,
    max_errors: 0,
    max_warnings: 64,
  }
}

///|
pub fn mobile_quality_thresholds() -> QualityThresholds {
  {
    max_draw_calls: 256,
    max_vertices: 1_000_000,
    max_triangles: 2_000_000,
    min_indexed_ratio: 0.95,
    max_external_uris: 64,
    max_depth: 64,
    max_errors: 0,
    max_warnings: 16,
  }
}

///|
fn violation(
  violations : Array[QualityViolation],
  rule : String,
  actual : String,
  expected : String,
  severity : DiagnosticSeverity,
) -> Unit {
  violations.push({ rule, actual, expected, severity })
}

///|
fn score_penalty(severity : DiagnosticSeverity) -> Int {
  match severity {
    Info => 1
    Warning => 5
    Error => 20
  }
}

///|
pub fn quality_gate(
  report : AssetReport,
  thresholds : QualityThresholds,
) -> QualityGate {
  let violations : Array[QualityViolation] = []
  if report.geometry.draw_calls > thresholds.max_draw_calls {
    violation(
      violations,
      "draw_calls",
      "\{report.geometry.draw_calls}",
      "<= \{thresholds.max_draw_calls}",
      Warning,
    )
  }
  if report.geometry.vertices > thresholds.max_vertices {
    violation(
      violations,
      "vertices",
      "\{report.geometry.vertices}",
      "<= \{thresholds.max_vertices}",
      Warning,
    )
  }
  if report.geometry.triangles > thresholds.max_triangles {
    violation(
      violations,
      "triangles",
      "\{report.geometry.triangles}",
      "<= \{thresholds.max_triangles}",
      Warning,
    )
  }
  if report.geometry.indexed_ratio < thresholds.min_indexed_ratio {
    violation(
      violations,
      "indexed_ratio",
      "\{report.geometry.indexed_ratio}",
      ">= \{thresholds.min_indexed_ratio}",
      Warning,
    )
  }
  if report.resources.external_uri_count > thresholds.max_external_uris {
    violation(
      violations,
      "external_uris",
      "\{report.resources.external_uri_count}",
      "<= \{thresholds.max_external_uris}",
      Warning,
    )
  }
  if report.transforms.max_depth > thresholds.max_depth {
    violation(
      violations,
      "scene_depth",
      "\{report.transforms.max_depth}",
      "<= \{thresholds.max_depth}",
      Warning,
    )
  }
  if report.diagnostics.errors > thresholds.max_errors {
    violation(
      violations,
      "diagnostic_errors",
      "\{report.diagnostics.errors}",
      "<= \{thresholds.max_errors}",
      Error,
    )
  }
  if report.diagnostics.warnings > thresholds.max_warnings {
    violation(
      violations,
      "diagnostic_warnings",
      "\{report.diagnostics.warnings}",
      "<= \{thresholds.max_warnings}",
      Warning,
    )
  }
  let mut penalty = 0
  for item in violations {
    penalty += score_penalty(item.severity)
  }
  let score = if penalty >= 100 { 0 } else { 100 - penalty }
  let passed = for_all_quality_violations(violations, item => {
    item.severity is Info
  })
  { passed, violations, score }
}

///|
fn for_all_quality_violations(
  items : Array[QualityViolation],
  predicate : (QualityViolation) -> Bool,
) -> Bool {
  for item in items {
    if !predicate(item) {
      return false
    }
  }
  true
}

///|
pub fn quality_gate_default(report : AssetReport) -> QualityGate {
  quality_gate(report, default_quality_thresholds())
}

///|
pub fn quality_gate_mobile(report : AssetReport) -> QualityGate {
  quality_gate(report, mobile_quality_thresholds())
}

///|
pub fn quality_violation_lines(gate : QualityGate) -> Array[String] {
  gate.violations.map(item => {
    "\{item.rule}: actual=\{item.actual}, expected=\{item.expected}"
  })
}

///|
pub fn material_texture_count(material : GltfMaterial) -> Int {
  let mut count = 0
  match material.pbr_metallic_roughness.base_color_texture {
    Some(_) => count += 1
    None => ()
  }
  match material.pbr_metallic_roughness.metallic_roughness_texture {
    Some(_) => count += 1
    None => ()
  }
  match material.normal_texture {
    Some(_) => count += 1
    None => ()
  }
  match material.occlusion_texture {
    Some(_) => count += 1
    None => ()
  }
  match material.emissive_texture {
    Some(_) => count += 1
    None => ()
  }
  count
}

///|
pub fn document_texture_slot_count(doc : GltfDocument) -> Int {
  doc.materials.fold(init=0, (sum, material) => {
    sum + material_texture_count(material)
  })
}

///|
pub fn document_materials_with_alpha(doc : GltfDocument) -> Int {
  doc.materials.fold(init=0, (sum, material) => {
    match material.alpha_mode {
      Opaque => sum
      Mask | Blend => sum + 1
    }
  })
}

///|
pub fn document_double_sided_materials(doc : GltfDocument) -> Int {
  doc.materials.fold(init=0, (sum, material) => {
    if material.double_sided {
      sum + 1
    } else {
      sum
    }
  })
}

///|
pub fn document_skinned_nodes(doc : GltfDocument) -> Int {
  doc.nodes.fold(init=0, (sum, node) => {
    match node.skin {
      Some(_) => sum + 1
      None => sum
    }
  })
}

///|
pub fn document_animation_channels(doc : GltfDocument) -> Int {
  doc.animations.fold(init=0, (sum, animation) => {
    sum + animation.channels.length()
  })
}

///|
pub fn document_animation_sampler_count(doc : GltfDocument) -> Int {
  doc.animations.fold(init=0, (sum, animation) => {
    sum + animation.samplers.length()
  })
}

///|
pub fn document_total_mesh_primitives(doc : GltfDocument) -> Int {
  doc.meshes.fold(init=0, (sum, mesh) => sum + mesh.primitives.length())
}

///|
pub fn document_total_vertex_attributes(doc : GltfDocument) -> Int {
  doc.meshes.fold(init=0, (sum, mesh) => {
    sum +
    mesh.primitives.fold(init=0, (inner, primitive) => {
      inner + primitive.attributes.length()
    })
  })
}

///|
pub fn document_named_node_count(doc : GltfDocument) -> Int {
  doc.nodes.fold(init=0, (sum, node) => {
    match node.name {
      Some(_) => sum + 1
      None => sum
    }
  })
}

///|
pub fn document_named_mesh_count(doc : GltfDocument) -> Int {
  doc.meshes.fold(init=0, (sum, mesh) => {
    match mesh.name {
      Some(_) => sum + 1
      None => sum
    }
  })
}

///|
pub fn document_uri_count(doc : GltfDocument) -> Int {
  let deps = collect_resource_deps(doc)
  deps.external_uris.length() +
  deps.embedded_buffer_count +
  deps.embedded_image_count
}

///|
pub fn material_alpha_cutoff_is_valid(material : GltfMaterial) -> Bool {
  material.alpha_cutoff >= 0.0 && material.alpha_cutoff <= 1.0
}

///|
pub fn material_pbr_is_valid(material : GltfMaterial) -> Bool {
  material.pbr_metallic_roughness.metallic_factor >= 0.0 &&
  material.pbr_metallic_roughness.metallic_factor <= 1.0 &&
  material.pbr_metallic_roughness.roughness_factor >= 0.0 &&
  material.pbr_metallic_roughness.roughness_factor <= 1.0
}

///|
pub fn color_is_valid(color : Color4) -> Bool {
  color.r >= 0.0 &&
  color.r <= 1.0 &&
  color.g >= 0.0 &&
  color.g <= 1.0 &&
  color.b >= 0.0 &&
  color.b <= 1.0 &&
  color.a >= 0.0 &&
  color.a <= 1.0
}

///|
pub fn document_material_parameter_errors(doc : GltfDocument) -> Int {
  doc.materials.fold(init=0, (count, material) => {
    let alpha_error = if material_alpha_cutoff_is_valid(material) {
      0
    } else {
      1
    }
    let pbr_error = if material_pbr_is_valid(material) { 0 } else { 1 }
    let color_error = if color_is_valid(
        material.pbr_metallic_roughness.base_color_factor,
      ) {
      0
    } else {
      1
    }
    count + alpha_error + pbr_error + color_error
  })
}
