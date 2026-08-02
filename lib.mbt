///|
pub using @gltf {
  type GltfDocument,
  parse_gltf_string,
  validate_document,
  traverse_node_tree,
  collect_resource_deps,
  unpack_glb,
  bytes_to_utf8_string,
  analyze_optimization,
}
