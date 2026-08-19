///|
/// Stable, machine-readable asset report assembled from the independent
/// analyzers. Consumers can use this as a CI artifact without understanding
/// each internal pass.

///|
pub(all) struct AssetCounts {
  scenes : Int
  nodes : Int
  meshes : Int
  primitives : Int
  materials : Int
  textures : Int
  images : Int
  buffers : Int
  buffer_views : Int
  accessors : Int
  animations : Int
  skins : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GeometryReport {
  vertices : Int
  triangles : Int
  draw_calls : Int
  indexed_primitives : Int
  unindexed_primitives : Int
  transformed_nodes : Int
  indexed_ratio : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ResourceReport {
  declared_buffer_bytes : Int
  view_bytes : Int
  external_uri_count : Int
  embedded_buffer_count : Int
  embedded_image_count : Int
  interleaved_view_count : Int
  sparse_like_accessor_count : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AssetReport {
  version : String
  generator : String?
  counts : AssetCounts
  geometry : GeometryReport
  resources : ResourceReport
  scene : NodeTreeInfo
  transforms : TransformReport
  diagnostics : DiagnosticSummary
} derive(Debug, ToJson, Eq)

///|
pub fn count_document(doc : GltfDocument) -> AssetCounts {
  let mut primitives = 0
  for mesh in doc.meshes {
    primitives += mesh.primitives.length()
  }
  {
    scenes: doc.scenes.length(),
    nodes: doc.nodes.length(),
    meshes: doc.meshes.length(),
    primitives,
    materials: doc.materials.length(),
    textures: doc.textures.length(),
    images: doc.images.length(),
    buffers: doc.buffers.length(),
    buffer_views: doc.buffer_views.length(),
    accessors: doc.accessors.length(),
    animations: doc.animations.length(),
    skins: doc.skins.length(),
  }
}

///|
pub fn report_geometry(doc : GltfDocument) -> GeometryReport {
  let mut vertices = 0
  let mut draw_calls = 0
  let mut triangles = 0
  let mut indexed_primitives = 0
  let mut unindexed_primitives = 0
  for mesh in doc.meshes {
    for primitive in mesh.primitives {
      draw_calls += 1
      vertices += primitive_vertex_count(doc, primitive)
      triangles += primitive_estimated_triangle_count(doc, primitive)
      if primitive_is_indexed(primitive) {
        indexed_primitives += 1
      } else {
        unindexed_primitives += 1
      }
    }
  }
  {
    vertices,
    triangles,
    draw_calls,
    indexed_primitives,
    unindexed_primitives,
    transformed_nodes: count_transformed_nodes(doc),
    indexed_ratio: document_indexed_primitive_ratio(doc),
  }
}

///|
pub fn report_resources(doc : GltfDocument) -> ResourceReport {
  let deps = collect_resource_deps(doc)
  {
    declared_buffer_bytes: buffer_total_declared_bytes(doc),
    view_bytes: buffer_total_view_bytes(doc),
    external_uri_count: deps.external_uris.length(),
    embedded_buffer_count: deps.embedded_buffer_count,
    embedded_image_count: deps.embedded_image_count,
    interleaved_view_count: count_interleaved_views(doc),
    sparse_like_accessor_count: count_sparse_like_accessors(doc),
  }
}

///|
pub fn build_asset_report(
  doc : GltfDocument,
  policy : DiagnosticPolicy,
) -> AssetReport {
  {
    version: doc.version,
    generator: doc.generator,
    counts: count_document(doc),
    geometry: report_geometry(doc),
    resources: report_resources(doc),
    scene: traverse_node_tree(doc),
    transforms: evaluate_scene_transforms(doc),
    diagnostics: diagnose(doc, policy),
  }
}

///|
pub fn build_default_asset_report(doc : GltfDocument) -> AssetReport {
  build_asset_report(doc, default_diagnostic_policy())
}

///|
pub fn report_has_errors(report : AssetReport) -> Bool {
  report.diagnostics.errors > 0
}

///|
pub fn report_is_acceptable(report : AssetReport) -> Bool {
  report.diagnostics.passed
}

///|
pub fn report_summary_lines(report : AssetReport) -> Array[String] {
  [
    "glTF version: \{report.version}",
    "nodes=\{report.counts.nodes}, meshes=\{report.counts.meshes}, primitives=\{report.counts.primitives}",
    "vertices=\{report.geometry.vertices}, triangles=\{report.geometry.triangles}, draw_calls=\{report.geometry.draw_calls}",
    "buffers=\{report.counts.buffers}, declared_bytes=\{report.resources.declared_buffer_bytes}",
    "diagnostics: errors=\{report.diagnostics.errors}, warnings=\{report.diagnostics.warnings}, infos=\{report.diagnostics.infos}",
  ]
}

///|
pub fn report_to_json(report : AssetReport) -> String {
  Repr(report).to_string()
}
