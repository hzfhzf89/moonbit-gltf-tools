///|
fn main {
  let args = @env.args()
  if args.length() < 2 {
    println("Usage: moon run cmd/main <file.gltf | file.glb>")
    return
  }
  let filepath = args[1]
  println("Loading file: \{filepath}")

  let is_glb = filepath.to_lower().has_suffix(".glb")

  // 读取文件内容
  let file_bytes = @fs.read_file_to_bytes(filepath) catch {
    err => {
      println("Failed to read file: \{err}")
      return
    }
  }

  // 解析并提取数据
  let doc = if is_glb {
    try {
      let unpacked = @gltf.unpack_glb(file_bytes)
      println("GLB Container unpacked successfully.")
      @gltf.parse_gltf_string(unpacked.json_str)
    } catch {
      err => {
        println("Error unpacking/parsing GLB: \{err}")
        return
      }
    }
  } else {
    try {
      let content = @gltf.bytes_to_utf8_string(file_bytes)
      @gltf.parse_gltf_string(content)
    } catch {
      err => {
        println("Error parsing glTF JSON: \{err}")
        return
      }
    }
  }

  // 1. 验证报告
  println("\n--- 1. Validation Report ---")
  let val_report = @gltf.validate_document(doc)
  if val_report.is_valid {
    println("[SUCCESS] The model structure is valid.")
  } else {
    println("[WARNING/ERROR] Model structure contains validation errors:")
    for err in val_report.errors {
      println("  - [Error] \{err.path}: \{err.message}")
    }
  }

  // 2. 节点树分析
  println("\n--- 2. Node Tree analysis ---")
  let tree_info = @gltf.traverse_node_tree(doc)
  println("Total nodes: \{tree_info.total_nodes}")
  println("Max depth: \{tree_info.max_depth}")
  println("Mesh nodes: \{tree_info.mesh_node_count}")
  println("Skinned nodes: \{tree_info.skinned_node_count}")
  println("Root nodes index: \{to_repr(tree_info.root_nodes)}")

  // 3. 元数据提取 (Mesh & Animation)
  println("\n--- 3. Mesh & Animation Metadata ---")
  let meshes_meta = @gltf.extract_mesh_metadata(doc)
  println("Meshes (count: \{meshes_meta.length()}):")
  for i, meta in meshes_meta {
    let name = match meta.name {
      Some(n) => n
      None => "<unnamed>"
    }
    println(
      "  - Mesh \{i} [\{name}]: Vertex count: \{meta.vertex_count}, Primitives: \{meta.primitive_count}, Indexed: \{meta.has_indices}, Attributes: \{to_repr(meta.attributes)}",
    )
  }
  let anims_meta = @gltf.extract_animation_metadata(doc)
  println("Animations (count: \{anims_meta.length()}):")
  for i, meta in anims_meta {
    let name = match meta.name {
      Some(n) => n
      None => "<unnamed>"
    }
    println(
      "  - Anim \{i} [\{name}]: Channels: \{meta.channel_count}, Targets: \{to_repr(meta.target_nodes)}, Interpolation: \{to_repr(meta.interpolations)}",
    )
  }

  // 4. 资源依赖
  println("\n--- 4. Resource Dependencies ---")
  let deps = @gltf.collect_resource_deps(doc)
  println("Total buffer bytes: \{deps.total_buffer_bytes}")
  println("Embedded buffers: \{deps.embedded_buffer_count}")
  println("Embedded images: \{deps.embedded_image_count}")
  println("External URI references (count: \{deps.external_uris.length()}):")
  for uri in deps.external_uris {
    println("  - \{uri}")
  }

  // 5. 优化分析
  println("\n--- 5. Optimization Report & Suggestions ---")
  let opt_report = @gltf.analyze_optimization(doc)
  println("Total Vertices: \{opt_report.total_vertices}")
  println("Draw Calls (Primitives): \{opt_report.draw_calls}")
  if opt_report.suggestions.length() == 0 {
    println("No optimization suggestion. Model is clean and efficient!")
  } else {
    println("Suggestions:")
    for suggestion in opt_report.suggestions {
      println("  - [Suggestion] \{suggestion}")
    }
  }
}
