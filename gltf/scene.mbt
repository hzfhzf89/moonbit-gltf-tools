///|
/// 场景图节点树遍历结果
pub(all) struct NodeTreeInfo {
  /// 节点总数
  total_nodes : Int
  /// 最大深度
  max_depth : Int
  /// 含网格的节点数
  mesh_node_count : Int
  /// 含蒙皮的节点数
  skinned_node_count : Int
  /// 根节点索引列表
  root_nodes : Array[Int]
  /// 各节点深度映射（节点索引 -> 深度）
  node_depths : Map[Int, Int]
} derive(Debug, ToJson)

///|
/// 遍历 glTF 场景图，收集节点树信息
///
/// # Example
/// ```mbt check
/// test "node tree basic" {
///   let doc = @gltf.GltfDocument::{
///     version: "2.0",
///     generator: None,
///     copyright: None,
///     scenes: [{ name: Some("Scene"), nodes: [0] }],
///     nodes: [
///       {
///         name: Some("Root"),
///         children: [1],
///         mesh: None,
///         skin: None,
///         camera: None,
///         translation: None,
///         rotation: None,
///         scale: None,
///       },
///       {
///         name: Some("Child"),
///         children: [],
///         mesh: Some(0),
///         skin: None,
///         camera: None,
///         translation: None,
///         rotation: None,
///         scale: None,
///       },
///     ],
///     meshes: [],
///     materials: [],
///     textures: [],
///     images: [],
///     samplers: [],
///     accessors: [],
///     buffer_views: [],
///     buffers: [],
///     animations: [],
///     skins: [],
///     default_scene: Some(0),
///   }
///   let info = @gltf.traverse_node_tree(doc)
///   inspect(info.total_nodes, content="2")
///   inspect(info.max_depth, content="2")
///   inspect(info.mesh_node_count, content="1")
/// }
/// ```
pub fn traverse_node_tree(doc : GltfDocument) -> NodeTreeInfo {
  let node_depths : Map[Int, Int] = {}
  let visited : Map[Int, Bool] = {}
  let mut max_depth = 0
  let mut mesh_node_count = 0
  let mut skinned_node_count = 0
  // DFS 遍历
  fn dfs(idx : Int, depth : Int) {
    if visited.contains(idx) {
      return
    }
    visited[idx] = true
    node_depths[idx] = depth
    if depth > max_depth {
      max_depth = depth
    }
    if idx >= 0 && idx < doc.nodes.length() {
      let node = doc.nodes[idx]
      if node.mesh is Some(_) {
        mesh_node_count += 1
      }
      if node.skin is Some(_) {
        skinned_node_count += 1
      }
      for child_idx in node.children {
        dfs(child_idx, depth + 1)
      }
    }
  }

  // 收集根节点（场景中直接引用的节点）
  let root_nodes : Array[Int] = []
  for scene in doc.scenes {
    for node_idx in scene.nodes {
      if !root_nodes.contains(node_idx) {
        root_nodes.push(node_idx)
      }
    }
  }
  // 从根节点开始遍历
  for root_idx in root_nodes {
    dfs(root_idx, 1)
  }
  // 检查孤立节点（未被任何场景引用）
  for i in 0..<doc.nodes.length() {
    if !visited.contains(i) {
      node_depths[i] = 0
    }
  }
  {
    total_nodes: doc.nodes.length(),
    max_depth,
    mesh_node_count,
    skinned_node_count,
    root_nodes,
    node_depths,
  }
}

///|
/// 收集文档中所有资源依赖关系
pub(all) struct ResourceDeps {
  /// 外部 URI 引用列表（图像、缓冲区等）
  external_uris : Array[String]
  /// 内嵌 GLB 数据块数量
  embedded_buffer_count : Int
  /// 内嵌 base64 图像数量
  embedded_image_count : Int
  /// 总缓冲区字节数
  total_buffer_bytes : Int
  /// 纹理引用的图像索引列表
  texture_image_refs : Array[Int]
} derive(Debug, ToJson)

///|
/// 分析 glTF 文档的资源依赖
pub fn collect_resource_deps(doc : GltfDocument) -> ResourceDeps {
  let external_uris : Array[String] = []
  let mut embedded_buffer_count = 0
  let mut embedded_image_count = 0
  let mut total_buffer_bytes = 0
  // 检查缓冲区
  for buf in doc.buffers {
    total_buffer_bytes += buf.byte_length
    match buf.uri {
      Some(uri) =>
        if uri.has_prefix("data:") {
          embedded_buffer_count += 1
        } else {
          external_uris.push(uri)
        }
      None => embedded_buffer_count += 1
    }
  }
  // 检查图像
  for img in doc.images {
    match img.uri {
      Some(uri) =>
        if uri.has_prefix("data:") {
          embedded_image_count += 1
        } else {
          external_uris.push(uri)
        }
      None => embedded_image_count += 1
    }
  }
  // 收集纹理引用的图像索引
  let texture_image_refs : Array[Int] = []
  for tex in doc.textures {
    match tex.source {
      Some(idx) => texture_image_refs.push(idx)
      None => ()
    }
  }
  {
    external_uris,
    embedded_buffer_count,
    embedded_image_count,
    total_buffer_bytes,
    texture_image_refs,
  }
}

///|
/// 网格元数据摘要
pub(all) struct MeshMetadata {
  /// 网格名称
  name : String?
  /// 图元数量
  primitive_count : Int
  /// 顶点属性集合（如 POSITION、NORMAL）
  attributes : Array[String]
  /// 使用的材质索引列表
  material_indices : Array[Int]
  /// 是否含索引数据
  has_indices : Bool
  /// 顶点总数（所有图元 POSITION accessor count 之和）
  vertex_count : Int
} derive(Debug, ToJson)

///|
/// 提取所有网格的元数据
pub fn extract_mesh_metadata(doc : GltfDocument) -> Array[MeshMetadata] {
  doc.meshes.map(mesh => {
    let mut primitive_count = 0
    let attrs_set : Map[String, Bool] = {}
    let material_indices : Array[Int] = []
    let mut has_indices = false
    let mut vertex_count = 0
    for prim in mesh.primitives {
      primitive_count += 1
      for attr, acc_idx in prim.attributes {
        attrs_set[attr] = true
        // 累加 POSITION 顶点数
        if attr == "POSITION" && acc_idx < doc.accessors.length() {
          vertex_count += doc.accessors[acc_idx].count
        }
      }
      match prim.material {
        Some(idx) =>
          if !material_indices.contains(idx) {
            material_indices.push(idx)
          }
        None => ()
      }
      if prim.indices is Some(_) {
        has_indices = true
      }
    }
    let attributes = attrs_set.keys().collect()
    {
      name: mesh.name,
      primitive_count,
      attributes,
      material_indices,
      has_indices,
      vertex_count,
    }
  })
}

///|
/// 动画元数据摘要
pub(all) struct AnimationMetadata {
  /// 动画名称
  name : String?
  /// 通道数量
  channel_count : Int
  /// 驱动的节点索引列表
  target_nodes : Array[Int]
  /// 驱动的属性集合
  target_paths : Array[String]
  /// 使用的插值方式列表
  interpolations : Array[String]
} derive(Debug, ToJson)

///|
/// 提取所有动画的元数据
pub fn extract_animation_metadata(
  doc : GltfDocument,
) -> Array[AnimationMetadata] {
  doc.animations.map(anim => {
    let target_nodes : Array[Int] = []
    let paths_set : Map[String, Bool] = {}
    let interp_set : Map[String, Bool] = {}
    for ch in anim.channels {
      match ch.target.node {
        Some(n) => if !target_nodes.contains(n) { target_nodes.push(n) }
        None => ()
      }
      let path_str = match ch.target.path {
        Translation => "translation"
        Rotation => "rotation"
        Scale => "scale"
        Weights => "weights"
      }
      paths_set[path_str] = true
    }
    for s in anim.samplers {
      let interp_str = match s.interpolation {
        Linear => "LINEAR"
        Step => "STEP"
        CubicSpline => "CUBICSPLINE"
      }
      interp_set[interp_str] = true
    }
    {
      name: anim.name,
      channel_count: anim.channels.length(),
      target_nodes,
      target_paths: paths_set.keys().collect(),
      interpolations: interp_set.keys().collect(),
    }
  })
}
