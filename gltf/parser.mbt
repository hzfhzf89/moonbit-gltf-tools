///|
/// 将 JSON 对象解析为完整 GltfDocument
///
/// # Example
/// ```mbt check
/// test "parse minimal gltf" {
///   let json_str =
///     #|{"asset":{"version":"2.0"},"scenes":[],"nodes":[],"meshes":[],
///     #|"materials":[],"textures":[],"images":[],"samplers":[],
///     #|"accessors":[],"bufferViews":[],"buffers":[],"animations":[],"skins":[]}
///   let doc = @gltf.parse_gltf_string(json_str)
///   inspect(doc.version, content="2.0")
/// }
/// ```
pub fn parse_gltf_string(json_str : String) -> GltfDocument raise ParseError {
  let json = @json.parse(json_str) catch {
    err => raise ParseError::InvalidJson(msg="\{err}")
  }
  match json {
    Json::Object(root) => parse_gltf_object(root)
    _ => raise ParseError::InvalidJson(msg="root must be a JSON object")
  }
}

///|
/// 从 JSON 根对象解析 GltfDocument
pub fn parse_gltf_object(
  root : Map[String, Json],
) -> GltfDocument raise ParseError {
  // asset 对象
  let version = match root.get("asset") {
    Some(Json::Object(asset)) => get_string(asset, "version")
    Some(_) =>
      raise ParseError::InvalidFieldType(field="asset", expected="object")
    None => raise ParseError::MissingField(field="asset")
  }
  let generator = match root.get("asset") {
    Some(Json::Object(asset)) => get_string_opt(asset, "generator")
    _ => None
  }
  let copyright = match root.get("asset") {
    Some(Json::Object(asset)) => get_string_opt(asset, "copyright")
    _ => None
  }
  let default_scene = get_int_opt(root, "scene")
  let scenes = parse_scenes(root)
  let nodes = parse_nodes(root)
  let meshes = parse_meshes(root)
  let materials = parse_materials(root)
  let textures = parse_textures(root)
  let images = parse_images(root)
  let samplers = parse_samplers(root)
  let accessors = parse_accessors(root)
  let buffer_views = parse_buffer_views(root)
  let buffers = parse_buffers(root)
  let animations = parse_animations(root)
  let skins = parse_skins(root)
  {
    version,
    generator,
    copyright,
    scenes,
    nodes,
    meshes,
    materials,
    textures,
    images,
    samplers,
    accessors,
    buffer_views,
    buffers,
    animations,
    skins,
    default_scene,
  }
}

///|
fn parse_scenes(root : Map[String, Json]) -> Array[GltfScene] raise ParseError {
  let arr = get_obj_array(root, "scenes")
  arr.map(o => {
    let name = get_string_opt(o, "name")
    let nodes = get_int_array(o, "nodes")
    { name, nodes }
  })
}

///|
fn parse_nodes(root : Map[String, Json]) -> Array[GltfNode] raise ParseError {
  let arr = get_obj_array(root, "nodes")
  arr.map(o => {
    let name = get_string_opt(o, "name")
    let children = get_int_array(o, "children")
    let mesh = get_int_opt(o, "mesh")
    let skin = get_int_opt(o, "skin")
    let camera = get_int_opt(o, "camera")
    let translation = match o.get("translation") {
      Some(Json::Array(arr)) => Some(parse_vec3(arr))
      _ => None
    }
    let rotation = match o.get("rotation") {
      Some(Json::Array(arr)) => Some(parse_quat(arr))
      _ => None
    }
    let scale = match o.get("scale") {
      Some(Json::Array(arr)) => Some(parse_vec3(arr))
      _ => None
    }
    { name, children, mesh, skin, camera, translation, rotation, scale }
  })
}

///|
fn parse_meshes(root : Map[String, Json]) -> Array[GltfMesh] raise ParseError {
  let arr = get_obj_array(root, "meshes")
  arr.map(o => {
    let name = get_string_opt(o, "name")
    let prims_raw = get_obj_array(o, "primitives")
    let primitives = prims_raw.map(p => {
      let attrs_raw = match p.get("attributes") {
        Some(Json::Object(a)) => a
        _ => {}
      }
      let attributes : Map[String, Int] = {}
      for k, v in attrs_raw {
        match v {
          Json::Number(n, ..) => attributes[k] = n.to_int()
          _ => ()
        }
      }
      let indices = get_int_opt(p, "indices")
      let material = get_int_opt(p, "material")
      let mode = match get_int_opt(p, "mode") {
        Some(code) => parse_primitive_mode(code)
        None => Triangles
      }
      { attributes, indices, material, mode }
    })
    { name, primitives }
  })
}

///|
fn parse_materials(
  root : Map[String, Json],
) -> Array[GltfMaterial] raise ParseError {
  let arr = get_obj_array(root, "materials")
  arr.map(o => {
    let name = get_string_opt(o, "name")
    let pbr_metallic_roughness = match o.get("pbrMetallicRoughness") {
      Some(Json::Object(pbr)) => parse_pbr(pbr)
      _ =>
        {
          base_color_factor: { r: 1.0, g: 1.0, b: 1.0, a: 1.0 },
          base_color_texture: None,
          metallic_factor: 1.0,
          roughness_factor: 1.0,
          metallic_roughness_texture: None,
        }
    }
    let normal_texture = match o.get("normalTexture") {
      Some(Json::Object(t)) => Some(parse_texture_info(t))
      _ => None
    }
    let occlusion_texture = match o.get("occlusionTexture") {
      Some(Json::Object(t)) => Some(parse_texture_info(t))
      _ => None
    }
    let emissive_texture = match o.get("emissiveTexture") {
      Some(Json::Object(t)) => Some(parse_texture_info(t))
      _ => None
    }
    let emissive_factor = match o.get("emissiveFactor") {
      Some(Json::Array(arr)) => parse_vec3(arr)
      _ => { x: 0.0, y: 0.0, z: 0.0 }
    }
    let alpha_mode = match get_string_opt(o, "alphaMode") {
      Some(s) => parse_alpha_mode(s)
      None => Opaque
    }
    let alpha_cutoff = get_double(o, "alphaCutoff", default=0.5)
    let double_sided = get_bool(o, "doubleSided", default=false)
    {
      name,
      pbr_metallic_roughness,
      normal_texture,
      occlusion_texture,
      emissive_texture,
      emissive_factor,
      alpha_mode,
      alpha_cutoff,
      double_sided,
    }
  })
}

///|
fn parse_textures(
  root : Map[String, Json],
) -> Array[GltfTexture] raise ParseError {
  let arr = get_obj_array(root, "textures")
  arr.map(o => {
    let name = get_string_opt(o, "name")
    let sampler = get_int_opt(o, "sampler")
    let source = get_int_opt(o, "source")
    { name, sampler, source }
  })
}

///|
fn parse_images(root : Map[String, Json]) -> Array[GltfImage] raise ParseError {
  let arr = get_obj_array(root, "images")
  arr.map(o => {
    let name = get_string_opt(o, "name")
    let uri = get_string_opt(o, "uri")
    let mime_type = get_string_opt(o, "mimeType")
    let buffer_view = get_int_opt(o, "bufferView")
    { name, uri, mime_type, buffer_view }
  })
}

///|
fn parse_samplers(
  root : Map[String, Json],
) -> Array[GltfSampler] raise ParseError {
  let arr = get_obj_array(root, "samplers")
  arr.map(o => {
    let name = get_string_opt(o, "name")
    let mag_filter = match get_int_opt(o, "magFilter") {
      Some(code) => Some(parse_filter_mode(code))
      None => None
    }
    let min_filter = match get_int_opt(o, "minFilter") {
      Some(code) => Some(parse_filter_mode(code))
      None => None
    }
    let wrap_s = match get_int_opt(o, "wrapS") {
      Some(code) => parse_wrap_mode(code)
      None => Repeat
    }
    let wrap_t = match get_int_opt(o, "wrapT") {
      Some(code) => parse_wrap_mode(code)
      None => Repeat
    }
    { name, mag_filter, min_filter, wrap_s, wrap_t }
  })
}

///|
fn parse_accessors(
  root : Map[String, Json],
) -> Array[GltfAccessor] raise ParseError {
  let arr = get_obj_array(root, "accessors")
  arr.map(o => {
    let name = get_string_opt(o, "name")
    let buffer_view = get_int_opt(o, "bufferView")
    let byte_offset = match get_int_opt(o, "byteOffset") {
      Some(n) => n
      None => 0
    }
    let component_type = parse_component_type(get_int(o, "componentType"))
    let normalized = get_bool(o, "normalized", default=false)
    let count = get_int(o, "count")
    let accessor_type = parse_accessor_type(get_string(o, "type"))
    let max_values = get_number_array(o, "max")
    let min_values = get_number_array(o, "min")
    {
      name,
      buffer_view,
      byte_offset,
      component_type,
      normalized,
      count,
      accessor_type,
      max_values,
      min_values,
    }
  })
}

///|
fn parse_buffer_views(
  root : Map[String, Json],
) -> Array[GltfBufferView] raise ParseError {
  let arr = get_obj_array(root, "bufferViews")
  arr.map(o => {
    let name = get_string_opt(o, "name")
    let buffer = get_int(o, "buffer")
    let byte_offset = match get_int_opt(o, "byteOffset") {
      Some(n) => n
      None => 0
    }
    let byte_length = get_int(o, "byteLength")
    let target = get_int_opt(o, "target")
    let byte_stride = get_int_opt(o, "byteStride")
    { name, buffer, byte_offset, byte_length, target, byte_stride }
  })
}

///|
fn parse_buffers(
  root : Map[String, Json],
) -> Array[GltfBuffer] raise ParseError {
  let arr = get_obj_array(root, "buffers")
  arr.map(o => {
    let name = get_string_opt(o, "name")
    let byte_length = get_int(o, "byteLength")
    let uri = get_string_opt(o, "uri")
    { name, byte_length, uri }
  })
}

///|
fn parse_animations(
  root : Map[String, Json],
) -> Array[GltfAnimation] raise ParseError {
  let arr = get_obj_array(root, "animations")
  arr.map(o => {
    let name = get_string_opt(o, "name")
    let channels_raw = get_obj_array(o, "channels")
    let channels = channels_raw.map(c => {
      let sampler = get_int(c, "sampler")
      let target = match c.get("target") {
        Some(Json::Object(t)) => {
          let node = get_int_opt(t, "node")
          let path = parse_animation_path(get_string(t, "path"))
          { node, path }
        }
        _ => raise ParseError::MissingField(field="channel.target")
      }
      { sampler, target }
    })
    let samplers_raw = get_obj_array(o, "samplers")
    let samplers = samplers_raw.map(s => {
      let input = get_int(s, "input")
      let output = get_int(s, "output")
      let interpolation = match get_string_opt(s, "interpolation") {
        Some(v) => parse_interpolation(v)
        None => Linear
      }
      { input, output, interpolation }
    })
    { name, channels, samplers }
  })
}

///|
fn parse_skins(root : Map[String, Json]) -> Array[GltfSkin] raise ParseError {
  let arr = get_obj_array(root, "skins")
  arr.map(o => {
    let name = get_string_opt(o, "name")
    let skeleton = get_int_opt(o, "skeleton")
    let joints = get_int_array(o, "joints")
    let inverse_bind_matrices = get_int_opt(o, "inverseBindMatrices")
    { name, skeleton, joints, inverse_bind_matrices }
  })
}
