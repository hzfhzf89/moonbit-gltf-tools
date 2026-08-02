///|
test "validation with cyclic node tree" {
  let doc = @gltf.GltfDocument::{
    version: "2.0",
    generator: None,
    copyright: None,
    scenes: [{ name: Some("Scene"), nodes: [0] }],
    nodes: [
      {
        name: Some("Node0"),
        children: [0], // 环路
        mesh: None,
        skin: None,
        camera: None,
        translation: None,
        rotation: None,
        scale: None,
      },
    ],
    meshes: [],
    materials: [],
    textures: [],
    images: [],
    samplers: [],
    accessors: [],
    buffer_views: [],
    buffers: [],
    animations: [],
    skins: [],
    default_scene: Some(0),
  }
  let report = @gltf.validate_document(doc)
  debug_inspect(report.is_valid, content="false")
  debug_inspect(report.errors.length(), content="1")
  debug_inspect(
    report.errors[0].message,
    content="\"Self-referencing node cycle detected\"",
  )
}

///|
test "validation with out of bounds mesh reference" {
  let doc = @gltf.GltfDocument::{
    version: "2.0",
    generator: None,
    copyright: None,
    scenes: [],
    nodes: [
      {
        name: Some("Node0"),
        children: [],
        mesh: Some(5), // 无效网格索引
        skin: None,
        camera: None,
        translation: None,
        rotation: None,
        scale: None,
      },
    ],
    meshes: [],
    materials: [],
    textures: [],
    images: [],
    samplers: [],
    accessors: [],
    buffer_views: [],
    buffers: [],
    animations: [],
    skins: [],
    default_scene: None,
  }
  let report = @gltf.validate_document(doc)
  debug_inspect(report.is_valid, content="false")
  debug_inspect(report.errors.length(), content="1")
  debug_inspect(report.errors[0].path, content="\"nodes[0].mesh\"")
}

///|
test "resource dependency checking" {
  let doc = @gltf.GltfDocument::{
    version: "2.0",
    generator: None,
    copyright: None,
    scenes: [],
    nodes: [],
    meshes: [],
    materials: [],
    textures: [{ name: None, sampler: None, source: Some(0) }],
    images: [
      {
        name: Some("external"),
        uri: Some("textures/brick.png"),
        mime_type: None,
        buffer_view: None,
      },
      {
        name: Some("embedded"),
        uri: Some("data:image/png;base64,iVBORw0KGgoAAAANS"),
        mime_type: None,
        buffer_view: None,
      },
    ],
    samplers: [],
    accessors: [],
    buffer_views: [],
    buffers: [
      {
        name: None,
        byte_length: 1024,
        uri: Some("data:application/octet-stream;base64,AAA"),
      },
    ],
    animations: [],
    skins: [],
    default_scene: None,
  }
  let deps = @gltf.collect_resource_deps(doc)
  debug_inspect(deps.external_uris, content="[\"textures/brick.png\"]")
  debug_inspect(deps.embedded_image_count, content="1")
  debug_inspect(deps.embedded_buffer_count, content="1")
  debug_inspect(deps.total_buffer_bytes, content="1024")
}

///|
test "optimization analyzer suggestions" {
  let doc = @gltf.GltfDocument::{
    version: "2.0",
    generator: None,
    copyright: None,
    scenes: [],
    nodes: [],
    meshes: [
      {
        name: Some("Mesh"),
        primitives: [
          {
            attributes: { "POSITION": 0 },
            indices: None, // 未使用索引缓冲区
            material: None,
            mode: Triangles,
          },
        ],
      },
    ],
    materials: [],
    textures: [],
    images: [],
    samplers: [],
    accessors: [
      {
        name: None,
        buffer_view: None,
        byte_offset: 0,
        component_type: Float,
        normalized: false,
        count: 50,
        accessor_type: Vec3,
        max_values: [],
        min_values: [],
      },
    ],
    buffer_views: [],
    buffers: [],
    animations: [],
    skins: [],
    default_scene: None,
  }
  let report = @gltf.analyze_optimization(doc)
  debug_inspect(report.draw_calls, content="1")
  debug_inspect(report.total_vertices, content="50")
  debug_inspect(
    report.suggestions[0],
    content="\"Found 1 unindexed primitive(s). Using index buffers is highly recommended to improve rendering performance.\"",
  )
}
