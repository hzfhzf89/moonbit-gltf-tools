///|
/// Accessor and buffer-view accounting. This module validates byte windows
/// before a loader attempts to decode vertex or animation data.

///|
pub(all) struct ComponentInfo {
  name : String
  size : Int
  signed : Bool
  floating : Bool
  normalized_range : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AccessorLayout {
  accessor_index : Int
  component : ComponentInfo
  component_count : Int
  element_size : Int
  stride : Int
  first_byte : Int
  last_byte_exclusive : Int
  valid : Bool
  problems : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct LayoutIssue {
  accessor : Int
  message : String
} derive(Debug, ToJson, Eq)

///|
pub fn component_info(kind : ComponentType) -> ComponentInfo {
  match kind {
    Byte =>
      {
        name: "BYTE",
        size: 1,
        signed: true,
        floating: false,
        normalized_range: true,
      }
    UnsignedByte =>
      {
        name: "UNSIGNED_BYTE",
        size: 1,
        signed: false,
        floating: false,
        normalized_range: true,
      }
    Short =>
      {
        name: "SHORT",
        size: 2,
        signed: true,
        floating: false,
        normalized_range: true,
      }
    UnsignedShort =>
      {
        name: "UNSIGNED_SHORT",
        size: 2,
        signed: false,
        floating: false,
        normalized_range: true,
      }
    UnsignedInt =>
      {
        name: "UNSIGNED_INT",
        size: 4,
        signed: false,
        floating: false,
        normalized_range: false,
      }
    Float =>
      {
        name: "FLOAT",
        size: 4,
        signed: true,
        floating: true,
        normalized_range: false,
      }
  }
}

///|
pub fn accessor_component_count(kind : AccessorType) -> Int {
  match kind {
    Scalar => 1
    Vec2 => 2
    Vec3 => 3
    Vec4 => 4
    Mat2 => 4
    Mat3 => 9
    Mat4 => 16
  }
}

///|
pub fn accessor_alignment(kind : ComponentType) -> Int {
  let size = component_info(kind).size
  if size > 4 {
    4
  } else {
    size
  }
}

///|
pub fn accessor_element_size(accessor : GltfAccessor) -> Int {
  component_info(accessor.component_type).size *
  accessor_component_count(accessor.accessor_type)
}

///|
pub fn accessor_min_value(accessor : GltfAccessor, index : Int) -> Double? {
  accessor.min_values.get(index)
}

///|
pub fn accessor_max_value(accessor : GltfAccessor, index : Int) -> Double? {
  accessor.max_values.get(index)
}

///|
pub fn accessor_is_index_compatible(accessor : GltfAccessor) -> Bool {
  match accessor.accessor_type {
    Scalar =>
      match accessor.component_type {
        UnsignedByte | UnsignedShort | UnsignedInt => true
        _ => false
      }
    _ => false
  }
}

///|
pub fn accessor_layout(doc : GltfDocument, index : Int) -> AccessorLayout {
  if index < 0 || index >= doc.accessors.length() {
    {
      accessor_index: index,
      component: component_info(Float),
      component_count: 0,
      element_size: 0,
      stride: 0,
      first_byte: 0,
      last_byte_exclusive: 0,
      valid: false,
      problems: ["accessor index is outside the document"],
    }
  } else {
    let accessor = doc.accessors[index]
    let component = component_info(accessor.component_type)
    let component_count = accessor_component_count(accessor.accessor_type)
    let element_size = component.size * component_count
    let mut stride = element_size
    let mut first_byte = accessor.byte_offset
    let mut last_byte_exclusive = first_byte
    let problems : Array[String] = []
    match accessor.buffer_view {
      Some(view_index) =>
        if view_index < 0 || view_index >= doc.buffer_views.length() {
          problems.push("bufferView index is outside the document")
        } else {
          let view = doc.buffer_views[view_index]
          match view.byte_stride {
            Some(value) => stride = value
            None => ()
          }
          first_byte = view.byte_offset + accessor.byte_offset
          if stride < element_size {
            problems.push("byteStride is smaller than one accessor element")
          }
          if stride % accessor_alignment(accessor.component_type) != 0 {
            problems.push("byteStride is not aligned to the component size")
          }
          if accessor.count < 0 {
            problems.push("accessor count cannot be negative")
          }
          if accessor.count > 0 {
            last_byte_exclusive = first_byte +
              stride * (accessor.count - 1) +
              element_size
          } else {
            last_byte_exclusive = first_byte
          }
          if accessor.byte_offset < 0 {
            problems.push("accessor byteOffset cannot be negative")
          }
          if accessor.byte_offset +
            (if accessor.count > 0 {
              stride * (accessor.count - 1) + element_size
            } else {
              0
            }) >
            view.byte_length {
            problems.push("accessor data exceeds its bufferView")
          }
          if view.buffer < 0 || view.buffer >= doc.buffers.length() {
            problems.push("bufferView buffer index is outside the document")
          } else if view.byte_offset + view.byte_length >
            doc.buffers[view.buffer].byte_length {
            problems.push("bufferView exceeds its buffer byteLength")
          }
        }
      None =>
        if accessor.count != 0 {
          problems.push(
            "sparse-only accessors are not supported by this data model",
          )
        }
    }
    {
      accessor_index: index,
      component,
      component_count,
      element_size,
      stride,
      first_byte,
      last_byte_exclusive,
      valid: problems.length() == 0,
      problems,
    }
  }
}

///|
pub fn validate_accessor_layouts(doc : GltfDocument) -> Array[LayoutIssue] {
  let issues : Array[LayoutIssue] = []
  for index in 0..<doc.accessors.length() {
    let layout = accessor_layout(doc, index)
    for problem in layout.problems {
      issues.push({ accessor: index, message: problem })
    }
  }
  issues
}

///|
pub fn buffer_view_end(view : GltfBufferView) -> Int {
  view.byte_offset + view.byte_length
}

///|
pub fn buffer_view_is_aligned(view : GltfBufferView) -> Bool {
  view.byte_offset >= 0 && view.byte_length >= 0 && view.byte_offset % 4 == 0
}

///|
pub fn buffer_total_declared_bytes(doc : GltfDocument) -> Int {
  doc.buffers.fold(init=0, (sum, buffer) => sum + buffer.byte_length)
}

///|
pub fn buffer_total_view_bytes(doc : GltfDocument) -> Int {
  doc.buffer_views.fold(init=0, (sum, view) => sum + view.byte_length)
}

///|
pub fn count_interleaved_views(doc : GltfDocument) -> Int {
  doc.buffer_views.fold(init=0, (count, view) => {
    match view.byte_stride {
      Some(_) => count + 1
      None => count
    }
  })
}

///|
pub fn count_sparse_like_accessors(doc : GltfDocument) -> Int {
  doc.accessors.fold(init=0, (count, accessor) => {
    match accessor.buffer_view {
      Some(_) => count
      None => count + 1
    }
  })
}

///|
pub fn primitive_vertex_count(
  doc : GltfDocument,
  primitive : GltfPrimitive,
) -> Int {
  match primitive.attributes.get("POSITION") {
    Some(accessor_index) =>
      match doc.accessors.get(accessor_index) {
        Some(accessor) => accessor.count
        None => 0
      }
    None => 0
  }
}

///|
pub fn primitive_index_count(
  doc : GltfDocument,
  primitive : GltfPrimitive,
) -> Int {
  match primitive.indices {
    Some(accessor_index) =>
      match doc.accessors.get(accessor_index) {
        Some(accessor) => accessor.count
        None => 0
      }
    None => 0
  }
}

///|
pub fn primitive_is_indexed(primitive : GltfPrimitive) -> Bool {
  primitive.indices is Some(_)
}

///|
pub fn primitive_topology_name(mode : PrimitiveMode) -> String {
  match mode {
    Points => "POINTS"
    Lines => "LINES"
    LineLoop => "LINE_LOOP"
    LineStrip => "LINE_STRIP"
    Triangles => "TRIANGLES"
    TriangleStrip => "TRIANGLE_STRIP"
    TriangleFan => "TRIANGLE_FAN"
  }
}

///|
pub fn primitive_estimated_triangle_count(
  doc : GltfDocument,
  primitive : GltfPrimitive,
) -> Int {
  let count = if primitive_is_indexed(primitive) {
    primitive_index_count(doc, primitive)
  } else {
    primitive_vertex_count(doc, primitive)
  }
  match primitive.mode {
    Triangles => count / 3
    TriangleStrip | TriangleFan => if count >= 3 { count - 2 } else { 0 }
    _ => 0
  }
}

///|
pub fn mesh_estimated_triangle_count(
  doc : GltfDocument,
  mesh : GltfMesh,
) -> Int {
  mesh.primitives.fold(init=0, (sum, primitive) => {
    sum + primitive_estimated_triangle_count(doc, primitive)
  })
}

///|
pub fn document_estimated_triangle_count(doc : GltfDocument) -> Int {
  doc.meshes.fold(init=0, (sum, mesh) => {
    sum + mesh_estimated_triangle_count(doc, mesh)
  })
}

///|
pub fn document_indexed_primitive_ratio(doc : GltfDocument) -> Double {
  let mut total = 0
  let mut indexed = 0
  for mesh in doc.meshes {
    for primitive in mesh.primitives {
      total += 1
      if primitive_is_indexed(primitive) {
        indexed += 1
      }
    }
  }
  if total == 0 {
    0.0
  } else {
    indexed.to_double() / total.to_double()
  }
}
