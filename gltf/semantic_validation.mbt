///|
/// Cross-object semantic validation for production importers.
///
/// Structural parsing only proves that JSON has the expected shape. These
/// rules validate relationships between arrays and the invariants that a
/// runtime loader depends on: reference bounds, scene reachability, accessor
/// ranges, material chains, animation targets, skin joints, and safe resource
/// names.

///|
pub(all) enum SemanticSeverity {
  Note
  Warning
  Error
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SemanticIssue {
  severity : SemanticSeverity
  rule : String
  path : String
  message : String
  hint : String?
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SemanticValidationReport {
  valid : Bool
  notes : Int
  warnings : Int
  errors : Int
  issues : Array[SemanticIssue]
  checked_references : Int
  checked_accessors : Int
  checked_primitives : Int
  checked_resources : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SemanticValidationPolicy {
  require_asset_version_2 : Bool
  require_scene : Bool
  require_scene_reachability : Bool
  reject_duplicate_names : Bool
  reject_negative_indices : Bool
  require_position : Bool
  require_material_reference : Bool
  reject_unsafe_uris : Bool
  reject_non_monotonic_animation_times : Bool
  max_name_length : Int
} derive(Debug, ToJson, Eq)

///|
pub fn default_semantic_policy() -> SemanticValidationPolicy {
  {
    require_asset_version_2: true,
    require_scene: false,
    require_scene_reachability: false,
    reject_duplicate_names: false,
    reject_negative_indices: true,
    require_position: true,
    require_material_reference: false,
    reject_unsafe_uris: true,
    reject_non_monotonic_animation_times: true,
    max_name_length: 256,
  }
}

///|
pub fn strict_semantic_policy() -> SemanticValidationPolicy {
  {
    require_asset_version_2: true,
    require_scene: true,
    require_scene_reachability: true,
    reject_duplicate_names: true,
    reject_negative_indices: true,
    require_position: true,
    require_material_reference: true,
    reject_unsafe_uris: true,
    reject_non_monotonic_animation_times: true,
    max_name_length: 128,
  }
}

///|
fn semantic_issue(
  severity : SemanticSeverity,
  rule : String,
  path : String,
  message : String,
  hint : String?,
) -> SemanticIssue {
  { severity, rule, path, message, hint }
}

///|
pub fn semantic_severity_name(severity : SemanticSeverity) -> String {
  match severity {
    Note => "note"
    Warning => "warning"
    Error => "error"
  }
}

///|
pub fn semantic_issue_line(issue : SemanticIssue) -> String {
  let hint = match issue.hint {
    Some(value) => " hint=\{value}"
    None => ""
  }
  "[\{semantic_severity_name(issue.severity)}] \{issue.rule} \{issue.path}: \{issue.message}\{hint}"
}

///|
fn check_index(
  issues : Array[SemanticIssue],
  value : Int,
  upper : Int,
  path : String,
  rule : String,
  policy : SemanticValidationPolicy,
) -> Unit {
  if (policy.reject_negative_indices && value < 0) || value >= upper {
    issues.push(
      semantic_issue(
        Error,
        rule,
        path,
        "index \{value} is outside the valid range 0..\{upper}",
        None,
      ),
    )
  }
}

///|
fn check_name(
  issues : Array[SemanticIssue],
  name : String?,
  path : String,
  policy : SemanticValidationPolicy,
) -> Unit {
  match name {
    Some(value) => {
      if value == "" {
        issues.push(
          semantic_issue(
            Warning,
            "EMPTY_NAME",
            path,
            "name is empty",
            Some("omit the name or provide a stable editor-facing name"),
          ),
        )
      }
      if value.length() > policy.max_name_length {
        issues.push(
          semantic_issue(
            Warning,
            "NAME_TOO_LONG",
            path,
            "name exceeds the configured maximum length",
            None,
          ),
        )
      }
    }
    None => ()
  }
}

///|
fn validate_asset(
  doc : GltfDocument,
  issues : Array[SemanticIssue],
  policy : SemanticValidationPolicy,
) -> Int {
  let mut checked = 1
  if policy.require_asset_version_2 && doc.version != "2.0" {
    issues.push(
      semantic_issue(
        Error,
        "ASSET_VERSION",
        "asset.version",
        "only glTF 2.0 assets are accepted by this pipeline",
        Some("export the asset with glTF version 2.0"),
      ),
    )
  }
  if doc.scenes.length() == 0 {
    issues.push(
      if policy.require_scene {
        semantic_issue(
          Error,
          "EMPTY_SCENES",
          "scenes",
          "asset contains no scenes",
          Some("export at least one scene"),
        )
      } else {
        semantic_issue(
          Note,
          "EMPTY_SCENES",
          "scenes",
          "asset contains no scenes",
          None,
        )
      },
    )
  }
  checked += doc.scenes.length()
  checked
}

///|
fn validate_scene_references(
  doc : GltfDocument,
  issues : Array[SemanticIssue],
  policy : SemanticValidationPolicy,
) -> Int {
  let mut checked = 0
  match doc.default_scene {
    Some(scene) => {
      checked += 1
      check_index(
        issues,
        scene,
        doc.scenes.length(),
        "scene",
        "DEFAULT_SCENE",
        policy,
      )
    }
    None =>
      if policy.require_scene && doc.scenes.length() > 0 {
        issues.push(
          semantic_issue(
            Error,
            "MISSING_DEFAULT_SCENE",
            "scene",
            "asset has scenes but no default scene",
            Some("set the scene field for deterministic playback"),
          ),
        )
      }
  }
  for scene_index, scene in doc.scenes {
    check_name(issues, scene.name, "scenes[\{scene_index}].name", policy)
    for root, node in scene.nodes {
      checked += 1
      check_index(
        issues,
        node,
        doc.nodes.length(),
        "scenes[\{scene_index}].nodes[\{root}]",
        "SCENE_NODE_REFERENCE",
        policy,
      )
    }
  }
  if policy.require_scene_reachability {
    let orphan = orphan_node_indices(doc)
    if orphan.length() > 0 {
      issues.push(
        semantic_issue(
          Error,
          "ORPHAN_NODES",
          "nodes",
          "scene graph contains \{orphan.length()} unreachable nodes",
          Some("attach nodes to a scene or remove editor-only leftovers"),
        ),
      )
    }
  }
  checked
}

///|
fn validate_nodes(
  doc : GltfDocument,
  issues : Array[SemanticIssue],
  policy : SemanticValidationPolicy,
) -> Int {
  let mut checked = 0
  for node_index, node in doc.nodes {
    check_name(issues, node.name, "nodes[\{node_index}].name", policy)
    let local_children : Map[Int, Bool] = Map([])
    for child, child_index in node.children {
      checked += 1
      check_index(
        issues,
        child_index,
        doc.nodes.length(),
        "nodes[\{node_index}].children[\{child}]",
        "NODE_CHILD_REFERENCE",
        policy,
      )
      if local_children.contains(child_index) {
        issues.push(
          semantic_issue(
            Error,
            "DUPLICATE_CHILD",
            "nodes[\{node_index}].children[\{child}]",
            "node lists the same child more than once",
            Some("deduplicate child references"),
          ),
        )
      } else {
        local_children[child_index] = true
      }
      if child_index == node_index {
        issues.push(
          semantic_issue(
            Error,
            "SELF_CYCLE",
            "nodes[\{node_index}].children[\{child}]",
            "node directly references itself",
            None,
          ),
        )
      }
    }
    match node.mesh {
      Some(mesh) => {
        checked += 1
        check_index(
          issues,
          mesh,
          doc.meshes.length(),
          "nodes[\{node_index}].mesh",
          "NODE_MESH_REFERENCE",
          policy,
        )
      }
      None => ()
    }
    match node.skin {
      Some(skin) => {
        checked += 1
        check_index(
          issues,
          skin,
          doc.skins.length(),
          "nodes[\{node_index}].skin",
          "NODE_SKIN_REFERENCE",
          policy,
        )
      }
      None => ()
    }
  }
  if scene_cycle_count(doc) > 0 {
    issues.push(
      semantic_issue(
        Error,
        "SCENE_CYCLE",
        "nodes",
        "scene graph contains a cycle",
        Some("repair parent-child links before runtime import"),
      ),
    )
  }
  checked
}

///|
fn validate_meshes(
  doc : GltfDocument,
  issues : Array[SemanticIssue],
  policy : SemanticValidationPolicy,
) -> (Int, Int) {
  let mut checked = 0
  let mut primitives = 0
  for mesh_index, mesh in doc.meshes {
    check_name(issues, mesh.name, "meshes[\{mesh_index}].name", policy)
    for primitive_index, primitive in mesh.primitives {
      primitives += 1
      checked += primitive.attributes.length()
      if policy.require_position && primitive.attributes.get("POSITION") is None {
        issues.push(
          semantic_issue(
            Error,
            "MISSING_POSITION",
            "meshes[\{mesh_index}].primitives[\{primitive_index}]",
            "primitive has no POSITION attribute",
            Some("export vertex positions for every renderable primitive"),
          ),
        )
      }
      for name, accessor in primitive.attributes {
        check_index(
          issues,
          accessor,
          doc.accessors.length(),
          "meshes[\{mesh_index}].primitives[\{primitive_index}].attributes.\{name}",
          "ATTRIBUTE_REFERENCE",
          policy,
        )
      }
      match primitive.indices {
        Some(accessor) =>
          check_index(
            issues,
            accessor,
            doc.accessors.length(),
            "meshes[\{mesh_index}].primitives[\{primitive_index}].indices",
            "INDEX_REFERENCE",
            policy,
          )
        None => ()
      }
      match primitive.material {
        Some(material) =>
          check_index(
            issues,
            material,
            doc.materials.length(),
            "meshes[\{mesh_index}].primitives[\{primitive_index}].material",
            "MATERIAL_REFERENCE",
            policy,
          )
        None =>
          if policy.require_material_reference {
            issues.push(
              semantic_issue(
                Warning,
                "MISSING_MATERIAL",
                "meshes[\{mesh_index}].primitives[\{primitive_index}]",
                "primitive has no material reference",
                Some(
                  "assign a material or make the missing-material policy explicit",
                ),
              ),
            )
          }
      }
      if primitive.mode == Triangles &&
        primitive.indices is None &&
        primitive.attributes.get("POSITION") is Some(accessor) &&
        doc.accessors.get(accessor) is Some(value) &&
        value.count % 3 != 0 {
        issues.push(
          semantic_issue(
            Warning,
            "TRAILING_VERTICES",
            "meshes[\{mesh_index}].primitives[\{primitive_index}]",
            "non-indexed triangle primitive has trailing vertices",
            Some("ensure POSITION count is divisible by three"),
          ),
        )
      }
    }
  }
  (checked, primitives)
}

///|
fn validate_materials(
  doc : GltfDocument,
  issues : Array[SemanticIssue],
  policy : SemanticValidationPolicy,
) -> Int {
  let mut checked = 0
  for material_index, material in doc.materials {
    checked += 1
    check_name(
      issues,
      material.name,
      "materials[\{material_index}].name",
      policy,
    )
    if material_pbr_parameter_error_count(material) > 0 {
      issues.push(
        semantic_issue(
          Error,
          "MATERIAL_RANGE",
          "materials[\{material_index}]",
          "material parameters are outside legal PBR ranges",
          Some("validate metallic, roughness, alpha cutoff, and color factors"),
        ),
      )
    }
    for semantic in material_texture_semantics(material) {
      match material_texture_info(material, semantic) {
        Some(info) => {
          checked += 1
          check_index(
            issues,
            info.index,
            doc.textures.length(),
            "materials[\{material_index}].\{texture_semantic_name(semantic)}.index",
            "TEXTURE_REFERENCE",
            policy,
          )
          if info.tex_coord < 0 {
            issues.push(
              semantic_issue(
                Error,
                "TEXCOORD_RANGE",
                "materials[\{material_index}]",
                "texture coordinate set cannot be negative",
                None,
              ),
            )
          }
        }
        None => ()
      }
    }
  }
  checked
}

///|
fn validate_textures(
  doc : GltfDocument,
  issues : Array[SemanticIssue],
  policy : SemanticValidationPolicy,
) -> Int {
  let mut checked = 0
  for texture_index, texture in doc.textures {
    match texture.source {
      Some(image) => {
        checked += 1
        check_index(
          issues,
          image,
          doc.images.length(),
          "textures[\{texture_index}].source",
          "IMAGE_REFERENCE",
          policy,
        )
      }
      None => ()
    }
    match texture.sampler {
      Some(sampler) => {
        checked += 1
        check_index(
          issues,
          sampler,
          doc.samplers.length(),
          "textures[\{texture_index}].sampler",
          "SAMPLER_REFERENCE",
          policy,
        )
      }
      None => ()
    }
  }
  for image_index, image in doc.images {
    check_name(issues, image.name, "images[\{image_index}].name", policy)
    match image.buffer_view {
      Some(view) => {
        checked += 1
        check_index(
          issues,
          view,
          doc.buffer_views.length(),
          "images[\{image_index}].bufferView",
          "IMAGE_BUFFER_VIEW",
          policy,
        )
      }
      None => ()
    }
    match image.uri {
      Some(uri) =>
        if policy.reject_unsafe_uris && !uri_is_safe_external(uri) {
          issues.push(
            semantic_issue(
              Error,
              "UNSAFE_URI",
              "images[\{image_index}].uri",
              "image URI is not safe for package resolution",
              Some("use a relative path without parent traversal"),
            ),
          )
        }
      None =>
        if image.buffer_view is None {
          issues.push(
            semantic_issue(
              Error,
              "IMAGE_SOURCE_MISSING",
              "images[\{image_index}]",
              "image has neither a URI nor a bufferView",
              None,
            ),
          )
        }
    }
  }
  checked
}

///|
fn validate_buffers(
  doc : GltfDocument,
  issues : Array[SemanticIssue],
  policy : SemanticValidationPolicy,
) -> Int {
  let mut checked = 0
  for index, buffer in doc.buffers {
    checked += 1
    check_name(issues, buffer.name, "buffers[\{index}].name", policy)
    if buffer.byte_length < 0 {
      issues.push(
        semantic_issue(
          Error,
          "BUFFER_LENGTH",
          "buffers[\{index}].byteLength",
          "buffer byteLength cannot be negative",
          None,
        ),
      )
    }
    match buffer.uri {
      Some(uri) =>
        if policy.reject_unsafe_uris && !uri_is_safe_external(uri) {
          issues.push(
            semantic_issue(
              Error,
              "UNSAFE_URI",
              "buffers[\{index}].uri",
              "buffer URI is not safe for package resolution",
              None,
            ),
          )
        }
      None => ()
    }
  }
  for index, view in doc.buffer_views {
    checked += 1
    check_index(
      issues,
      view.buffer,
      doc.buffers.length(),
      "bufferViews[\{index}].buffer",
      "BUFFER_VIEW_BUFFER",
      policy,
    )
    if view.byte_offset < 0 || view.byte_length < 0 {
      issues.push(
        semantic_issue(
          Error,
          "BUFFER_VIEW_RANGE",
          "bufferViews[\{index}]",
          "bufferView offsets and lengths cannot be negative",
          None,
        ),
      )
    }
    if view.byte_stride is Some(stride) &&
      (stride < 4 || stride > 252 || stride % 4 != 0) {
      issues.push(
        semantic_issue(
          Error,
          "BUFFER_VIEW_STRIDE",
          "bufferViews[\{index}].byteStride",
          "byteStride must be aligned and within glTF limits",
          None,
        ),
      )
    }
  }
  checked
}

///|
fn validate_accessors(
  doc : GltfDocument,
  issues : Array[SemanticIssue],
  policy : SemanticValidationPolicy,
) -> Int {
  let mut checked = 0
  for index, accessor in doc.accessors {
    checked += 1
    check_name(issues, accessor.name, "accessors[\{index}].name", policy)
    if accessor.count < 0 || accessor.byte_offset < 0 {
      issues.push(
        semantic_issue(
          Error,
          "ACCESSOR_RANGE",
          "accessors[\{index}]",
          "accessor count and byteOffset must be non-negative",
          None,
        ),
      )
    }
    if accessor.min_values.length() > 0 &&
      accessor.min_values.length() !=
      accessor_component_count(accessor.accessor_type) {
      issues.push(
        semantic_issue(
          Error,
          "ACCESSOR_MIN_SHAPE",
          "accessors[\{index}].min",
          "min array length does not match accessor type",
          None,
        ),
      )
    }
    if accessor.max_values.length() > 0 &&
      accessor.max_values.length() !=
      accessor_component_count(accessor.accessor_type) {
      issues.push(
        semantic_issue(
          Error,
          "ACCESSOR_MAX_SHAPE",
          "accessors[\{index}].max",
          "max array length does not match accessor type",
          None,
        ),
      )
    }
    for component in 0..<accessor.min_values.length() {
      if accessor.min_values[component] > accessor.max_values[component] {
        issues.push(
          semantic_issue(
            Error,
            "ACCESSOR_BOUNDS",
            "accessors[\{index}]",
            "accessor min value exceeds max value",
            None,
          ),
        )
      }
    }
    match accessor.buffer_view {
      Some(view) =>
        check_index(
          issues,
          view,
          doc.buffer_views.length(),
          "accessors[\{index}].bufferView",
          "ACCESSOR_BUFFER_VIEW",
          policy,
        )
      None =>
        if accessor.count > 0 {
          issues.push(
            semantic_issue(
              Warning,
              "SPARSE_UNSUPPORTED",
              "accessors[\{index}]",
              "accessor has no bufferView and requires sparse data support",
              Some("provide a regular bufferView for this importer"),
            ),
          )
        }
    }
    let layout = accessor_layout(doc, index)
    if !layout.valid {
      for problem in layout.problems {
        issues.push(
          semantic_issue(
            Error,
            "ACCESSOR_LAYOUT",
            "accessors[\{index}]",
            problem,
            None,
          ),
        )
      }
    }
  }
  checked
}

///|
fn validate_animations(
  doc : GltfDocument,
  issues : Array[SemanticIssue],
  policy : SemanticValidationPolicy,
) -> Int {
  let mut checked = 0
  for animation_index, animation in doc.animations {
    check_name(
      issues,
      animation.name,
      "animations[\{animation_index}].name",
      policy,
    )
    for sampler_index, sampler in animation.samplers {
      checked += 1
      check_index(
        issues,
        sampler.input,
        doc.accessors.length(),
        "animations[\{animation_index}].samplers[\{sampler_index}].input",
        "ANIMATION_INPUT",
        policy,
      )
      check_index(
        issues,
        sampler.output,
        doc.accessors.length(),
        "animations[\{animation_index}].samplers[\{sampler_index}].output",
        "ANIMATION_OUTPUT",
        policy,
      )
    }
    for channel_index, channel in animation.channels {
      checked += 1
      check_index(
        issues,
        channel.sampler,
        animation.samplers.length(),
        "animations[\{animation_index}].channels[\{channel_index}].sampler",
        "ANIMATION_SAMPLER",
        policy,
      )
      match channel.target.node {
        Some(node) =>
          check_index(
            issues,
            node,
            doc.nodes.length(),
            "animations[\{animation_index}].channels[\{channel_index}].target.node",
            "ANIMATION_NODE",
            policy,
          )
        None =>
          issues.push(
            semantic_issue(
              Warning,
              "ANIMATION_GLOBAL_TARGET",
              "animations[\{animation_index}].channels[\{channel_index}]",
              "animation channel has no target node",
              None,
            ),
          )
      }
    }
  }
  checked
}

///|
fn validate_skins(
  doc : GltfDocument,
  issues : Array[SemanticIssue],
  policy : SemanticValidationPolicy,
) -> Int {
  let mut checked = 0
  for skin_index, skin in doc.skins {
    check_name(issues, skin.name, "skins[\{skin_index}].name", policy)
    for joint, node in skin.joints {
      checked += 1
      check_index(
        issues,
        node,
        doc.nodes.length(),
        "skins[\{skin_index}].joints[\{joint}]",
        "SKIN_JOINT",
        policy,
      )
    }
    match skin.skeleton {
      Some(node) =>
        check_index(
          issues,
          node,
          doc.nodes.length(),
          "skins[\{skin_index}].skeleton",
          "SKIN_SKELETON",
          policy,
        )
      None => ()
    }
    match skin.inverse_bind_matrices {
      Some(accessor) =>
        check_index(
          issues,
          accessor,
          doc.accessors.length(),
          "skins[\{skin_index}].inverseBindMatrices",
          "SKIN_INVERSE_BIND",
          policy,
        )
      None => ()
    }
    if skin_duplicate_joint_count(doc, skin_index) > 0 {
      issues.push(
        semantic_issue(
          Error,
          "SKIN_DUPLICATE_JOINT",
          "skins[\{skin_index}].joints",
          "skin joint list contains duplicates",
          None,
        ),
      )
    }
  }
  checked
}

///|
pub fn semantic_validate(
  doc : GltfDocument,
  policy : SemanticValidationPolicy,
) -> SemanticValidationReport {
  let issues : Array[SemanticIssue] = []
  let mut references = 0
  let mut accessors = 0
  let mut primitives = 0
  let mut resources = 0
  ignore(validate_asset(doc, issues, policy))
  references += validate_scene_references(doc, issues, policy)
  references += validate_nodes(doc, issues, policy)
  let (mesh_refs, primitive_count) = validate_meshes(doc, issues, policy)
  references += mesh_refs
  primitives += primitive_count
  references += validate_materials(doc, issues, policy)
  resources += validate_textures(doc, issues, policy)
  resources += validate_buffers(doc, issues, policy)
  accessors += validate_accessors(doc, issues, policy)
  references += validate_animations(doc, issues, policy)
  references += validate_skins(doc, issues, policy)
  if policy.reject_duplicate_names && named_node_duplicate_count(doc) > 0 {
    issues.push(
      semantic_issue(
        Error,
        "DUPLICATE_NODE_NAMES",
        "nodes",
        "multiple nodes share the same name",
        Some("use stable unique names for editor and runtime lookup"),
      ),
    )
  }
  let notes = issues.fold(init=0, (count, issue) => {
    if issue.severity == Note {
      count + 1
    } else {
      count
    }
  })
  let warnings = issues.fold(init=0, (count, issue) => {
    if issue.severity == Warning {
      count + 1
    } else {
      count
    }
  })
  let errors = issues.fold(init=0, (count, issue) => {
    if issue.severity == Error {
      count + 1
    } else {
      count
    }
  })
  {
    valid: errors == 0,
    notes,
    warnings,
    errors,
    issues,
    checked_references: references,
    checked_accessors: accessors,
    checked_primitives: primitives,
    checked_resources: resources,
  }
}

///|
pub fn semantic_validate_default(
  doc : GltfDocument,
) -> SemanticValidationReport {
  semantic_validate(doc, default_semantic_policy())
}

///|
pub fn semantic_validate_strict(doc : GltfDocument) -> SemanticValidationReport {
  semantic_validate(doc, strict_semantic_policy())
}

///|
pub fn semantic_issue_lines(report : SemanticValidationReport) -> Array[String] {
  report.issues.map(semantic_issue_line)
}

///|
pub fn semantic_error_issues(
  report : SemanticValidationReport,
) -> Array[SemanticIssue] {
  report.issues.filter(issue => issue.severity == Error)
}

///|
pub fn semantic_warning_issues(
  report : SemanticValidationReport,
) -> Array[SemanticIssue] {
  report.issues.filter(issue => issue.severity == Warning)
}

///|
pub fn semantic_rule_count(
  report : SemanticValidationReport,
  rule : String,
) -> Int {
  report.issues.fold(init=0, (count, issue) => {
    if issue.rule == rule {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn semantic_report_summary_lines(
  report : SemanticValidationReport,
) -> Array[String] {
  [
    "valid=\{report.valid}, errors=\{report.errors}, warnings=\{report.warnings}, notes=\{report.notes}",
    "references=\{report.checked_references}, accessors=\{report.checked_accessors}",
    "primitives=\{report.checked_primitives}, resources=\{report.checked_resources}",
  ]
}
