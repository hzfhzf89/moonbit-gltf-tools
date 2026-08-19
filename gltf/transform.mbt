///|
/// Scene transform evaluation for offline tooling. glTF nodes can provide a
/// matrix in the full specification; the current data model stores TRS, so
/// this module evaluates the TRS form and makes inheritance explicit.

///|
pub(all) struct WorldTransform {
  node : Int
  parent : Int?
  local_matrix : Mat4
  world : Mat4
  depth : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct TransformReport {
  transforms : Array[WorldTransform]
  roots : Array[Int]
  max_depth : Int
  cycle_nodes : Array[Int]
} derive(Debug, ToJson, Eq)

///|
fn node_translation(node : GltfNode) -> Vec3 {
  match node.translation {
    Some(value) => value
    None => { x: 0.0, y: 0.0, z: 0.0 }
  }
}

///|
fn node_rotation(node : GltfNode) -> Quat {
  match node.rotation {
    Some(value) => value
    None => { x: 0.0, y: 0.0, z: 0.0, w: 1.0 }
  }
}

///|
fn node_scale(node : GltfNode) -> Vec3 {
  match node.scale {
    Some(value) => value
    None => { x: 1.0, y: 1.0, z: 1.0 }
  }
}

///|
pub fn node_local_transform(node : GltfNode) -> Mat4 {
  mat4_from_trs(node_translation(node), node_rotation(node), node_scale(node))
}

///|
pub fn node_has_nontrivial_transform(node : GltfNode) -> Bool {
  let translation = node_translation(node)
  let rotation = node_rotation(node)
  let scale = node_scale(node)
  translation.x != 0.0 ||
  translation.y != 0.0 ||
  translation.z != 0.0 ||
  rotation.x != 0.0 ||
  rotation.y != 0.0 ||
  rotation.z != 0.0 ||
  rotation.w != 1.0 ||
  scale.x != 1.0 ||
  scale.y != 1.0 ||
  scale.z != 1.0
}

///|
pub fn count_transformed_nodes(doc : GltfDocument) -> Int {
  doc.nodes.fold(init=0, (count, node) => {
    if node_has_nontrivial_transform(node) {
      count + 1
    } else {
      count
    }
  })
}

///|
fn append_transform(
  report : Array[WorldTransform],
  node : Int,
  parent : Int?,
  local_matrix : Mat4,
  world : Mat4,
  depth : Int,
) -> Unit {
  report.push({ node, parent, local_matrix, world, depth })
}

///|
fn walk_transform(
  doc : GltfDocument,
  node : Int,
  parent : Int?,
  parent_world : Mat4,
  depth : Int,
  visiting : Map[Int, Bool],
  result : Array[WorldTransform],
  cycles : Array[Int],
  max_depth : Ref[Int],
) -> Unit {
  if node < 0 || node >= doc.nodes.length() {
    return
  }
  if visiting.contains(node) {
    if !cycles.contains(node) {
      cycles.push(node)
    }
    return
  }
  visiting[node] = true
  let current = doc.nodes[node]
  let local_matrix = node_local_transform(current)
  let world = mat4_mul(parent_world, local_matrix)
  append_transform(result, node, parent, local_matrix, world, depth)
  if depth > max_depth.val {
    max_depth.val = depth
  }
  for child in current.children {
    walk_transform(
      doc,
      child,
      Some(node),
      world,
      depth + 1,
      visiting,
      result,
      cycles,
      max_depth,
    )
  }
  visiting.remove(node)
}

///|
pub fn evaluate_scene_transforms(doc : GltfDocument) -> TransformReport {
  let transforms : Array[WorldTransform] = []
  let roots : Array[Int] = []
  let cycles : Array[Int] = []
  let visiting : Map[Int, Bool] = Map([])
  let max_depth : Ref[Int] = Ref(0)
  for scene in doc.scenes {
    for root in scene.nodes {
      if !roots.contains(root) {
        roots.push(root)
      }
    }
  }
  for root in roots {
    walk_transform(
      doc,
      root,
      None,
      identity_mat4(),
      1,
      visiting,
      transforms,
      cycles,
      max_depth,
    )
  }
  { transforms, roots, max_depth: max_depth.val, cycle_nodes: cycles }
}

///|
pub fn world_transform_for(report : TransformReport, node : Int) -> Mat4? {
  for item in report.transforms {
    if item.node == node {
      return Some(item.world)
    }
  }
  None
}

///|
pub fn transformed_node_bounds(bounds : Bounds3, transform : Mat4) -> Bounds3 {
  if !bounds.valid {
    return bounds
  }
  let corners = [
    { x: bounds.min.x, y: bounds.min.y, z: bounds.min.z },
    { x: bounds.max.x, y: bounds.min.y, z: bounds.min.z },
    { x: bounds.min.x, y: bounds.max.y, z: bounds.min.z },
    { x: bounds.max.x, y: bounds.max.y, z: bounds.min.z },
    { x: bounds.min.x, y: bounds.min.y, z: bounds.max.z },
    { x: bounds.max.x, y: bounds.min.y, z: bounds.max.z },
    { x: bounds.min.x, y: bounds.max.y, z: bounds.max.z },
    { x: bounds.max.x, y: bounds.max.y, z: bounds.max.z },
  ]
  let mut output = bounds_empty()
  for corner in corners {
    output = bounds_include(output, mat4_transform_point(transform, corner))
  }
  output
}

///|
pub fn scene_root_count(doc : GltfDocument) -> Int {
  evaluate_scene_transforms(doc).roots.length()
}

///|
pub fn scene_cycle_count(doc : GltfDocument) -> Int {
  evaluate_scene_transforms(doc).cycle_nodes.length()
}

///|
pub fn scene_transform_depth(doc : GltfDocument) -> Int {
  evaluate_scene_transforms(doc).max_depth
}
