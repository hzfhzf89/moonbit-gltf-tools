///|
/// 资产优化报告
pub(all) struct OptimizationReport {
  total_vertices : Int
  draw_calls : Int
  unused_materials : Array[Int]
  unused_textures : Array[Int]
  unused_images : Array[Int]
  suggestions : Array[String]
} derive(Debug, ToJson, Eq)

///|
/// 对 glTF 模型进行深度分析，找出低效配置和冗余资源，并输出优化建议报告
///
/// # Example
/// ```mbt check
/// test "analyzer test" {
///   let doc = @gltf.GltfDocument::{
///     version: "2.0",
///     generator: None,
///     copyright: None,
///     scenes: [{ name: Some("Scene"), nodes: [0] }],
///     nodes: [
///       {
///         name: Some("Root"),
///         children: [],
///         mesh: Some(0),
///         skin: None,
///         camera: None,
///         translation: None,
///         rotation: None,
///         scale: None,
///       },
///     ],
///     meshes: [
///       {
///         name: Some("Mesh"),
///         primitives: [
///           {
///             attributes: { "POSITION": 0 },
///             indices: None,
///             material: Some(0),
///             mode: Triangles,
///           },
///         ],
///       },
///     ],
///     materials: [
///       {
///         name: Some("UsedMaterial"),
///         pbr_metallic_roughness: {
///           base_color_factor: { r: 1.0, g: 1.0, b: 1.0, a: 1.0 },
///           base_color_texture: None,
///           metallic_factor: 1.0,
///           roughness_factor: 1.0,
///           metallic_roughness_texture: None,
///         },
///         normal_texture: None,
///         occlusion_texture: None,
///         emissive_texture: None,
///         emissive_factor: { x: 0.0, y: 0.0, z: 0.0 },
///         alpha_mode: Opaque,
///         alpha_cutoff: 0.5,
///         double_sided: false,
///       },
///       {
///         name: Some("UnusedMaterial"),
///         pbr_metallic_roughness: {
///           base_color_factor: { r: 1.0, g: 1.0, b: 1.0, a: 1.0 },
///           base_color_texture: None,
///           metallic_factor: 1.0,
///           roughness_factor: 1.0,
///           metallic_roughness_texture: None,
///         },
///         normal_texture: None,
///         occlusion_texture: None,
///         emissive_texture: None,
///         emissive_factor: { x: 0.0, y: 0.0, z: 0.0 },
///         alpha_mode: Opaque,
///         alpha_cutoff: 0.5,
///         double_sided: false,
///       },
///     ],
///     textures: [],
///     images: [],
///     samplers: [],
///     accessors: [
///       {
///         name: None,
///         buffer_view: None,
///         byte_offset: 0,
///         component_type: Float,
///         normalized: false,
///         count: 100, // 100个顶点
///         accessor_type: Vec3,
///         max_values: [],
///         min_values: [],
///       },
///     ],
///     buffer_views: [],
///     buffers: [],
///     animations: [],
///     skins: [],
///     default_scene: Some(0),
///   }
///   let report = @gltf.analyze_optimization(doc)
///   inspect(report.total_vertices, content="100")
///   inspect(report.draw_calls, content="1")
///   debug_inspect(report.unused_materials, content="[1]")
/// }
/// ```
pub fn analyze_optimization(doc : GltfDocument) -> OptimizationReport {
  let suggestions : Array[String] = []

  // 1. 统计顶点和 Draw Calls (Primitives 数量)
  let mut total_vertices = 0
  let mut draw_calls = 0
  let used_materials_map : Map[Int, Bool] = Map([])
  let used_textures_map : Map[Int, Bool] = Map([])

  for mesh in doc.meshes {
    for prim in mesh.primitives {
      draw_calls += 1
      match prim.material {
        Some(mat_idx) => {
          used_materials_map[mat_idx] = true
          // 标记该材质引用的纹理
          if mat_idx >= 0 && mat_idx < doc.materials.length() {
            let mat = doc.materials[mat_idx]
            match mat.pbr_metallic_roughness.base_color_texture {
              Some(tex) => used_textures_map[tex.index] = true
              None => ()
            }
            match mat.normal_texture {
              Some(tex) => used_textures_map[tex.index] = true
              None => ()
            }
            match mat.occlusion_texture {
              Some(tex) => used_textures_map[tex.index] = true
              None => ()
            }
            match mat.emissive_texture {
              Some(tex) => used_textures_map[tex.index] = true
              None => ()
            }
          }
        }
        None => ()
      }

      // 获取顶点总数
      match prim.attributes.get("POSITION") {
        Some(acc_idx) =>
          if acc_idx >= 0 && acc_idx < doc.accessors.length() {
            total_vertices += doc.accessors[acc_idx].count
          }
        None => ()
      }
    }
  }

  // 2. 统计未使用的材质
  let unused_materials : Array[Int] = []
  for i in 0..<doc.materials.length() {
    if !used_materials_map.contains(i) {
      unused_materials.push(i)
    }
  }
  if unused_materials.length() > 0 {
    suggestions.push(
      "Found \{unused_materials.length()} unused materials. Consider removing them to reduce file size.",
    )
  }

  // 3. 统计未使用的纹理与图像
  let used_images_map : Map[Int, Bool] = Map([])
  let unused_textures : Array[Int] = []
  for i in 0..<doc.textures.length() {
    if used_textures_map.contains(i) {
      match doc.textures[i].source {
        Some(img_idx) => used_images_map[img_idx] = true
        None => ()
      }
    } else {
      unused_textures.push(i)
    }
  }
  if unused_textures.length() > 0 {
    suggestions.push(
      "Found \{unused_textures.length()} unused textures. Consider purging them from the file.",
    )
  }

  let unused_images : Array[Int] = []
  for i in 0..<doc.images.length() {
    if !used_images_map.contains(i) {
      unused_images.push(i)
    }
  }
  if unused_images.length() > 0 {
    suggestions.push(
      "Found \{unused_images.length()} unused images/textures. Cleaning them will save memory.",
    )
  }

  // 4. 分析 Draw Calls 带来的性能隐患
  if draw_calls > 50 {
    suggestions.push(
      "Model has a high number of draw calls (\{draw_calls}). Try merging meshes or using texture atlases.",
    )
  }

  // 5. 校验网格是否使用了索引缓冲区 (Index buffer)
  let mut unindexed_prims = 0
  for mesh in doc.meshes {
    for prim in mesh.primitives {
      if prim.indices is None {
        unindexed_prims += 1
      }
    }
  }
  if unindexed_prims > 0 {
    suggestions.push(
      "Found \{unindexed_prims} unindexed primitive(s). Using index buffers is highly recommended to improve rendering performance.",
    )
  }

  {
    total_vertices,
    draw_calls,
    unused_materials,
    unused_textures,
    unused_images,
    suggestions,
  }
}
