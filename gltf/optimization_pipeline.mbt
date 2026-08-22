///|
/// Actionable optimization planning for glTF asset pipelines.
///
/// The analyzer reports facts; this module turns those facts into a stable
/// ordered plan. A plan is intentionally descriptive rather than destructive:
/// a build system can review or apply each action with its own renderer and
/// compression policy.

///|
pub(all) enum OptimizationKind {
  IndexGeometry
  ReorderVertices
  RemoveDegenerateTriangles
  AddMissingNormals
  ReduceDrawCalls
  MergeDuplicateMaterials
  RemoveUnusedMaterials
  ShareDuplicateResources
  PackageExternalResources
  FlattenSceneHelpers
  ReduceAnimationKeys
  LimitSkinInfluences
  NormalizeSkinWeights
  RenameNodes
  RejectUnsafeUri
} derive(Debug, ToJson, Eq)

///|
pub(all) enum OptimizationRisk {
  Safe
  Review
  RendererDependent
  Destructive
} derive(Debug, ToJson, Eq)

///|
pub(all) struct OptimizationFinding {
  kind : OptimizationKind
  risk : OptimizationRisk
  priority : Int
  target : String
  title : String
  reason : String
  action : String
  estimated_bytes_saved : Int
  estimated_draw_calls_saved : Int
  estimated_triangles_saved : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct OptimizationPlan {
  score : Int
  findings : Array[OptimizationFinding]
  safe_count : Int
  review_count : Int
  renderer_dependent_count : Int
  destructive_count : Int
  estimated_bytes_saved : Int
  estimated_draw_calls_saved : Int
  estimated_triangles_saved : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct OptimizationPolicy {
  index_unindexed : Bool
  reject_degenerate : Bool
  target_cache_hit_ratio : Double
  remove_unused_materials : Bool
  merge_duplicate_materials : Bool
  package_external_resources : Bool
  max_draw_calls : Int
  max_animation_keys : Int
  max_skin_influences : Int
} derive(Debug, ToJson, Eq)

///|
pub fn default_optimization_policy() -> OptimizationPolicy {
  {
    index_unindexed: true,
    reject_degenerate: false,
    target_cache_hit_ratio: 0.55,
    remove_unused_materials: true,
    merge_duplicate_materials: true,
    package_external_resources: true,
    max_draw_calls: 1000,
    max_animation_keys: 100000,
    max_skin_influences: 4,
  }
}

///|
pub fn mobile_optimization_policy() -> OptimizationPolicy {
  {
    index_unindexed: true,
    reject_degenerate: true,
    target_cache_hit_ratio: 0.65,
    remove_unused_materials: true,
    merge_duplicate_materials: true,
    package_external_resources: true,
    max_draw_calls: 300,
    max_animation_keys: 50000,
    max_skin_influences: 4,
  }
}

///|
pub fn optimization_kind_name(kind : OptimizationKind) -> String {
  match kind {
    IndexGeometry => "index-geometry"
    ReorderVertices => "reorder-vertices"
    RemoveDegenerateTriangles => "remove-degenerate-triangles"
    AddMissingNormals => "add-missing-normals"
    ReduceDrawCalls => "reduce-draw-calls"
    MergeDuplicateMaterials => "merge-duplicate-materials"
    RemoveUnusedMaterials => "remove-unused-materials"
    ShareDuplicateResources => "share-duplicate-resources"
    PackageExternalResources => "package-external-resources"
    FlattenSceneHelpers => "flatten-scene-helpers"
    ReduceAnimationKeys => "reduce-animation-keys"
    LimitSkinInfluences => "limit-skin-influences"
    NormalizeSkinWeights => "normalize-skin-weights"
    RenameNodes => "rename-nodes"
    RejectUnsafeUri => "reject-unsafe-uri"
  }
}

///|
pub fn optimization_risk_name(risk : OptimizationRisk) -> String {
  match risk {
    Safe => "safe"
    Review => "review"
    RendererDependent => "renderer-dependent"
    Destructive => "destructive"
  }
}

///|
fn finding(
  kind : OptimizationKind,
  risk : OptimizationRisk,
  priority : Int,
  target : String,
  title : String,
  reason : String,
  action : String,
  bytes : Int,
  draws : Int,
  triangles : Int,
) -> OptimizationFinding {
  {
    kind,
    risk,
    priority,
    target,
    title,
    reason,
    action,
    estimated_bytes_saved: if bytes < 0 {
      0
    } else {
      bytes
    },
    estimated_draw_calls_saved: if draws < 0 {
      0
    } else {
      draws
    },
    estimated_triangles_saved: if triangles < 0 {
      0
    } else {
      triangles
    },
    valid: true,
  }
}

///|
fn add_mesh_findings(
  doc : GltfDocument,
  asset : BinaryAsset,
  policy : OptimizationPolicy,
  findings : Array[OptimizationFinding],
) -> Unit {
  let geometry = document_geometry_report(doc, asset)
  for mesh in geometry.meshes {
    for primitive in mesh.primitives {
      if policy.index_unindexed &&
        !primitive.indexed &&
        primitive.vertex_count > 0 {
        let estimated = primitive.vertex_count * 4
        findings.push(
          finding(
            IndexGeometry,
            RendererDependent,
            60,
            "meshes[\{mesh.mesh_index}].primitives[\{primitive.primitive_index}]",
            "index repeated vertex data",
            "primitive is not indexed and repeats vertex attributes",
            "generate an index buffer and deduplicate equivalent vertices",
            estimated,
            0,
            0,
          ),
        )
      }
      if primitive.triangles.degenerate_count > 0 {
        findings.push(
          finding(
            RemoveDegenerateTriangles,
            if policy.reject_degenerate {
              Destructive
            } else {
              Review
            },
            90,
            "meshes[\{mesh.mesh_index}].primitives[\{primitive.primitive_index}]",
            "remove degenerate triangles",
            "\{primitive.triangles.degenerate_count} triangles have zero area",
            "remove zero-area triangles after preserving material groups",
            0,
            0,
            primitive.triangles.degenerate_count,
          ),
        )
      }
      if primitive.cache_hit_ratio < policy.target_cache_hit_ratio &&
        primitive.indexed {
        findings.push(
          finding(
            ReorderVertices,
            RendererDependent,
            55,
            "meshes[\{mesh.mesh_index}].primitives[\{primitive.primitive_index}]",
            "reorder vertices for post-transform cache locality",
            "measured vertex cache hit ratio is below the target",
            "run a cache-aware triangle reorderer for the target GPU profile",
            0,
            0,
            0,
          ),
        )
      }
      if !primitive.channels.normal && primitive.triangle_count > 0 {
        findings.push(
          finding(
            AddMissingNormals,
            RendererDependent,
            40,
            "meshes[\{mesh.mesh_index}].primitives[\{primitive.primitive_index}]",
            "generate missing normals",
            "primitive has triangles but no NORMAL channel",
            "generate angle-weighted vertex normals before runtime upload",
            0,
            0,
            0,
          ),
        )
      }
      if primitive.overdraw_proxy > 0.25 {
        findings.push(
          finding(
            ReduceDrawCalls,
            Review,
            35,
            "meshes[\{mesh.mesh_index}].primitives[\{primitive.primitive_index}]",
            "review projected overdraw",
            "triangle area distribution suggests high overlap",
            "inspect material splits and simplify hidden geometry",
            0,
            0,
            0,
          ),
        )
      }
    }
  }
  if geometry.primitive_count > policy.max_draw_calls {
    findings.push(
      finding(
        ReduceDrawCalls,
        Review,
        95,
        "document",
        "reduce draw calls",
        "primitive count exceeds the configured draw-call budget",
        "merge compatible primitives and reduce material splits",
        0,
        geometry.primitive_count - policy.max_draw_calls,
        0,
      ),
    )
  }
}

///|
fn add_material_findings(
  doc : GltfDocument,
  policy : OptimizationPolicy,
  findings : Array[OptimizationFinding],
) -> Unit {
  if policy.remove_unused_materials {
    let unused = unused_material_indices(doc)
    if unused.length() > 0 {
      findings.push(
        finding(
          RemoveUnusedMaterials,
          Safe,
          45,
          "materials",
          "remove unused materials",
          "\{unused.length()} materials are not referenced by any primitive",
          "prune unreferenced material records after export",
          0,
          0,
          0,
        ),
      )
    }
  }
  if policy.merge_duplicate_materials {
    let groups = duplicate_material_groups(doc)
    if groups.length() > 0 {
      let mut duplicate_count = 0
      for group in groups {
        duplicate_count += group.length() - 1
      }
      findings.push(
        finding(
          MergeDuplicateMaterials,
          Safe,
          50,
          "materials",
          "merge duplicate material definitions",
          "\{duplicate_count} material records share a stable signature",
          "replace duplicate references with one canonical material",
          0,
          0,
          0,
        ),
      )
    }
  }
  let double_sided = material_double_sided_count(doc)
  if double_sided > 0 {
    findings.push(
      finding(
        ReduceDrawCalls,
        Review,
        20,
        "materials",
        "review double-sided materials",
        "\{double_sided} materials disable back-face culling",
        "keep double-sided only where thin-surface visibility requires it",
        0,
        0,
        0,
      ),
    )
  }
}

///|
fn add_resource_findings(
  doc : GltfDocument,
  policy : OptimizationPolicy,
  findings : Array[OptimizationFinding],
) -> Unit {
  let manifest = resource_manifest_default(doc)
  if manifest.duplicate_uri_count > 0 {
    findings.push(
      finding(
        ShareDuplicateResources,
        Safe,
        70,
        "resources",
        "share duplicate resource paths",
        "\{manifest.duplicate_uri_count} resource records resolve to duplicate fingerprints",
        "deduplicate packaged resources while preserving references",
        0,
        0,
        0,
      ),
    )
  }
  if policy.package_external_resources && manifest.external_count > 0 {
    findings.push(
      finding(
        PackageExternalResources,
        Safe,
        80,
        "resources",
        "package external dependencies",
        "asset depends on \{manifest.external_count} external resource records",
        "copy dependencies into a deterministic asset package manifest",
        0,
        0,
        0,
      ),
    )
  }
  if manifest.unsafe_count > 0 {
    findings.push(
      finding(
        RejectUnsafeUri,
        Destructive,
        100,
        "resources",
        "reject unsafe resource URIs",
        "\{manifest.unsafe_count} resource paths violate URI safety policy",
        "fail the import or require an explicit path rewrite",
        0,
        0,
        0,
      ),
    )
  }
}

///|
fn add_scene_findings(
  doc : GltfDocument,
  findings : Array[OptimizationFinding],
) -> Unit {
  let report = document_scene_graph_report(doc)
  if report.orphan_count > 0 {
    findings.push(
      finding(
        FlattenSceneHelpers,
        Review,
        30,
        "nodes",
        "remove orphan scene nodes",
        "\{report.orphan_count} nodes are not reachable from the selected scene",
        "prune editor-only helpers or attach them to an explicit scene",
        0,
        0,
        0,
      ),
    )
  }
  if report.max_depth > 64 {
    findings.push(
      finding(
        FlattenSceneHelpers,
        RendererDependent,
        40,
        "nodes",
        "flatten excessively deep helper chains",
        "scene depth is \{report.max_depth}",
        "bake transforms for helper-only nodes where runtime semantics allow",
        0,
        0,
        0,
      ),
    )
  }
  if report.duplicate_name_count > 0 {
    findings.push(
      finding(
        RenameNodes,
        Review,
        25,
        "nodes",
        "make node names unique",
        "\{report.duplicate_name_count} duplicate name occurrences were found",
        "rename nodes used by animation or editor lookup",
        0,
        0,
        0,
      ),
    )
  }
}

///|
fn add_animation_findings(
  doc : GltfDocument,
  asset : BinaryAsset,
  policy : OptimizationPolicy,
  findings : Array[OptimizationFinding],
) -> Unit {
  let reports = all_animation_clip_reports(doc, asset)
  let keyframes = total_animation_keyframes(reports)
  if keyframes > policy.max_animation_keys {
    findings.push(
      finding(
        ReduceAnimationKeys,
        RendererDependent,
        75,
        "animations",
        "reduce animation keyframes",
        "animation data contains \{keyframes} keyframes",
        "run a tolerance-aware keyframe simplifier per animated property",
        0,
        0,
        0,
      ),
    )
  }
  for report in reports {
    if report.invalid_track_count > 0 {
      findings.push(
        finding(
          ReduceAnimationKeys,
          Destructive,
          100,
          "animations[\{report.animation_index}]",
          "repair invalid animation tracks",
          "\{report.invalid_track_count} tracks failed timeline or decode checks",
          "fix accessors and channel references before optimizing keyframes",
          0,
          0,
          0,
        ),
      )
    }
  }
}

///|
fn add_skin_findings(
  doc : GltfDocument,
  asset : BinaryAsset,
  policy : OptimizationPolicy,
  findings : Array[OptimizationFinding],
) -> Unit {
  let reports = all_skin_reports(doc, asset)
  for report in reports {
    if report.weight_summary.max_influences_per_vertex >
      policy.max_skin_influences {
      findings.push(
        finding(
          LimitSkinInfluences,
          RendererDependent,
          70,
          "skins[\{report.skin_index}]",
          "limit vertex skin influences",
          "skin exceeds the configured influence count",
          "retain the strongest influences and renormalize weights",
          0,
          0,
          0,
        ),
      )
    }
    if report.weight_summary.non_normalized_vertex_count > 0 {
      findings.push(
        finding(
          NormalizeSkinWeights,
          Safe,
          65,
          "skins[\{report.skin_index}]",
          "normalize skin weights",
          "\{report.weight_summary.non_normalized_vertex_count} vertices are not normalized",
          "clamp negative values and divide each influence set by its sum",
          0,
          0,
          0,
        ),
      )
    }
  }
}

///|
pub fn optimization_plan(
  doc : GltfDocument,
  asset : BinaryAsset,
  policy : OptimizationPolicy,
) -> OptimizationPlan {
  let findings : Array[OptimizationFinding] = []
  add_mesh_findings(doc, asset, policy, findings)
  add_material_findings(doc, policy, findings)
  add_resource_findings(doc, policy, findings)
  add_scene_findings(doc, findings)
  add_animation_findings(doc, asset, policy, findings)
  add_skin_findings(doc, asset, policy, findings)
  let mut safe = 0
  let mut review = 0
  let mut renderer = 0
  let mut destructive = 0
  let mut bytes = 0
  let mut draws = 0
  let mut triangles = 0
  let mut score = 100
  for item in findings {
    match item.risk {
      Safe => safe += 1
      Review => review += 1
      RendererDependent => renderer += 1
      Destructive => {
        destructive += 1
        score -= 10
      }
    }
    bytes += item.estimated_bytes_saved
    draws += item.estimated_draw_calls_saved
    triangles += item.estimated_triangles_saved
    score -= if item.priority >= 90 {
      5
    } else if item.priority >= 60 {
      2
    } else {
      1
    }
  }
  {
    score: if score < 0 {
      0
    } else {
      score
    },
    findings,
    safe_count: safe,
    review_count: review,
    renderer_dependent_count: renderer,
    destructive_count: destructive,
    estimated_bytes_saved: bytes,
    estimated_draw_calls_saved: draws,
    estimated_triangles_saved: triangles,
    valid: destructive == 0,
  }
}

///|
pub fn optimization_plan_default(
  doc : GltfDocument,
  asset : BinaryAsset,
) -> OptimizationPlan {
  optimization_plan(doc, asset, default_optimization_policy())
}

///|
pub fn optimization_findings_by_risk(
  plan : OptimizationPlan,
  risk : OptimizationRisk,
) -> Array[OptimizationFinding] {
  plan.findings.filter(item => item.risk == risk)
}

///|
pub fn optimization_findings_by_kind(
  plan : OptimizationPlan,
  kind : OptimizationKind,
) -> Array[OptimizationFinding] {
  plan.findings.filter(item => item.kind == kind)
}

///|
pub fn optimization_findings_above_priority(
  plan : OptimizationPlan,
  priority : Int,
) -> Array[OptimizationFinding] {
  plan.findings.filter(item => item.priority >= priority)
}

///|
pub fn optimization_plan_has_blockers(plan : OptimizationPlan) -> Bool {
  plan.destructive_count > 0
}

///|
pub fn optimization_plan_is_empty(plan : OptimizationPlan) -> Bool {
  plan.findings.length() == 0
}

///|
pub fn optimization_plan_top_priority(
  plan : OptimizationPlan,
) -> OptimizationFinding? {
  let mut best : OptimizationFinding? = None
  for item in plan.findings {
    match best {
      None => best = Some(item)
      Some(old) => if item.priority > old.priority { best = Some(item) }
    }
  }
  best
}

///|
pub fn optimization_plan_summary_lines(
  plan : OptimizationPlan,
) -> Array[String] {
  [
    "score=\{plan.score}, findings=\{plan.findings.length()}, valid=\{plan.valid}",
    "safe=\{plan.safe_count}, review=\{plan.review_count}, renderer_dependent=\{plan.renderer_dependent_count}, destructive=\{plan.destructive_count}",
    "estimated_bytes_saved=\{plan.estimated_bytes_saved}",
    "estimated_draw_calls_saved=\{plan.estimated_draw_calls_saved}, triangles_saved=\{plan.estimated_triangles_saved}",
  ]
}

///|
pub fn optimization_finding_line(item : OptimizationFinding) -> String {
  "[\{item.priority}] \{optimization_kind_name(item.kind)} (\{optimization_risk_name(item.risk)}) \{item.target}: \{item.title} - \{item.reason}"
}

///|
pub fn optimization_finding_lines(plan : OptimizationPlan) -> Array[String] {
  plan.findings.map(optimization_finding_line)
}
