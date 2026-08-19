///|
/// Production-oriented diagnostics. Validation is intentionally represented as
/// data so CI, an editor integration, and the CLI can apply different policies.

///|
pub(all) enum DiagnosticSeverity {
  Info
  Warning
  Error
} derive(Debug, ToJson, Eq)

///|
pub(all) enum DiagnosticCode {
  EmptyDocument
  InvalidVersion
  MissingDefaultScene
  InvalidReference
  InvalidAccessorLayout
  UnindexedGeometry
  MissingPosition
  MissingMaterial
  UnusedResource
  DeepScene
  LargeBuffer
  ExternalDependency
  AnimationReference
  SkinReference
} derive(Debug, ToJson, Eq)

///|
pub(all) struct Diagnostic {
  severity : DiagnosticSeverity
  code : DiagnosticCode
  path : String
  message : String
  hint : String?
} derive(Debug, ToJson, Eq)

///|
pub(all) struct DiagnosticSummary {
  infos : Int
  warnings : Int
  errors : Int
  diagnostics : Array[Diagnostic]
  passed : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct DiagnosticPolicy {
  fail_on_warning : Bool
  max_scene_depth : Int
  max_buffer_bytes : Int
  require_default_scene : Bool
  require_position_attribute : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn default_diagnostic_policy() -> DiagnosticPolicy {
  {
    fail_on_warning: false,
    max_scene_depth: 128,
    max_buffer_bytes: 256 * 1024 * 1024,
    require_default_scene: false,
    require_position_attribute: true,
  }
}

///|
pub fn strict_diagnostic_policy() -> DiagnosticPolicy {
  {
    fail_on_warning: true,
    max_scene_depth: 64,
    max_buffer_bytes: 64 * 1024 * 1024,
    require_default_scene: true,
    require_position_attribute: true,
  }
}

///|
fn severity_name(value : DiagnosticSeverity) -> String {
  match value {
    Info => "info"
    Warning => "warning"
    Error => "error"
  }
}

///|
fn code_name(value : DiagnosticCode) -> String {
  match value {
    EmptyDocument => "EMPTY_DOCUMENT"
    InvalidVersion => "INVALID_VERSION"
    MissingDefaultScene => "MISSING_DEFAULT_SCENE"
    InvalidReference => "INVALID_REFERENCE"
    InvalidAccessorLayout => "INVALID_ACCESSOR_LAYOUT"
    UnindexedGeometry => "UNINDEXED_GEOMETRY"
    MissingPosition => "MISSING_POSITION"
    MissingMaterial => "MISSING_MATERIAL"
    UnusedResource => "UNUSED_RESOURCE"
    DeepScene => "DEEP_SCENE"
    LargeBuffer => "LARGE_BUFFER"
    ExternalDependency => "EXTERNAL_DEPENDENCY"
    AnimationReference => "ANIMATION_REFERENCE"
    SkinReference => "SKIN_REFERENCE"
  }
}

///|
pub fn diagnostic_to_line(diagnostic : Diagnostic) -> String {
  let hint = match diagnostic.hint {
    Some(value) => " hint=\{value}"
    None => ""
  }
  "[\{severity_name(diagnostic.severity)}] \{code_name(diagnostic.code)} \{diagnostic.path}: \{diagnostic.message}\{hint}"
}

///|
pub fn diagnostics_to_lines(summary : DiagnosticSummary) -> Array[String] {
  summary.diagnostics.map(diagnostic_to_line)
}

///|
fn push_diagnostic(
  diagnostics : Array[Diagnostic],
  severity : DiagnosticSeverity,
  code : DiagnosticCode,
  path : String,
  message : String,
  hint : String?,
) -> Unit {
  diagnostics.push({ severity, code, path, message, hint })
}

///|
fn check_version(doc : GltfDocument, diagnostics : Array[Diagnostic]) -> Unit {
  if doc.version != "2.0" {
    push_diagnostic(
      diagnostics,
      Error,
      InvalidVersion,
      "asset.version",
      "only glTF version 2.0 is supported",
      Some("export the asset as glTF 2.0"),
    )
  }
}

///|
fn check_default_scene(
  doc : GltfDocument,
  policy : DiagnosticPolicy,
  diagnostics : Array[Diagnostic],
) -> Unit {
  if policy.require_default_scene && doc.default_scene is None {
    push_diagnostic(
      diagnostics,
      Warning,
      MissingDefaultScene,
      "scene",
      "asset has no default scene",
      Some("set the scene field in the exporter"),
    )
  }
  match doc.default_scene {
    Some(index) =>
      if index < 0 || index >= doc.scenes.length() {
        push_diagnostic(
          diagnostics,
          Error,
          InvalidReference,
          "scene",
          "default scene index is out of range",
          None,
        )
      }
    None => ()
  }
}

///|
fn check_scene_depth(
  doc : GltfDocument,
  policy : DiagnosticPolicy,
  diagnostics : Array[Diagnostic],
) -> Unit {
  let info = traverse_node_tree(doc)
  if info.max_depth > policy.max_scene_depth {
    push_diagnostic(
      diagnostics,
      Warning,
      DeepScene,
      "nodes",
      "scene depth exceeds the configured limit",
      Some("flatten unnecessary helper nodes"),
    )
  }
}

///|
fn check_buffers(
  doc : GltfDocument,
  policy : DiagnosticPolicy,
  diagnostics : Array[Diagnostic],
) -> Unit {
  for index in 0..<doc.buffers.length() {
    let buffer = doc.buffers[index]
    if buffer.byte_length < 0 {
      push_diagnostic(
        diagnostics,
        Error,
        InvalidReference,
        "buffers[\{index}]",
        "byteLength cannot be negative",
        None,
      )
    }
    if buffer.byte_length > policy.max_buffer_bytes {
      push_diagnostic(
        diagnostics,
        Warning,
        LargeBuffer,
        "buffers[\{index}]",
        "buffer is larger than the configured policy",
        Some("split or compress the asset"),
      )
    }
    match buffer.uri {
      Some(uri) =>
        if !uri.has_prefix("data:") {
          push_diagnostic(
            diagnostics,
            Info,
            ExternalDependency,
            "buffers[\{index}].uri",
            "asset depends on an external URI",
            Some("package the URI beside the asset"),
          )
        }
      None => ()
    }
  }
}

///|
fn check_buffer_views(
  doc : GltfDocument,
  diagnostics : Array[Diagnostic],
) -> Unit {
  for index in 0..<doc.buffer_views.length() {
    let view = doc.buffer_views[index]
    if view.buffer < 0 || view.buffer >= doc.buffers.length() {
      push_diagnostic(
        diagnostics,
        Error,
        InvalidReference,
        "bufferViews[{index}].buffer",
        "buffer index is out of range",
        None,
      )
    } else if view.byte_offset < 0 ||
      view.byte_length < 0 ||
      buffer_view_end(view) > doc.buffers[view.buffer].byte_length {
      push_diagnostic(
        diagnostics,
        Error,
        InvalidReference,
        "bufferViews[{index}]",
        "view exceeds its parent buffer",
        None,
      )
    }
    if !buffer_view_is_aligned(view) {
      push_diagnostic(
        diagnostics,
        Warning,
        InvalidAccessorLayout,
        "bufferViews[{index}]",
        "view offset is not four-byte aligned",
        Some("align bufferView offsets to four bytes"),
      )
    }
  }
}

///|
fn check_accessors(doc : GltfDocument, diagnostics : Array[Diagnostic]) -> Unit {
  for issue in validate_accessor_layouts(doc) {
    push_diagnostic(
      diagnostics,
      Error,
      InvalidAccessorLayout,
      "accessors[{issue.accessor}]",
      issue.message,
      Some("check byteOffset, byteStride and count"),
    )
  }
  for index in 0..<doc.accessors.length() {
    let accessor = doc.accessors[index]
    if accessor.count < 0 {
      push_diagnostic(
        diagnostics,
        Error,
        InvalidAccessorLayout,
        "accessors[{index}].count",
        "count cannot be negative",
        None,
      )
    }
    if accessor.normalized &&
      !component_info(accessor.component_type).normalized_range {
      push_diagnostic(
        diagnostics,
        Warning,
        InvalidAccessorLayout,
        "accessors[{index}].normalized",
        "normalization is not defined for this component type",
        None,
      )
    }
  }
}

///|
fn check_meshes(
  doc : GltfDocument,
  policy : DiagnosticPolicy,
  diagnostics : Array[Diagnostic],
) -> Unit {
  for mesh_index in 0..<doc.meshes.length() {
    let mesh = doc.meshes[mesh_index]
    for primitive_index in 0..<mesh.primitives.length() {
      let primitive = mesh.primitives[primitive_index]
      if policy.require_position_attribute &&
        !primitive.attributes.contains("POSITION") {
        push_diagnostic(
          diagnostics,
          Error,
          MissingPosition,
          "meshes[{mesh_index}].primitives[{primitive_index}]",
          "primitive has no POSITION attribute",
          None,
        )
      }
      if !primitive_is_indexed(primitive) {
        push_diagnostic(
          diagnostics,
          Warning,
          UnindexedGeometry,
          "meshes[{mesh_index}].primitives[{primitive_index}]",
          "primitive is not indexed",
          Some("reuse vertices when topology permits"),
        )
      }
      match primitive.material {
        Some(index) =>
          if index < 0 || index >= doc.materials.length() {
            push_diagnostic(
              diagnostics,
              Error,
              InvalidReference,
              "meshes[{mesh_index}].material",
              "material index is out of range",
              None,
            )
          }
        None =>
          push_diagnostic(
            diagnostics,
            Info,
            MissingMaterial,
            "meshes[{mesh_index}].primitives[{primitive_index}]",
            "primitive uses the default material",
            None,
          )
      }
    }
  }
}

///|
fn check_nodes(doc : GltfDocument, diagnostics : Array[Diagnostic]) -> Unit {
  for index in 0..<doc.nodes.length() {
    let node = doc.nodes[index]
    match node.mesh {
      Some(mesh) =>
        if mesh < 0 || mesh >= doc.meshes.length() {
          push_diagnostic(
            diagnostics,
            Error,
            InvalidReference,
            "nodes[\{index}].mesh",
            "mesh index is out of range",
            None,
          )
        }
      None => ()
    }
    match node.skin {
      Some(skin) =>
        if skin < 0 || skin >= doc.skins.length() {
          push_diagnostic(
            diagnostics,
            Error,
            SkinReference,
            "nodes[\{index}].skin",
            "skin index is out of range",
            None,
          )
        }
      None => ()
    }
    for child in node.children {
      if child < 0 || child >= doc.nodes.length() {
        push_diagnostic(
          diagnostics,
          Error,
          InvalidReference,
          "nodes[\{index}].children",
          "child node index is out of range",
          None,
        )
      }
    }
  }
}

///|
fn check_animations(
  doc : GltfDocument,
  diagnostics : Array[Diagnostic],
) -> Unit {
  for animation_index in 0..<doc.animations.length() {
    let animation = doc.animations[animation_index]
    for channel_index in 0..<animation.channels.length() {
      let channel = animation.channels[channel_index]
      match channel.target.node {
        Some(node) =>
          if node < 0 || node >= doc.nodes.length() {
            push_diagnostic(
              diagnostics,
              Error,
              AnimationReference,
              "animations[{animation_index}].channels[{channel_index}]",
              "target node index is out of range",
              None,
            )
          }
        None =>
          push_diagnostic(
            diagnostics,
            Warning,
            AnimationReference,
            "animations[{animation_index}].channels[{channel_index}]",
            "animation channel has no target node",
            None,
          )
      }
      if channel.sampler < 0 || channel.sampler >= animation.samplers.length() {
        push_diagnostic(
          diagnostics,
          Error,
          AnimationReference,
          "animations[{animation_index}].channels[{channel_index}].sampler",
          "sampler index is out of range",
          None,
        )
      }
    }
  }
}

///|
pub fn diagnose(
  doc : GltfDocument,
  policy : DiagnosticPolicy,
) -> DiagnosticSummary {
  let diagnostics : Array[Diagnostic] = []
  if doc.version == "" && doc.scenes.length() == 0 && doc.nodes.length() == 0 {
    push_diagnostic(
      diagnostics,
      Error,
      EmptyDocument,
      "asset",
      "document contains no scene data",
      None,
    )
  }
  check_version(doc, diagnostics)
  check_default_scene(doc, policy, diagnostics)
  check_scene_depth(doc, policy, diagnostics)
  check_buffers(doc, policy, diagnostics)
  check_buffer_views(doc, diagnostics)
  check_accessors(doc, diagnostics)
  check_meshes(doc, policy, diagnostics)
  check_nodes(doc, diagnostics)
  check_animations(doc, diagnostics)
  let mut infos = 0
  let mut warnings = 0
  let mut errors = 0
  for diagnostic in diagnostics {
    match diagnostic.severity {
      Info => infos += 1
      Warning => warnings += 1
      Error => errors += 1
    }
  }
  {
    infos,
    warnings,
    errors,
    diagnostics,
    passed: errors == 0 && (!policy.fail_on_warning || warnings == 0),
  }
}

///|
pub fn diagnose_default(doc : GltfDocument) -> DiagnosticSummary {
  diagnose(doc, default_diagnostic_policy())
}

///|
pub fn diagnose_strict(doc : GltfDocument) -> DiagnosticSummary {
  diagnose(doc, strict_diagnostic_policy())
}
