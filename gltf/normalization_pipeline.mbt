///|
/// Non-destructive canonicalization plans for reproducible asset builds.

///|
pub(all) enum NormalizationAction {
  NormalizeUri
  NormalizeQuaternion
  NormalizeWeights
  ClampMaterialFactors
  RepairNodeNames
  RemoveUnusedRecord
  MergeDuplicateRecord
  AlignBufferView
  ReorderExtensionList
} derive(Debug, ToJson, Eq)

///|
pub(all) struct NormalizationFinding {
  action : NormalizationAction
  path : String
  before : String
  after : String
  safe : Bool
  applied : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct NormalizationPlan {
  findings : Array[NormalizationFinding]
  safe_count : Int
  review_count : Int
  valid : Bool
  fingerprint : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct NormalizationPolicy {
  normalize_uris : Bool
  normalize_quaternions : Bool
  normalize_weights : Bool
  clamp_material_factors : Bool
  repair_names : Bool
  remove_unused : Bool
  merge_duplicates : Bool
  align_views : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn default_normalization_policy() -> NormalizationPolicy {
  {
    normalize_uris: true,
    normalize_quaternions: true,
    normalize_weights: true,
    clamp_material_factors: true,
    repair_names: false,
    remove_unused: false,
    merge_duplicates: false,
    align_views: true,
  }
}

///|
pub fn normalization_action_name(action : NormalizationAction) -> String {
  match action {
    NormalizeUri => "normalize-uri"
    NormalizeQuaternion => "normalize-quaternion"
    NormalizeWeights => "normalize-weights"
    ClampMaterialFactors => "clamp-material-factors"
    RepairNodeNames => "repair-node-names"
    RemoveUnusedRecord => "remove-unused-record"
    MergeDuplicateRecord => "merge-duplicate-record"
    AlignBufferView => "align-buffer-view"
    ReorderExtensionList => "reorder-extension-list"
  }
}

///|
fn normalization_finding(
  action : NormalizationAction,
  path : String,
  before : String,
  after : String,
  safe : Bool,
) -> NormalizationFinding {
  { action, path, before, after, safe, applied: false }
}

///|
pub fn normalized_node_name(name : String, fallback : String) -> String {
  let trimmed = name.trim()
  if trimmed.is_empty() {
    fallback
  } else {
    let builder = StringBuilder()
    let mut previous_space = false
    for character in trimmed {
      let is_space = character == ' ' || character == '\t' || character == '\n'
      if is_space {
        if !previous_space {
          builder.write_char('_')
        }
        previous_space = true
      } else {
        builder.write_char(character)
        previous_space = false
      }
    }
    builder.to_string()
  }
}

///|
pub fn normalized_uri_value(uri : String) -> String {
  match classify_uri(uri) {
    Relative => normalize_relative_uri(uri)
    _ => uri
  }
}

///|
pub fn normalized_quaternion_value(value : Quat) -> Quat {
  normalize_quaternion(value)
}

///|
pub fn normalized_weight_values(values : Array[Double]) -> Array[Double] {
  normalize_weights(values)
}

///|
pub fn clamped_material_factor(value : Double) -> Double {
  if value < 0.0 {
    0.0
  } else if value > 1.0 {
    1.0
  } else {
    value
  }
}

///|
pub fn normalized_material_factors(
  material : GltfMaterial,
) -> (Double, Double, Double) {
  (
    clamped_material_factor(material.pbr_metallic_roughness.metallic_factor),
    clamped_material_factor(material.pbr_metallic_roughness.roughness_factor),
    clamped_material_factor(material.alpha_cutoff),
  )
}

///|
fn add_uri_findings(
  doc : GltfDocument,
  findings : Array[NormalizationFinding],
) -> Unit {
  for index, buffer in doc.buffers {
    match buffer.uri {
      Some(uri) => {
        let normalized = normalized_uri_value(uri)
        if uri != normalized {
          findings.push(
            normalization_finding(
              NormalizeUri,
              "buffers[\{index}].uri",
              uri,
              normalized,
              true,
            ),
          )
        }
      }
      None => ()
    }
  }
  for index, image in doc.images {
    match image.uri {
      Some(uri) => {
        let normalized = normalized_uri_value(uri)
        if uri != normalized {
          findings.push(
            normalization_finding(
              NormalizeUri,
              "images[\{index}].uri",
              uri,
              normalized,
              true,
            ),
          )
        }
      }
      None => ()
    }
  }
}

///|
fn add_node_name_findings(
  doc : GltfDocument,
  findings : Array[NormalizationFinding],
  policy : NormalizationPolicy,
) -> Unit {
  if policy.repair_names {
    for index, node in doc.nodes {
      match node.name {
        Some(name) => {
          let normalized = normalized_node_name(name, "node_\{index}")
          if name != normalized {
            findings.push(
              normalization_finding(
                RepairNodeNames,
                "nodes[\{index}].name",
                name,
                normalized,
                false,
              ),
            )
          }
        }
        None =>
          findings.push(
            normalization_finding(
              RepairNodeNames,
              "nodes[\{index}].name",
              "",
              "node_\{index}",
              false,
            ),
          )
      }
    }
  }
}

///|
fn add_normalization_material_findings(
  doc : GltfDocument,
  findings : Array[NormalizationFinding],
) -> Unit {
  for index, material in doc.materials {
    let before = normalized_material_factors(material)
    let changed = before.0 != material.pbr_metallic_roughness.metallic_factor ||
      before.1 != material.pbr_metallic_roughness.roughness_factor ||
      before.2 != material.alpha_cutoff
    if changed {
      findings.push(
        normalization_finding(
          ClampMaterialFactors,
          "materials[\{index}]",
          "\{material.pbr_metallic_roughness.metallic_factor},\{material.pbr_metallic_roughness.roughness_factor},\{material.alpha_cutoff}",
          "\{before.0},\{before.1},\{before.2}",
          true,
        ),
      )
    }
  }
}

///|
fn add_accessor_findings(
  doc : GltfDocument,
  findings : Array[NormalizationFinding],
  policy : NormalizationPolicy,
) -> Unit {
  if policy.align_views {
    for index, view in doc.buffer_views {
      if view.byte_offset % 4 != 0 {
        findings.push(
          normalization_finding(
            AlignBufferView,
            "bufferViews[\{index}].byteOffset",
            "\{view.byte_offset}",
            "\{view.byte_offset - view.byte_offset % 4}",
            false,
          ),
        )
      }
    }
  }
}

///|
pub fn normalization_plan(
  doc : GltfDocument,
  policy : NormalizationPolicy,
) -> NormalizationPlan {
  let findings : Array[NormalizationFinding] = []
  if policy.normalize_uris {
    add_uri_findings(doc, findings)
  }
  add_node_name_findings(doc, findings, policy)
  if policy.clamp_material_factors {
    add_normalization_material_findings(doc, findings)
  }
  add_accessor_findings(doc, findings, policy)
  if policy.merge_duplicates {
    for group in duplicate_material_groups(doc) {
      findings.push(
        normalization_finding(
          MergeDuplicateRecord,
          "materials",
          "\{group.length()} records",
          "one canonical record",
          false,
        ),
      )
    }
  }
  let safe = findings.fold(init=0, (count, finding) => {
    if finding.safe {
      count + 1
    } else {
      count
    }
  })
  let review = findings.length() - safe
  let fingerprint = findings.fold(init=0, (hash, finding) => {
    hash * 31 + String::hash(finding.path) + String::hash(finding.after)
  })
  { findings, safe_count: safe, review_count: review, valid: true, fingerprint }
}

///|
pub fn normalization_plan_default(doc : GltfDocument) -> NormalizationPlan {
  normalization_plan(doc, default_normalization_policy())
}

///|
pub fn normalization_plan_safe(
  plan : NormalizationPlan,
) -> Array[NormalizationFinding] {
  plan.findings.filter(finding => finding.safe)
}

///|
pub fn normalization_plan_review(
  plan : NormalizationPlan,
) -> Array[NormalizationFinding] {
  plan.findings.filter(finding => !finding.safe)
}

///|
pub fn normalization_plan_for_action(
  plan : NormalizationPlan,
  action : NormalizationAction,
) -> Array[NormalizationFinding] {
  plan.findings.filter(finding => finding.action == action)
}

///|
pub fn normalization_plan_summary_lines(
  plan : NormalizationPlan,
) -> Array[String] {
  [
    "findings=\{plan.findings.length()}, safe=\{plan.safe_count}, review=\{plan.review_count}",
    "fingerprint=\{plan.fingerprint}, valid=\{plan.valid}",
  ]
}
