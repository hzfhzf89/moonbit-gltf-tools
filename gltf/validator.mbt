///|
/// 校验错误类型
pub(all) struct ValidationError {
  /// 校验规则路径（例如 "scenes[0].nodes[2]"）
  path : String
  /// 错误详细说明
  message : String
} derive(Debug, ToJson, Eq)

///|
/// 校验报告
pub(all) struct ValidationReport {
  is_valid : Bool
  errors : Array[ValidationError]
  warnings : Array[ValidationError]
} derive(Debug, ToJson, Eq)

///|
/// 校验 glTF 文档完整性与规范合规性
///
/// # Example
/// ```mbt check
/// test "validation invalid node index" {
///   let doc = @gltf.GltfDocument::{
///     version: "2.0",
///     generator: None,
///     copyright: None,
///     scenes: [{ name: Some("Scene"), nodes: [99] }], // 99 是无效的 node 索引
///     nodes: [
///       {
///         name: Some("Root"),
///         children: [],
///         mesh: None,
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
///   let report = @gltf.validate_document(doc)
///   inspect(report.is_valid, content="false")
///   inspect(report.errors.length(), content="1")
/// }
/// ```
pub fn validate_document(doc : GltfDocument) -> ValidationReport {
  let errors : Array[ValidationError] = []
  let warnings : Array[ValidationError] = []

  // 1. 验证基础元数据
  if doc.version != "2.0" {
    errors.push({
      path: "asset.version",
      message: "Unsupported glTF version: \{doc.version}. Only 2.0 is supported.",
    })
  }

  // 2. 验证场景引用
  for s_idx, scene in doc.scenes {
    for n_idx, node_idx in scene.nodes {
      if node_idx < 0 || node_idx >= doc.nodes.length() {
        errors.push({
          path: "scenes[\{s_idx}].nodes[\{n_idx}]",
          message: "Node index \{node_idx} is out of bounds (total nodes: \{doc.nodes.length()})",
        })
      }
    }
  }

  // 3. 验证节点层次结构
  for n_idx, node in doc.nodes {
    for c_idx, child_idx in node.children {
      if child_idx < 0 || child_idx >= doc.nodes.length() {
        errors.push({
          path: "nodes[\{n_idx}].children[\{c_idx}]",
          message: "Child node index \{child_idx} is out of bounds",
        })
      }
      if child_idx == n_idx {
        errors.push({
          path: "nodes[\{n_idx}].children[\{c_idx}]",
          message: "Self-referencing node cycle detected",
        })
      }
    }
    match node.mesh {
      Some(mesh_idx) =>
        if mesh_idx < 0 || mesh_idx >= doc.meshes.length() {
          errors.push({
            path: "nodes[\{n_idx}].mesh",
            message: "Mesh index \{mesh_idx} is out of bounds (total meshes: \{doc.meshes.length()})",
          })
        }
      None => ()
    }
  }

  // 4. 验证网格与材质引用
  for m_idx, mesh in doc.meshes {
    for p_idx, prim in mesh.primitives {
      match prim.indices {
        Some(acc_idx) =>
          if acc_idx < 0 || acc_idx >= doc.accessors.length() {
            errors.push({
              path: "meshes[\{m_idx}].primitives[\{p_idx}].indices",
              message: "Accessor index \{acc_idx} is out of bounds",
            })
          }
        None => ()
      }
      match prim.material {
        Some(mat_idx) =>
          if mat_idx < 0 || mat_idx >= doc.materials.length() {
            errors.push({
              path: "meshes[\{m_idx}].primitives[\{p_idx}].material",
              message: "Material index \{mat_idx} is out of bounds",
            })
          }
        None => ()
      }
      for attr_name, acc_idx in prim.attributes {
        if acc_idx < 0 || acc_idx >= doc.accessors.length() {
          errors.push({
            path: "meshes[\{m_idx}].primitives[\{p_idx}].attributes['\{attr_name}']",
            message: "Accessor index \{acc_idx} is out of bounds",
          })
        }
      }
    }
  }

  // 5. 验证材质引用的纹理
  for mat_idx, mat in doc.materials {
    match mat.pbr_metallic_roughness.base_color_texture {
      Some(tex_info) =>
        if tex_info.index < 0 || tex_info.index >= doc.textures.length() {
          errors.push({
            path: "materials[\{mat_idx}].pbrMetallicRoughness.baseColorTexture.index",
            message: "Texture index \{tex_info.index} is out of bounds",
          })
        }
      None => ()
    }
    match mat.normal_texture {
      Some(tex_info) =>
        if tex_info.index < 0 || tex_info.index >= doc.textures.length() {
          errors.push({
            path: "materials[\{mat_idx}].normalTexture.index",
            message: "Texture index \{tex_info.index} is out of bounds",
          })
        }
      None => ()
    }
  }

  // 6. 验证纹理、图像、采样器
  for tex_idx, tex in doc.textures {
    match tex.sampler {
      Some(sam_idx) =>
        if sam_idx < 0 || sam_idx >= doc.samplers.length() {
          errors.push({
            path: "textures[\{tex_idx}].sampler",
            message: "Sampler index \{sam_idx} is out of bounds",
          })
        }
      None => ()
    }
    match tex.source {
      Some(img_idx) =>
        if img_idx < 0 || img_idx >= doc.images.length() {
          errors.push({
            path: "textures[\{tex_idx}].source",
            message: "Image index \{img_idx} is out of bounds",
          })
        }
      None => ()
    }
  }

  // 7. 验证访问器与缓冲视口
  for acc_idx, acc in doc.accessors {
    match acc.buffer_view {
      Some(view_idx) =>
        if view_idx < 0 || view_idx >= doc.buffer_views.length() {
          errors.push({
            path: "accessors[\{acc_idx}].bufferView",
            message: "BufferView index \{view_idx} is out of bounds",
          })
        }
      None => ()
    }
  }

  for view_idx, view in doc.buffer_views {
    if view.buffer < 0 || view.buffer >= doc.buffers.length() {
      errors.push({
        path: "bufferViews[\{view_idx}].buffer",
        message: "Buffer index \{view.buffer} is out of bounds",
      })
    }
  }

  { is_valid: errors.length() == 0, errors, warnings }
}
