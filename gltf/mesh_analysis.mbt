///|
/// Mesh-level diagnostics used by importers to estimate GPU and CPU costs.

///|
pub(all) struct PrimitiveReport {
  mesh : Int
  primitive : Int
  mode : String
  vertex_count : Int
  index_count : Int
  triangle_count : Int
  attribute_count : Int
  attribute_names : Array[String]
  indexed : Bool
  material : Int?
  has_position : Bool
  has_normal : Bool
  has_tangent : Bool
  has_texcoord0 : Bool
  has_color0 : Bool
  has_joints0 : Bool
  has_weights0 : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct MeshCostReport {
  mesh : Int
  name : String?
  primitives : Array[PrimitiveReport]
  vertex_count : Int
  triangle_count : Int
  draw_calls : Int
  attribute_slots : Int
  estimated_vertex_bytes : Int
} derive(Debug, ToJson, Eq)

///|
fn has_attribute(primitive : GltfPrimitive, name : String) -> Bool {
  primitive.attributes.contains(name)
}

///|
pub fn primitive_report(
  doc : GltfDocument,
  mesh : Int,
  primitive_index : Int,
) -> PrimitiveReport {
  let primitive = doc.meshes[mesh].primitives[primitive_index]
  {
    mesh,
    primitive: primitive_index,
    mode: primitive_topology_name(primitive.mode),
    vertex_count: primitive_vertex_count(doc, primitive),
    index_count: primitive_index_count(doc, primitive),
    triangle_count: primitive_estimated_triangle_count(doc, primitive),
    attribute_count: primitive.attributes.length(),
    attribute_names: primitive.attributes.keys().collect(),
    indexed: primitive_is_indexed(primitive),
    material: primitive.material,
    has_position: has_attribute(primitive, "POSITION"),
    has_normal: has_attribute(primitive, "NORMAL"),
    has_tangent: has_attribute(primitive, "TANGENT"),
    has_texcoord0: has_attribute(primitive, "TEXCOORD_0"),
    has_color0: has_attribute(primitive, "COLOR_0"),
    has_joints0: has_attribute(primitive, "JOINTS_0"),
    has_weights0: has_attribute(primitive, "WEIGHTS_0"),
  }
}

///|
fn estimate_attribute_bytes(name : String) -> Int {
  match name {
    "POSITION" => 12
    "NORMAL" => 12
    "TANGENT" => 16
    "TEXCOORD_0" | "TEXCOORD_1" => 8
    "COLOR_0" => 16
    "JOINTS_0" => 8
    "WEIGHTS_0" => 16
    _ => 16
  }
}

///|
fn estimate_vertex_bytes(primitive : PrimitiveReport) -> Int {
  primitive.attribute_names.fold(init=0, (sum, name) => {
    sum + estimate_attribute_bytes(name)
  }) *
  primitive.vertex_count
}

///|
pub fn mesh_cost_report(doc : GltfDocument, mesh_index : Int) -> MeshCostReport {
  let mesh = doc.meshes[mesh_index]
  let primitives = []
  for primitive_index in 0..<mesh.primitives.length() {
    primitives.push(primitive_report(doc, mesh_index, primitive_index))
  }
  let vertex_count = primitives.fold(init=0, (sum, item) => {
    sum + item.vertex_count
  })
  let triangle_count = primitives.fold(init=0, (sum, item) => {
    sum + item.triangle_count
  })
  let attribute_slots = primitives.fold(init=0, (sum, item) => {
    sum + item.attribute_count
  })
  let estimated_vertex_bytes = primitives.fold(init=0, (sum, item) => {
    sum + estimate_vertex_bytes(item)
  })
  {
    mesh: mesh_index,
    name: mesh.name,
    primitives,
    vertex_count,
    triangle_count,
    draw_calls: primitives.length(),
    attribute_slots,
    estimated_vertex_bytes,
  }
}

///|
pub fn all_mesh_cost_reports(doc : GltfDocument) -> Array[MeshCostReport] {
  let result = []
  for index in 0..<doc.meshes.length() {
    result.push(mesh_cost_report(doc, index))
  }
  result
}

///|
pub fn total_estimated_vertex_bytes(doc : GltfDocument) -> Int {
  all_mesh_cost_reports(doc).fold(init=0, (sum, report) => {
    sum + report.estimated_vertex_bytes
  })
}

///|
pub fn total_attribute_slots(doc : GltfDocument) -> Int {
  all_mesh_cost_reports(doc).fold(init=0, (sum, report) => {
    sum + report.attribute_slots
  })
}

///|
pub fn mesh_with_most_vertices(doc : GltfDocument) -> Int? {
  if doc.meshes.length() == 0 {
    return None
  }
  let mut selected = 0
  let mut largest = 0
  for index in 0..<doc.meshes.length() {
    let count = mesh_cost_report(doc, index).vertex_count
    if count > largest {
      largest = count
      selected = index
    }
  }
  Some(selected)
}

///|
pub fn mesh_with_most_triangles(doc : GltfDocument) -> Int? {
  if doc.meshes.length() == 0 {
    return None
  }
  let mut selected = 0
  let mut largest = 0
  for index in 0..<doc.meshes.length() {
    let count = mesh_cost_report(doc, index).triangle_count
    if count > largest {
      largest = count
      selected = index
    }
  }
  Some(selected)
}

///|
pub fn unindexed_mesh_count(doc : GltfDocument) -> Int {
  all_mesh_cost_reports(doc).fold(init=0, (count, report) => {
    if report.primitives.any(item => !item.indexed) {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn missing_normal_primitive_count(doc : GltfDocument) -> Int {
  all_mesh_cost_reports(doc).fold(init=0, (count, report) => {
    count +
    report.primitives.fold(init=0, (inner, item) => {
      if item.has_normal {
        inner
      } else {
        inner + 1
      }
    })
  })
}

///|
pub fn skinned_primitive_count(doc : GltfDocument) -> Int {
  all_mesh_cost_reports(doc).fold(init=0, (count, report) => {
    count +
    report.primitives.fold(init=0, (inner, item) => {
      if item.has_joints0 && item.has_weights0 {
        inner + 1
      } else {
        inner
      }
    })
  })
}

///|
pub fn primitive_uses_material(
  doc : GltfDocument,
  mesh : Int,
  primitive : Int,
  material : Int,
) -> Bool {
  match doc.meshes.get(mesh) {
    Some(value) =>
      match value.primitives.get(primitive) {
        Some(item) => item.material == Some(material)
        None => false
      }
    None => false
  }
}

///|
pub fn material_usage_counts(doc : GltfDocument) -> Array[Int] {
  let counts = Array::make(doc.materials.length(), 0)
  for mesh in doc.meshes {
    for primitive in mesh.primitives {
      match primitive.material {
        Some(index) =>
          if index >= 0 && index < counts.length() {
            counts[index] += 1
          }
        None => ()
      }
    }
  }
  counts
}

///|
pub fn mesh_uses_skin(doc : GltfDocument, mesh : Int) -> Bool {
  for node in doc.nodes {
    if node.mesh == Some(mesh) && node.skin is Some(_) {
      return true
    }
  }
  false
}

///|
pub fn mesh_instance_count(doc : GltfDocument, mesh : Int) -> Int {
  doc.nodes.fold(init=0, (count, node) => {
    if node.mesh == Some(mesh) {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn instanced_mesh_indices(doc : GltfDocument) -> Array[Int] {
  let result = []
  for index in 0..<doc.meshes.length() {
    if mesh_instance_count(doc, index) > 1 {
      result.push(index)
    }
  }
  result
}

///|
pub fn mesh_draw_call_budget(doc : GltfDocument, budget : Int) -> Array[Int] {
  let result = []
  for report in all_mesh_cost_reports(doc) {
    if report.draw_calls > budget {
      result.push(report.mesh)
    }
  }
  result
}

///|
pub fn primitive_attribute_signature(primitive : GltfPrimitive) -> String {
  let names : Array[String] = primitive.attributes.keys().collect()
  names.sort()
  names.fold(init="", (result, name) => {
    if result == "" {
      name
    } else {
      result + "," + name
    }
  })
}

///|
pub fn mesh_attribute_signatures(
  doc : GltfDocument,
  mesh : Int,
) -> Array[String] {
  doc.meshes[mesh].primitives.map(primitive_attribute_signature)
}
