///|
/// Deterministic resource dependency and packaging analysis.
///
/// glTF documents can reference buffer files, images, data URIs, and GLB
/// embedded chunks. This module turns those references into a manifest that a
/// build system can validate, deduplicate, package, or reject under a path
/// safety policy without reading the host filesystem.

///|
pub(all) enum ResourceKind {
  Buffer
  Image
  EmbeddedBuffer
  EmbeddedImage
  GlbBin
  Unknown
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ResourceRecord {
  id : String
  kind : ResourceKind
  index : Int
  uri : String?
  normalized_uri : String?
  extension : String?
  media_type : String?
  embedded : Bool
  external : Bool
  safe : Bool
  declared_bytes : Int
  mut reference_count : Int
  fingerprint : Int
  references : Array[String]
  issues : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ResourceManifest {
  resources : Array[ResourceRecord]
  external_count : Int
  embedded_count : Int
  unsafe_count : Int
  missing_uri_count : Int
  duplicate_uri_count : Int
  declared_bytes : Int
  referenced_bytes : Int
  fingerprint : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ResourcePolicy {
  allow_external : Bool
  allow_absolute_uri : Bool
  allow_parent_segments : Bool
  allow_data_uri : Bool
  max_external_count : Int
  max_total_declared_bytes : Int
  require_file_extension : Bool
  allowed_image_extensions : Array[String]
  allowed_buffer_extensions : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ResourcePolicyResult {
  passed : Bool
  violations : Array[String]
  external_overage : Int
  byte_overage : Int
  unsafe_count : Int
  unsupported_extension_count : Int
  missing_uri_count : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct PackageEntry {
  source_id : String
  destination : String
  kind : ResourceKind
  uri : String?
  deduplicated : Bool
  safe : Bool
  issues : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct PackagePlan {
  entries : Array[PackageEntry]
  destination_root : String
  total_entries : Int
  deduplicated_entries : Int
  unsafe_entries : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn default_resource_policy() -> ResourcePolicy {
  {
    allow_external: true,
    allow_absolute_uri: false,
    allow_parent_segments: false,
    allow_data_uri: true,
    max_external_count: 10000,
    max_total_declared_bytes: 2 * 1024 * 1024 * 1024,
    require_file_extension: false,
    allowed_image_extensions: ["png", "jpg", "jpeg", "webp", "ktx2"],
    allowed_buffer_extensions: ["bin", "buffer"],
  }
}

///|
pub fn embedded_resource_policy() -> ResourcePolicy {
  {
    allow_external: false,
    allow_absolute_uri: false,
    allow_parent_segments: false,
    allow_data_uri: true,
    max_external_count: 0,
    max_total_declared_bytes: 2 * 1024 * 1024 * 1024,
    require_file_extension: false,
    allowed_image_extensions: ["png", "jpg", "jpeg", "webp", "ktx2"],
    allowed_buffer_extensions: ["bin", "buffer"],
  }
}

///|
pub fn resource_kind_name(kind : ResourceKind) -> String {
  match kind {
    Buffer => "buffer"
    Image => "image"
    EmbeddedBuffer => "embedded-buffer"
    EmbeddedImage => "embedded-image"
    GlbBin => "glb-bin"
    Unknown => "unknown"
  }
}

///|
pub fn resource_fingerprint(value : String) -> Int {
  let mut hash = 216613626
  let mut index = 0
  for character in value {
    hash = (hash ^ character.to_int()) * 16777619
    index += 1
  }
  hash ^ index
}

///|
pub fn resource_fingerprint_bytes(data : Bytes) -> Int {
  binary_checksum(data).reinterpret_as_int()
}

///|
pub fn resource_id(kind : ResourceKind, index : Int) -> String {
  "\{resource_kind_name(kind)}[\{index}]"
}

///|
pub fn resource_uri_is_embedded(uri : String?) -> Bool {
  match uri {
    Some(value) => value.has_prefix("data:")
    None => false
  }
}

///|
pub fn resource_uri_is_external(uri : String?) -> Bool {
  match uri {
    Some(value) =>
      match classify_uri(value) {
        Relative | Absolute => true
        _ => false
      }
    None => false
  }
}

///|
pub fn resource_uri_is_safe(uri : String?, policy : ResourcePolicy) -> Bool {
  match uri {
    None => true
    Some(value) =>
      match classify_uri(value) {
        Empty | Fragment => true
        Data => policy.allow_data_uri
        Relative =>
          (policy.allow_parent_segments || !value.contains("..")) &&
          uri_is_safe_external(value)
        Absolute => policy.allow_absolute_uri
      }
  }
}

///|
pub fn resource_uri_normalized(uri : String?) -> String? {
  match uri {
    Some(value) =>
      match classify_uri(value) {
        Relative => Some(normalize_relative_uri(value))
        _ => Some(value)
      }
    None => None
  }
}

///|
pub fn resource_uri_extension(uri : String?) -> String? {
  match uri {
    Some(value) => uri_extension(value)
    None => None
  }
}

///|
pub fn resource_uri_media_type(uri : String?) -> String? {
  match uri {
    Some(value) => uri_data_media_type(value)
    None => None
  }
}

///|
pub fn resource_uri_payload_length(uri : String?) -> Int {
  match uri {
    None => 0
    Some(value) =>
      if value.has_prefix("data:") {
        match value.split(",").collect().get(1) {
          Some(payload) => payload.length()
          None => 0
        }
      } else {
        0
      }
  }
}

///|
fn record_for_uri(
  kind : ResourceKind,
  index : Int,
  uri : String?,
  declared_bytes : Int,
  reference : String,
  policy : ResourcePolicy,
) -> ResourceRecord {
  let embedded = resource_uri_is_embedded(uri)
  let external = resource_uri_is_external(uri)
  let safe = resource_uri_is_safe(uri, policy)
  let normalized = resource_uri_normalized(uri)
  let extension = resource_uri_extension(uri)
  let media_type = resource_uri_media_type(uri)
  let issues : Array[String] = []
  match uri {
    None =>
      if kind == Buffer || kind == Image {
        issues.push(
          "resource has no URI and is expected to be resolved from embedded data",
        )
      }
    Some(value) => {
      if !safe {
        issues.push("resource URI violates the configured path safety policy")
      }
      if value == "" {
        issues.push("resource URI is empty")
      }
    }
  }
  {
    id: resource_id(kind, index),
    kind,
    index,
    uri,
    normalized_uri: normalized,
    extension,
    media_type,
    embedded,
    external,
    safe,
    declared_bytes: if declared_bytes < 0 {
      0
    } else {
      declared_bytes
    },
    reference_count: 1,
    fingerprint: match normalized {
      Some(value) => resource_fingerprint(value)
      None => resource_fingerprint(resource_id(kind, index))
    },
    references: [reference],
    issues,
  }
}

///|
pub fn document_buffer_resource_records(
  doc : GltfDocument,
  policy : ResourcePolicy,
) -> Array[ResourceRecord] {
  let result : Array[ResourceRecord] = []
  for index, buffer in doc.buffers {
    let kind = match buffer.uri {
      Some(uri) => if uri.has_prefix("data:") { EmbeddedBuffer } else { Buffer }
      None => EmbeddedBuffer
    }
    result.push(
      record_for_uri(
        kind,
        index,
        buffer.uri,
        buffer.byte_length,
        "buffers[\{index}]",
        policy,
      ),
    )
  }
  result
}

///|
pub fn document_image_resource_records(
  doc : GltfDocument,
  policy : ResourcePolicy,
) -> Array[ResourceRecord] {
  let result : Array[ResourceRecord] = []
  for index, image in doc.images {
    let kind = match image.uri {
      Some(uri) => if uri.has_prefix("data:") { EmbeddedImage } else { Image }
      None => EmbeddedImage
    }
    let bytes = match image.buffer_view {
      Some(view) =>
        match doc.buffer_views.get(view) {
          Some(value) => value.byte_length
          None => 0
        }
      None => resource_uri_payload_length(image.uri)
    }
    result.push(
      record_for_uri(kind, index, image.uri, bytes, "images[\{index}]", policy),
    )
  }
  result
}

///|
pub fn document_resource_records(
  doc : GltfDocument,
  policy : ResourcePolicy,
) -> Array[ResourceRecord] {
  let records = document_buffer_resource_records(doc, policy)
  for record in document_image_resource_records(doc, policy) {
    records.push(record)
  }
  records
}

///|
fn add_texture_references(
  doc : GltfDocument,
  records : Array[ResourceRecord],
) -> Unit {
  for material_index, material in doc.materials {
    for semantic in material_texture_semantics(material) {
      match material_texture_info(material, semantic) {
        Some(info) =>
          match doc.textures.get(info.index) {
            Some(texture) =>
              match texture.source {
                Some(image) =>
                  for record in records {
                    if record.kind == Image || record.kind == EmbeddedImage {
                      if record.index == image {
                        record.reference_count += 1
                        record.references.push(
                          "materials[\{material_index}].\{texture_semantic_name(semantic)}",
                        )
                      }
                    }
                  }
                None => ()
              }
            None => ()
          }
        None => ()
      }
    }
  }
}

///|
fn add_mesh_buffer_references(
  doc : GltfDocument,
  records : Array[ResourceRecord],
) -> Unit {
  for accessor in doc.accessors {
    match accessor.buffer_view {
      Some(view_index) =>
        match doc.buffer_views.get(view_index) {
          Some(view) =>
            for record in records {
              if (record.kind == Buffer || record.kind == EmbeddedBuffer) &&
                record.index == view.buffer {
                record.reference_count += 1
                record.references.push("accessor.bufferView")
              }
            }
          None => ()
        }
      None => ()
    }
  }
}

///|
pub fn resource_manifest(
  doc : GltfDocument,
  policy : ResourcePolicy,
) -> ResourceManifest {
  let records = document_resource_records(doc, policy)
  add_texture_references(doc, records)
  add_mesh_buffer_references(doc, records)
  let mut external = 0
  let mut embedded = 0
  let mut unsafe_count = 0
  let mut missing_uri = 0
  let mut declared = 0
  let mut referenced = 0
  let fingerprints : Map[Int, Bool] = Map([])
  let mut duplicate = 0
  let mut fingerprint = 216613626
  for record in records {
    if record.external {
      external += 1
    }
    if record.embedded {
      embedded += 1
    }
    if !record.safe {
      unsafe_count += 1
    }
    if record.uri is None {
      missing_uri += 1
    }
    declared += record.declared_bytes
    if record.reference_count > 0 {
      referenced += record.declared_bytes
    }
    if fingerprints.contains(record.fingerprint) {
      duplicate += 1
    } else {
      fingerprints[record.fingerprint] = true
    }
    fingerprint = (fingerprint ^ record.fingerprint) * 16777619
  }
  {
    resources: records,
    external_count: external,
    embedded_count: embedded,
    unsafe_count,
    missing_uri_count: missing_uri,
    duplicate_uri_count: duplicate,
    declared_bytes: declared,
    referenced_bytes: referenced,
    fingerprint,
    valid: unsafe_count == 0,
  }
}

///|
pub fn resource_manifest_default(doc : GltfDocument) -> ResourceManifest {
  resource_manifest(doc, default_resource_policy())
}

///|
pub fn resource_manifest_external_uris(
  manifest : ResourceManifest,
) -> Array[String] {
  let result : Array[String] = []
  for resource in manifest.resources {
    if resource.external {
      match resource.normalized_uri {
        Some(uri) => if !result.contains(uri) { result.push(uri) }
        None => ()
      }
    }
  }
  result
}

///|
pub fn resource_manifest_embedded_count(manifest : ResourceManifest) -> Int {
  manifest.resources.fold(init=0, (count, resource) => {
    if resource.embedded {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn resource_manifest_external_bytes(manifest : ResourceManifest) -> Int {
  manifest.resources.fold(init=0, (sum, resource) => {
    if resource.external {
      sum + resource.declared_bytes
    } else {
      sum
    }
  })
}

///|
pub fn resource_manifest_image_count(manifest : ResourceManifest) -> Int {
  manifest.resources.fold(init=0, (count, resource) => {
    if resource.kind == Image || resource.kind == EmbeddedImage {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn resource_manifest_buffer_count(manifest : ResourceManifest) -> Int {
  manifest.resources.fold(init=0, (count, resource) => {
    if resource.kind == Buffer || resource.kind == EmbeddedBuffer {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn resource_manifest_duplicate_groups(
  manifest : ResourceManifest,
) -> Array[Array[String]] {
  let groups : Map[Int, Array[String]] = Map([])
  for resource in manifest.resources {
    match groups.get(resource.fingerprint) {
      Some(values) => values.push(resource.id)
      None => groups[resource.fingerprint] = [resource.id]
    }
  }
  let result : Array[Array[String]] = []
  for _, values in groups {
    if values.length() > 1 {
      result.push(values)
    }
  }
  result
}

///|
pub fn resource_extension_count(
  manifest : ResourceManifest,
  extension : String,
) -> Int {
  manifest.resources.fold(init=0, (count, resource) => {
    match resource.extension {
      Some(value) => if value == extension { count + 1 } else { count }
      None => count
    }
  })
}

///|
fn resource_extension_allowed(
  record : ResourceRecord,
  policy : ResourcePolicy,
) -> Bool {
  match record.extension {
    None => !policy.require_file_extension
    Some(extension) =>
      if record.kind == Image || record.kind == EmbeddedImage {
        policy.allowed_image_extensions.contains(extension)
      } else if record.kind == Buffer || record.kind == EmbeddedBuffer {
        policy.allowed_buffer_extensions.contains(extension)
      } else {
        true
      }
  }
}

///|
pub fn resource_policy_result(
  manifest : ResourceManifest,
  policy : ResourcePolicy,
) -> ResourcePolicyResult {
  let external_overage = if manifest.external_count > policy.max_external_count {
    manifest.external_count - policy.max_external_count
  } else {
    0
  }
  let byte_overage = if manifest.declared_bytes >
    policy.max_total_declared_bytes {
    manifest.declared_bytes - policy.max_total_declared_bytes
  } else {
    0
  }
  let mut unsupported = 0
  let mut missing_uri = 0
  let violations : Array[String] = []
  for resource in manifest.resources {
    if !resource_extension_allowed(resource, policy) {
      unsupported += 1
    }
    if resource.uri is None &&
      (resource.kind == Buffer || resource.kind == Image) {
      missing_uri += 1
    }
  }
  if !policy.allow_external && manifest.external_count > 0 {
    violations.push("external resource references are disabled")
  }
  if external_overage > 0 {
    violations.push("external resource budget exceeded by \{external_overage}")
  }
  if byte_overage > 0 {
    violations.push("declared resource bytes exceed policy by \{byte_overage}")
  }
  if manifest.unsafe_count > 0 {
    violations.push("resource manifest contains unsafe URI paths")
  }
  if unsupported > 0 {
    violations.push("\{unsupported} resources use unsupported extensions")
  }
  if missing_uri > 0 {
    violations.push(
      "\{missing_uri} resources require embedded or external resolution",
    )
  }
  {
    passed: violations.length() == 0,
    violations,
    external_overage,
    byte_overage,
    unsafe_count: manifest.unsafe_count,
    unsupported_extension_count: unsupported,
    missing_uri_count: missing_uri,
  }
}

///|
pub fn resource_package_destination(
  root : String,
  resource : ResourceRecord,
) -> String {
  let filename = match resource.normalized_uri {
    Some(uri) => uri
    None => "\{resource_kind_name(resource.kind)}/\{resource.index}"
  }
  "\{root}/\{filename}"
}

///|
pub fn package_plan(
  manifest : ResourceManifest,
  destination_root : String,
) -> PackagePlan {
  let entries : Array[PackageEntry] = []
  let destinations : Map[String, Int] = Map([])
  let mut deduplicated = 0
  let mut unsafe_entries = 0
  for resource in manifest.resources {
    let destination = resource_package_destination(destination_root, resource)
    let is_duplicate = destinations.contains(destination)
    if is_duplicate {
      deduplicated += 1
    } else {
      destinations[destination] = resource.index
    }
    if !resource.safe {
      unsafe_entries += 1
    }
    entries.push({
      source_id: resource.id,
      destination,
      kind: resource.kind,
      uri: resource.uri,
      deduplicated: is_duplicate,
      safe: resource.safe,
      issues: resource.issues,
    })
  }
  {
    entries,
    destination_root,
    total_entries: manifest.resources.length(),
    deduplicated_entries: deduplicated,
    unsafe_entries,
    valid: unsafe_entries == 0,
  }
}

///|
pub fn package_plan_valid(plan : PackagePlan) -> Bool {
  plan.valid && plan.unsafe_entries == 0
}

///|
pub fn package_plan_unique_destinations(plan : PackagePlan) -> Array[String] {
  let result : Array[String] = []
  for entry in plan.entries {
    if !result.contains(entry.destination) {
      result.push(entry.destination)
    }
  }
  result
}

///|
pub fn resource_manifest_summary_lines(
  manifest : ResourceManifest,
) -> Array[String] {
  [
    "resources=\{manifest.resources.length()}, buffers=\{resource_manifest_buffer_count(manifest)}, images=\{resource_manifest_image_count(manifest)}",
    "external=\{manifest.external_count}, embedded=\{manifest.embedded_count}, unsafe=\{manifest.unsafe_count}",
    "declared_bytes=\{manifest.declared_bytes}, referenced_bytes=\{manifest.referenced_bytes}",
    "duplicates=\{manifest.duplicate_uri_count}, fingerprint=\{manifest.fingerprint}",
  ]
}
