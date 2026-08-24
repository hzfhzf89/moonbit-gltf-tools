///|
/// Unified production profile for CI, importers, and asset dashboards.
///
/// This is the orchestration layer for the independent analyzers. It keeps
/// every measured domain visible in one stable value, computes a transparent
/// score, and exposes policy failures separately from advisory findings.

///|
pub(all) enum ProductionVerdict {
  Pass
  PassWithWarnings
  Fail
  Empty
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ProductionPolicy {
  semantic : SemanticValidationPolicy
  geometry : GeometryBudget
  materials : MaterialBudget
  resources : ResourcePolicy
  skins : SkinBudget
  animations : AnimationBudget
  optimization : OptimizationPolicy
  minimum_score : Int
  fail_on_warnings : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ProductionMetrics {
  vertices : Int
  indices : Int
  triangles : Int
  draw_calls : Int
  attribute_bytes : Int
  scene_nodes : Int
  scene_depth : Int
  materials : Int
  textures : Int
  images : Int
  external_resources : Int
  resource_bytes : Int
  animations : Int
  animation_keyframes : Int
  skins : Int
  skin_joints : Int
  diagnostic_errors : Int
  diagnostic_warnings : Int
  semantic_errors : Int
  semantic_warnings : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ProductionGate {
  passed : Bool
  score : Int
  verdict : ProductionVerdict
  violations : Array[String]
  warnings : Array[String]
  metric_failures : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ProductionProfile {
  version : String
  generator : String?
  verdict : ProductionVerdict
  metrics : ProductionMetrics
  asset_report : AssetReport
  semantic : SemanticValidationReport
  geometry : DocumentGeometryReport
  scene : SceneGraphReport
  materials : Array[MaterialReport]
  textures : Array[TextureReport]
  resources : ResourceManifest
  animations : Array[AnimationClipReport]
  skins : Array[SkinReport]
  optimization : OptimizationPlan
  gate : ProductionGate
} derive(Debug, ToJson, Eq)

///|
pub fn default_production_policy() -> ProductionPolicy {
  {
    semantic: default_semantic_policy(),
    geometry: default_geometry_budget(),
    materials: default_material_budget(),
    resources: default_resource_policy(),
    skins: default_skin_budget(),
    animations: default_animation_budget(),
    optimization: default_optimization_policy(),
    minimum_score: 70,
    fail_on_warnings: false,
  }
}

///|
pub fn mobile_production_policy() -> ProductionPolicy {
  {
    semantic: strict_semantic_policy(),
    geometry: mobile_geometry_budget(),
    materials: mobile_material_budget(),
    resources: embedded_resource_policy(),
    skins: mobile_skin_budget(),
    animations: {
      max_clips: 128,
      max_channels: 4000,
      max_duration: 1800.0,
      max_keyframes: 500000,
      require_monotonic_times: true,
    },
    optimization: mobile_optimization_policy(),
    minimum_score: 80,
    fail_on_warnings: true,
  }
}

///|
pub fn production_verdict_name(verdict : ProductionVerdict) -> String {
  match verdict {
    Pass => "pass"
    PassWithWarnings => "pass-with-warnings"
    Fail => "fail"
    Empty => "empty"
  }
}

///|
fn production_metrics(
  asset : AssetReport,
  geometry : DocumentGeometryReport,
  scene : SceneGraphReport,
  materials : Array[MaterialReport],
  textures : Array[TextureReport],
  resources : ResourceManifest,
  animations : Array[AnimationClipReport],
  skins : Array[SkinReport],
  semantic : SemanticValidationReport,
) -> ProductionMetrics {
  {
    vertices: geometry.vertex_count,
    indices: geometry.index_count,
    triangles: geometry.triangle_count,
    draw_calls: geometry.primitive_count,
    attribute_bytes: geometry.attribute_bytes,
    scene_nodes: scene.reachable_count,
    scene_depth: scene.max_depth,
    materials: materials.length(),
    textures: textures.length(),
    images: resource_manifest_image_count(resources),
    external_resources: resources.external_count,
    resource_bytes: resources.declared_bytes,
    animations: animations.length(),
    animation_keyframes: total_animation_keyframes(animations),
    skins: skins.length(),
    skin_joints: skins.fold(init=0, (sum, report) => sum + report.joint_count),
    diagnostic_errors: asset.diagnostics.errors,
    diagnostic_warnings: asset.diagnostics.warnings,
    semantic_errors: semantic.errors,
    semantic_warnings: semantic.warnings,
  }
}

///|
fn production_score_penalty(value : Int, threshold : Int, weight : Int) -> Int {
  if value <= threshold {
    0
  } else {
    let overage = value - threshold
    let denominator = if threshold <= 0 { 1 } else { threshold }
    let penalty = overage * weight / denominator
    if penalty < 1 {
      1
    } else {
      penalty
    }
  }
}

///|
pub fn production_score(
  metrics : ProductionMetrics,
  policy : ProductionPolicy,
) -> Int {
  let mut score = 100
  score -= metrics.diagnostic_errors * 20
  score -= metrics.semantic_errors * 15
  score -= metrics.semantic_warnings * 2
  score -= production_score_penalty(
    metrics.draw_calls,
    policy.geometry.max_draw_calls,
    15,
  )
  score -= production_score_penalty(
    metrics.vertices,
    policy.geometry.max_vertices,
    10,
  )
  score -= production_score_penalty(
    metrics.scene_depth,
    policy.skins.max_depth,
    5,
  )
  score -= production_score_penalty(
    metrics.external_resources,
    policy.resources.max_external_count,
    10,
  )
  if score < 0 {
    0
  } else if score > 100 {
    100
  } else {
    score
  }
}

///|
fn production_gate_with_results(
  metrics : ProductionMetrics,
  semantic : SemanticValidationReport,
  geometry : DocumentGeometryReport,
  material_result : MaterialBudgetResult,
  resource_result : ResourcePolicyResult,
  skin_result : SkinBudgetResult,
  animation_result : AnimationBudgetResult,
  policy : ProductionPolicy,
) -> ProductionGate {
  let violations : Array[String] = []
  let warnings : Array[String] = []
  let metric_failures : Array[String] = []
  let score = production_score(metrics, policy)
  let geometry_result = geometry_budget_result(geometry, policy.geometry)
  for issue in semantic_error_issues(semantic) {
    violations.push(semantic_issue_line(issue))
  }
  for violation in geometry_result.violations {
    metric_failures.push(violation)
  }
  for violation in material_result.violations {
    metric_failures.push(violation)
  }
  for violation in resource_result.violations {
    metric_failures.push(violation)
  }
  for violation in skin_result.violations {
    metric_failures.push(violation)
  }
  for violation in animation_result.violations {
    metric_failures.push(violation)
  }
  if policy.fail_on_warnings {
    for issue in semantic_warning_issues(semantic) {
      violations.push(semantic_issue_line(issue))
    }
  } else {
    for issue in semantic_warning_issues(semantic) {
      warnings.push(semantic_issue_line(issue))
    }
  }
  if score < policy.minimum_score {
    violations.push(
      "production score \{score} is below the minimum \{policy.minimum_score}",
    )
  }
  for failure in metric_failures {
    violations.push(failure)
  }
  let verdict = if metrics.scene_nodes == 0 &&
    metrics.materials == 0 &&
    metrics.vertices == 0 {
    ProductionVerdict::Empty
  } else if violations.length() > 0 {
    Fail
  } else if warnings.length() > 0 {
    PassWithWarnings
  } else {
    Pass
  }
  {
    passed: verdict == Pass || verdict == PassWithWarnings,
    score,
    verdict,
    violations,
    warnings,
    metric_failures,
  }
}

///|
/// Apply a production policy to report data that has already been collected.
/// This compatibility entry point is useful to dashboards and cache readers
/// that do not retain the original document.
pub fn production_gate(
  metrics : ProductionMetrics,
  semantic : SemanticValidationReport,
  geometry : DocumentGeometryReport,
  materials : Array[MaterialReport],
  resources : ResourceManifest,
  animations : Array[AnimationClipReport],
  skins : Array[SkinReport],
  policy : ProductionPolicy,
) -> ProductionGate {
  production_gate_with_results(
    metrics,
    semantic,
    geometry,
    material_budget_result_from_reports(materials, policy.materials),
    resource_policy_result(resources, policy.resources),
    skin_budget_result(skins, policy.skins),
    animation_budget_result_from_reports(animations, policy.animations),
    policy,
  )
}

///|
/// Apply a production policy while retaining document-level resource data.
/// This is the preferred entry point for importers because it counts unused
/// images and non-contiguous texture-coordinate sets as well as referenced
/// material slots.
pub fn production_gate_for_document(
  doc : GltfDocument,
  metrics : ProductionMetrics,
  semantic : SemanticValidationReport,
  geometry : DocumentGeometryReport,
  materials : Array[MaterialReport],
  resources : ResourceManifest,
  animations : Array[AnimationClipReport],
  skins : Array[SkinReport],
  policy : ProductionPolicy,
) -> ProductionGate {
  ignore(materials)
  production_gate_with_results(
    metrics,
    semantic,
    geometry,
    material_budget_result(doc, policy.materials),
    resource_policy_result(resources, policy.resources),
    skin_budget_result(skins, policy.skins),
    animation_budget_result(doc, animations, policy.animations),
    policy,
  )
}

///|
pub fn build_production_profile(
  doc : GltfDocument,
  asset : BinaryAsset,
  policy : ProductionPolicy,
) -> ProductionProfile {
  let asset_report = build_asset_report(doc, default_diagnostic_policy())
  let semantic = semantic_validate(doc, policy.semantic)
  let geometry = document_geometry_report(doc, asset)
  let scene = document_scene_graph_report(doc)
  let materials = all_material_reports(doc)
  let textures = all_texture_reports(doc)
  let resources = resource_manifest(doc, policy.resources)
  let animations = all_animation_clip_reports(doc, asset)
  let skins = all_skin_reports(doc, asset)
  let optimization = optimization_plan(doc, asset, policy.optimization)
  let metrics = production_metrics(
    asset_report, geometry, scene, materials, textures, resources, animations, skins,
    semantic,
  )
  let gate = production_gate_for_document(
    doc, metrics, semantic, geometry, materials, resources, animations, skins, policy,
  )
  {
    version: doc.version,
    generator: doc.generator,
    verdict: gate.verdict,
    metrics,
    asset_report,
    semantic,
    geometry,
    scene,
    materials,
    textures,
    resources,
    animations,
    skins,
    optimization,
    gate,
  }
}

///|
pub fn build_default_production_profile(
  doc : GltfDocument,
  asset : BinaryAsset,
) -> ProductionProfile {
  build_production_profile(doc, asset, default_production_policy())
}

///|
pub fn build_mobile_production_profile(
  doc : GltfDocument,
  asset : BinaryAsset,
) -> ProductionProfile {
  build_production_profile(doc, asset, mobile_production_policy())
}

///|
pub fn production_profile_is_acceptable(profile : ProductionProfile) -> Bool {
  profile.gate.passed
}

///|
pub fn production_profile_score(profile : ProductionProfile) -> Int {
  profile.gate.score
}

///|
pub fn production_profile_has_blockers(profile : ProductionProfile) -> Bool {
  profile.gate.violations.length() > 0
}

///|
pub fn production_profile_summary_lines(
  profile : ProductionProfile,
) -> Array[String] {
  let m = profile.metrics
  [
    "verdict=\{production_verdict_name(profile.verdict)}, score=\{profile.gate.score}",
    "vertices=\{m.vertices}, triangles=\{m.triangles}, draw_calls=\{m.draw_calls}",
    "nodes=\{m.scene_nodes}, materials=\{m.materials}, textures=\{m.textures}",
    "resources=\{m.external_resources} external / \{m.resource_bytes} bytes",
    "animations=\{m.animations} / \{m.animation_keyframes} keys, skins=\{m.skins} / \{m.skin_joints} joints",
    "errors=\{m.diagnostic_errors + m.semantic_errors}, warnings=\{m.diagnostic_warnings + m.semantic_warnings}",
  ]
}

///|
pub fn production_profile_failure_lines(
  profile : ProductionProfile,
) -> Array[String] {
  profile.gate.violations
}

///|
pub fn production_profile_warning_lines(
  profile : ProductionProfile,
) -> Array[String] {
  profile.gate.warnings
}

///|
pub fn production_profile_to_json(profile : ProductionProfile) -> String {
  Repr(profile).to_string()
}
