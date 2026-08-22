///|
/// Scene graph queries for importers, editors, and build-time asset checks.
///
/// The original tree traversal API answers aggregate questions. This module
/// keeps the node-level operations reusable: callers can resolve stable paths,
/// inspect reachability, select mesh instances, and measure hierarchy shape
/// without reimplementing cycle-safe traversal.

///|
pub(all) struct SceneNodePath {
  scene : Int?
  nodes : Array[Int]
  labels : Array[String]
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct NodeSelection {
  name : String?
  name_prefix : String?
  has_mesh : Bool?
  has_skin : Bool?
  has_camera : Bool?
  leaf_only : Bool
  scene : Int?
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SceneQueryResult {
  nodes : Array[Int]
  paths : Array[SceneNodePath]
  meshes : Array[Int]
  skins : Array[Int]
  cameras : Array[Int]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SceneGraphReport {
  scene_index : Int?
  root_count : Int
  reachable_count : Int
  orphan_count : Int
  leaf_count : Int
  branch_count : Int
  max_depth : Int
  average_children : Double
  duplicate_name_count : Int
  cycle_node_count : Int
  mesh_instance_count : Int
  skinned_node_count : Int
  camera_node_count : Int
  depth_histogram : Array[Int]
  reachable_nodes : Array[Int]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct NodeInstance {
  node : Int
  mesh : Int?
  skin : Int?
  scene : Int?
  path : SceneNodePath
  world_transform : Mat4
} derive(Debug, ToJson, Eq)

///|
pub fn empty_node_selection() -> NodeSelection {
  {
    name: None,
    name_prefix: None,
    has_mesh: None,
    has_skin: None,
    has_camera: None,
    leaf_only: false,
    scene: None,
  }
}

///|
pub fn selection_for_name(name : String) -> NodeSelection {
  { ..empty_node_selection(), name: Some(name) }
}

///|
pub fn selection_for_mesh_nodes() -> NodeSelection {
  { ..empty_node_selection(), has_mesh: Some(true) }
}

///|
pub fn selection_for_skinned_nodes() -> NodeSelection {
  { ..empty_node_selection(), has_skin: Some(true) }
}

///|
pub fn selection_for_leaves() -> NodeSelection {
  { ..empty_node_selection(), leaf_only: true }
}

///|
pub fn node_name(doc : GltfDocument, index : Int) -> String {
  match doc.nodes.get(index) {
    Some(node) =>
      match node.name {
        Some(name) => name
        None => "node[\{index}]"
      }
    None => "node[\{index}]"
  }
}

///|
pub fn node_has_children(doc : GltfDocument, index : Int) -> Bool {
  match doc.nodes.get(index) {
    Some(node) => node.children.length() > 0
    None => false
  }
}

///|
pub fn node_is_leaf(doc : GltfDocument, index : Int) -> Bool {
  !node_has_children(doc, index)
}

///|
pub fn node_child_count(doc : GltfDocument, index : Int) -> Int {
  match doc.nodes.get(index) {
    Some(node) => node.children.length()
    None => 0
  }
}

///|
pub fn node_mesh_index(doc : GltfDocument, index : Int) -> Int? {
  match doc.nodes.get(index) {
    Some(node) => node.mesh
    None => None
  }
}

///|
pub fn node_skin_index(doc : GltfDocument, index : Int) -> Int? {
  match doc.nodes.get(index) {
    Some(node) => node.skin
    None => None
  }
}

///|
pub fn node_camera_index(doc : GltfDocument, index : Int) -> Int? {
  match doc.nodes.get(index) {
    Some(node) => node.camera
    None => None
  }
}

///|
pub fn node_parent_indices(doc : GltfDocument) -> Map[Int, Int] {
  let parents : Map[Int, Int] = Map([])
  for parent, node in doc.nodes {
    for child in node.children {
      if child >= 0 && child < doc.nodes.length() && !parents.contains(child) {
        parents[child] = parent
      }
    }
  }
  parents
}

///|
pub fn scene_roots(doc : GltfDocument, scene_index : Int) -> Array[Int] {
  match doc.scenes.get(scene_index) {
    Some(scene) => scene.nodes
    None => []
  }
}

///|
pub fn default_scene_index(doc : GltfDocument) -> Int? {
  match doc.default_scene {
    Some(index) =>
      if index >= 0 && index < doc.scenes.length() {
        Some(index)
      } else {
        None
      }
    None => if doc.scenes.length() == 1 { Some(0) } else { None }
  }
}

///|
fn visit_nodes(
  doc : GltfDocument,
  roots : Array[Int],
  visited : Map[Int, Bool],
  order : Array[Int],
) -> Unit {
  let stack : Array[Int] = []
  for root in roots {
    stack.push(root)
  }
  while stack.length() > 0 {
    let last = stack.length() - 1
    let current = stack[last]
    ignore(stack.remove(last))
    if current >= 0 &&
      current < doc.nodes.length() &&
      !visited.contains(current) {
      visited[current] = true
      order.push(current)
      for child in doc.nodes[current].children {
        stack.push(child)
      }
    }
  }
}

///|
pub fn reachable_scene_nodes(
  doc : GltfDocument,
  scene_index : Int,
) -> Array[Int] {
  let visited : Map[Int, Bool] = Map([])
  let order : Array[Int] = []
  visit_nodes(doc, scene_roots(doc, scene_index), visited, order)
  order
}

///|
pub fn all_reachable_scene_nodes(doc : GltfDocument) -> Array[Int] {
  let visited : Map[Int, Bool] = Map([])
  let order : Array[Int] = []
  for scene_index in 0..<doc.scenes.length() {
    let scene_order : Array[Int] = []
    visit_nodes(doc, scene_roots(doc, scene_index), visited, scene_order)
    for node in scene_order {
      order.push(node)
    }
  }
  order
}

///|
pub fn orphan_node_indices(doc : GltfDocument) -> Array[Int] {
  let reachable : Map[Int, Bool] = Map([])
  for node in all_reachable_scene_nodes(doc) {
    reachable[node] = true
  }
  let result : Array[Int] = []
  for index in 0..<doc.nodes.length() {
    if !reachable.contains(index) {
      result.push(index)
    }
  }
  result
}

///|
pub fn scene_node_depths(
  doc : GltfDocument,
  scene_index : Int,
) -> Map[Int, Int] {
  let depths : Map[Int, Int] = Map([])
  let queue : Array[(Int, Int)] = []
  for root in scene_roots(doc, scene_index) {
    queue.push((root, 1))
  }
  let mut cursor = 0
  while cursor < queue.length() {
    let (node, depth) = queue[cursor]
    cursor += 1
    if node >= 0 &&
      node < doc.nodes.length() &&
      (!depths.contains(node) || depth < depths[node]) {
      depths[node] = depth
      for child in doc.nodes[node].children {
        queue.push((child, depth + 1))
      }
    }
  }
  depths
}

///|
pub fn node_depth(doc : GltfDocument, scene_index : Int, node : Int) -> Int? {
  scene_node_depths(doc, scene_index).get(node)
}

///|
pub fn node_ancestors(doc : GltfDocument, node : Int) -> Array[Int] {
  let parents = node_parent_indices(doc)
  let result : Array[Int] = []
  let seen : Map[Int, Bool] = Map([])
  let mut current : Int? = Some(node)
  while current is Some(value) {
    if seen.contains(value) {
      break
    }
    seen[value] = true
    match parents.get(value) {
      Some(parent) => {
        result.push(parent)
        current = Some(parent)
      }
      None => current = None
    }
  }
  result
}

///|
pub fn node_descendants(doc : GltfDocument, node : Int) -> Array[Int] {
  let result : Array[Int] = []
  let queue : Array[Int] = [node]
  let mut cursor = 0
  let seen : Map[Int, Bool] = Map([])
  while cursor < queue.length() {
    let current = queue[cursor]
    cursor += 1
    if current >= 0 && current < doc.nodes.length() && !seen.contains(current) {
      seen[current] = true
      for child in doc.nodes[current].children {
        result.push(child)
        queue.push(child)
      }
    }
  }
  result
}

///|
pub fn node_is_descendant(
  doc : GltfDocument,
  ancestor : Int,
  candidate : Int,
) -> Bool {
  for node in node_descendants(doc, ancestor) {
    if node == candidate {
      return true
    }
  }
  false
}

///|
pub fn node_is_ancestor(
  doc : GltfDocument,
  ancestor : Int,
  candidate : Int,
) -> Bool {
  for node in node_ancestors(doc, candidate) {
    if node == ancestor {
      return true
    }
  }
  false
}

///|
pub fn scene_node_path(
  doc : GltfDocument,
  scene_index : Int?,
  node : Int,
) -> SceneNodePath {
  if node < 0 || node >= doc.nodes.length() {
    { scene: scene_index, nodes: [], labels: [], valid: false }
  } else {
    let parents = node_parent_indices(doc)
    let chain : Array[Int] = []
    let seen : Map[Int, Bool] = Map([])
    let mut current : Int? = Some(node)
    let mut valid = true
    while current is Some(value) {
      if seen.contains(value) {
        valid = false
        current = None
      } else {
        seen[value] = true
        chain.push(value)
        current = parents.get(value)
      }
    }
    let nodes : Array[Int] = []
    let labels : Array[String] = []
    for index in 0..<chain.length() {
      let reverse = chain.length() - 1 - index
      let value = chain[reverse]
      nodes.push(value)
      labels.push(node_name(doc, value))
    }
    { scene: scene_index, nodes, labels, valid }
  }
}

///|
pub fn scene_node_path_text(path : SceneNodePath) -> String {
  if path.nodes.length() == 0 {
    "<invalid-node>"
  } else {
    let text = StringBuilder()
    for index, label in path.labels {
      if index > 0 {
        text.write_char('/')
      }
      text.write_string(label)
    }
    text.to_string()
  }
}

///|
pub fn scene_node_path_for(
  doc : GltfDocument,
  scene_index : Int,
  node : Int,
) -> String {
  scene_node_path_text(scene_node_path(doc, Some(scene_index), node))
}

///|
fn selection_matches(
  doc : GltfDocument,
  query : NodeSelection,
  node : Int,
) -> Bool {
  if node < 0 || node >= doc.nodes.length() {
    false
  } else {
    let value = doc.nodes[node]
    let name_matches = match query.name {
      Some(name) => value.name == Some(name)
      None => true
    }
    let prefix_matches = match query.name_prefix {
      Some(prefix) =>
        match value.name {
          Some(name) => name.has_prefix(prefix)
          None => false
        }
      None => true
    }
    let mesh_matches = match query.has_mesh {
      Some(expected) => (value.mesh is Some(_)) == expected
      None => true
    }
    let skin_matches = match query.has_skin {
      Some(expected) => (value.skin is Some(_)) == expected
      None => true
    }
    let camera_matches = match query.has_camera {
      Some(expected) => (value.camera is Some(_)) == expected
      None => true
    }
    let leaf_matches = !query.leaf_only || value.children.length() == 0
    name_matches &&
    prefix_matches &&
    mesh_matches &&
    skin_matches &&
    camera_matches &&
    leaf_matches
  }
}

///|
pub fn query_scene_nodes(
  doc : GltfDocument,
  query : NodeSelection,
) -> SceneQueryResult {
  let candidates = match query.scene {
    Some(scene) => reachable_scene_nodes(doc, scene)
    None => all_reachable_scene_nodes(doc)
  }
  let nodes : Array[Int] = []
  let paths : Array[SceneNodePath] = []
  let meshes : Array[Int] = []
  let skins : Array[Int] = []
  let cameras : Array[Int] = []
  for node in candidates {
    if selection_matches(doc, query, node) {
      nodes.push(node)
      paths.push(scene_node_path(doc, query.scene, node))
      if doc.nodes[node].mesh is Some(_) {
        meshes.push(node)
      }
      if doc.nodes[node].skin is Some(_) {
        skins.push(node)
      }
      if doc.nodes[node].camera is Some(_) {
        cameras.push(node)
      }
    }
  }
  { nodes, paths, meshes, skins, cameras }
}

///|
pub fn find_nodes_by_name(doc : GltfDocument, name : String) -> Array[Int] {
  query_scene_nodes(doc, selection_for_name(name)).nodes
}

///|
pub fn find_nodes_by_prefix(doc : GltfDocument, prefix : String) -> Array[Int] {
  query_scene_nodes(doc, { ..empty_node_selection(), name_prefix: Some(prefix) }).nodes
}

///|
pub fn mesh_instance_nodes(doc : GltfDocument) -> Array[Int] {
  query_scene_nodes(doc, selection_for_mesh_nodes()).nodes
}

///|
pub fn skinned_instance_nodes(doc : GltfDocument) -> Array[Int] {
  query_scene_nodes(doc, selection_for_skinned_nodes()).nodes
}

///|
pub fn leaf_nodes(doc : GltfDocument) -> Array[Int] {
  query_scene_nodes(doc, selection_for_leaves()).nodes
}

///|
pub fn named_node_duplicate_count(doc : GltfDocument) -> Int {
  let names : Map[String, Int] = Map([])
  for node in doc.nodes {
    match node.name {
      Some(name) =>
        names[name] = match names.get(name) {
          Some(count) => count + 1
          None => 1
        }
      None => ()
    }
  }
  let mut duplicates = 0
  for _, count in names {
    if count > 1 {
      duplicates += count - 1
    }
  }
  duplicates
}

///|
pub fn scene_depth_histogram(
  doc : GltfDocument,
  scene_index : Int?,
) -> Array[Int] {
  let depths = match scene_index {
    Some(scene) => scene_node_depths(doc, scene)
    None => {
      let combined : Map[Int, Int] = Map([])
      for index in 0..<doc.scenes.length() {
        let one = scene_node_depths(doc, index)
        for node, depth in one {
          match combined.get(node) {
            Some(old) => if depth < old { combined[node] = depth }
            None => combined[node] = depth
          }
        }
      }
      combined
    }
  }
  let mut maximum = 0
  for _, depth in depths {
    if depth > maximum {
      maximum = depth
    }
  }
  let histogram : Array[Int] = []
  for _ in 0..<(maximum + 1) {
    histogram.push(0)
  }
  for _, depth in depths {
    if depth >= 0 && depth < histogram.length() {
      histogram[depth] += 1
    }
  }
  histogram
}

///|
pub fn scene_average_children(doc : GltfDocument, nodes : Array[Int]) -> Double {
  if nodes.length() == 0 {
    0.0
  } else {
    nodes
    .fold(init=0, (sum, node) => sum + node_child_count(doc, node))
    .to_double() /
    nodes.length().to_double()
  }
}

///|
pub fn scene_graph_report(
  doc : GltfDocument,
  scene_index : Int?,
) -> SceneGraphReport {
  let reachable = match scene_index {
    Some(scene) => reachable_scene_nodes(doc, scene)
    None => all_reachable_scene_nodes(doc)
  }
  let reachable_map : Map[Int, Bool] = Map([])
  for node in reachable {
    reachable_map[node] = true
  }
  let mut leaves = 0
  let mut branches = 0
  let mut maximum = 0
  for node in reachable {
    let children = node_child_count(doc, node)
    if children == 0 {
      leaves += 1
    } else {
      branches += 1
    }
  }
  let histogram = scene_depth_histogram(doc, scene_index)
  for depth, count in histogram {
    if count > 0 && depth > maximum {
      maximum = depth
    }
  }
  let orphan_count = if scene_index is Some(_) {
    doc.nodes.length() - reachable.length()
  } else {
    orphan_node_indices(doc).length()
  }
  let mesh_count = reachable.fold(init=0, (count, node) => {
    if node_mesh_index(doc, node) is Some(_) {
      count + 1
    } else {
      count
    }
  })
  let skin_count = reachable.fold(init=0, (count, node) => {
    if node_skin_index(doc, node) is Some(_) {
      count + 1
    } else {
      count
    }
  })
  let camera_count = reachable.fold(init=0, (count, node) => {
    if node_camera_index(doc, node) is Some(_) {
      count + 1
    } else {
      count
    }
  })
  {
    scene_index,
    root_count: match scene_index {
      Some(index) => scene_roots(doc, index).length()
      None =>
        doc.scenes.fold(init=0, (sum, scene) => sum + scene.nodes.length())
    },
    reachable_count: reachable.length(),
    orphan_count,
    leaf_count: leaves,
    branch_count: branches,
    max_depth: maximum,
    average_children: scene_average_children(doc, reachable),
    duplicate_name_count: named_node_duplicate_count(doc),
    cycle_node_count: scene_cycle_count(doc),
    mesh_instance_count: mesh_count,
    skinned_node_count: skin_count,
    camera_node_count: camera_count,
    depth_histogram: histogram,
    reachable_nodes: reachable,
  }
}

///|
pub fn document_scene_graph_report(doc : GltfDocument) -> SceneGraphReport {
  scene_graph_report(doc, default_scene_index(doc))
}

///|
pub fn node_world_transform(doc : GltfDocument, node : Int) -> Mat4 {
  let report = evaluate_scene_transforms(doc)
  match world_transform_for(report, node) {
    Some(transform) => transform
    None => identity_mat4()
  }
}

///|
pub fn node_world_position(doc : GltfDocument, node : Int) -> Vec3 {
  let transform = node_world_transform(doc, node)
  mat4_transform_point(transform, { x: 0.0, y: 0.0, z: 0.0 })
}

///|
pub fn scene_world_positions(
  doc : GltfDocument,
  scene_index : Int,
) -> Map[Int, Vec3] {
  let positions : Map[Int, Vec3] = Map([])
  for node in reachable_scene_nodes(doc, scene_index) {
    positions[node] = node_world_position(doc, node)
  }
  positions
}

///|
pub fn node_instance(
  doc : GltfDocument,
  scene_index : Int?,
  node : Int,
) -> NodeInstance? {
  if node < 0 || node >= doc.nodes.length() {
    None
  } else {
    Some({
      node,
      mesh: node_mesh_index(doc, node),
      skin: node_skin_index(doc, node),
      scene: scene_index,
      path: scene_node_path(doc, scene_index, node),
      world_transform: node_world_transform(doc, node),
    })
  }
}

///|
pub fn scene_mesh_instances(
  doc : GltfDocument,
  scene_index : Int,
) -> Array[NodeInstance] {
  let instances : Array[NodeInstance] = []
  for node in reachable_scene_nodes(doc, scene_index) {
    if node_mesh_index(doc, node) is Some(_) {
      match node_instance(doc, Some(scene_index), node) {
        Some(instance) => instances.push(instance)
        None => ()
      }
    }
  }
  instances
}

///|
pub fn scene_nodes_with_no_parent(doc : GltfDocument) -> Array[Int] {
  let parents = node_parent_indices(doc)
  let roots : Array[Int] = []
  for index in 0..<doc.nodes.length() {
    if !parents.contains(index) {
      roots.push(index)
    }
  }
  roots
}

///|
pub fn node_subtree_size(doc : GltfDocument, node : Int) -> Int {
  node_descendants(doc, node).length() + 1
}

///|
pub fn node_leaf_descendant_count(doc : GltfDocument, node : Int) -> Int {
  node_descendants(doc, node).fold(init=0, (count, child) => {
    if node_is_leaf(doc, child) {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn node_branching_factor(doc : GltfDocument, node : Int) -> Double {
  let descendants = node_descendants(doc, node)
  scene_average_children(doc, descendants)
}

///|
pub fn scene_is_connected(doc : GltfDocument, scene_index : Int) -> Bool {
  reachable_scene_nodes(doc, scene_index).length() == doc.nodes.length()
}

///|
pub fn scene_has_orphans(doc : GltfDocument, scene_index : Int) -> Bool {
  reachable_scene_nodes(doc, scene_index).length() < doc.nodes.length()
}

///|
pub fn scene_has_multiple_roots(doc : GltfDocument, scene_index : Int) -> Bool {
  scene_roots(doc, scene_index).length() > 1
}

///|
pub fn scene_max_branching_factor(doc : GltfDocument, scene_index : Int) -> Int {
  reachable_scene_nodes(doc, scene_index).fold(init=0, (maximum, node) => {
    let count = node_child_count(doc, node)
    if count > maximum {
      count
    } else {
      maximum
    }
  })
}

///|
pub fn scene_mesh_indices(doc : GltfDocument, scene_index : Int) -> Array[Int] {
  let indices : Array[Int] = []
  for node in reachable_scene_nodes(doc, scene_index) {
    match node_mesh_index(doc, node) {
      Some(mesh) => if !indices.contains(mesh) { indices.push(mesh) }
      None => ()
    }
  }
  indices
}

///|
pub fn scene_skin_indices(doc : GltfDocument, scene_index : Int) -> Array[Int] {
  let indices : Array[Int] = []
  for node in reachable_scene_nodes(doc, scene_index) {
    match node_skin_index(doc, node) {
      Some(skin) => if !indices.contains(skin) { indices.push(skin) }
      None => ()
    }
  }
  indices
}

///|
pub fn scene_camera_indices(
  doc : GltfDocument,
  scene_index : Int,
) -> Array[Int] {
  let indices : Array[Int] = []
  for node in reachable_scene_nodes(doc, scene_index) {
    match node_camera_index(doc, node) {
      Some(camera) => if !indices.contains(camera) { indices.push(camera) }
      None => ()
    }
  }
  indices
}

///|
pub fn scene_path_lookup(
  doc : GltfDocument,
  scene_index : Int,
) -> Map[String, Int] {
  let lookup : Map[String, Int] = Map([])
  for node in reachable_scene_nodes(doc, scene_index) {
    let path = scene_node_path_for(doc, scene_index, node)
    lookup[path] = node
  }
  lookup
}

///|
pub fn resolve_scene_path(
  doc : GltfDocument,
  scene_index : Int,
  path : String,
) -> Int? {
  scene_path_lookup(doc, scene_index).get(path)
}

///|
pub fn scene_report_summary_lines(report : SceneGraphReport) -> Array[String] {
  [
    "scene=\{Repr(report.scene_index)}, roots=\{report.root_count}",
    "reachable=\{report.reachable_count}, orphans=\{report.orphan_count}",
    "leaves=\{report.leaf_count}, branches=\{report.branch_count}, max_depth=\{report.max_depth}",
    "mesh_instances=\{report.mesh_instance_count}, skinned=\{report.skinned_node_count}, cameras=\{report.camera_node_count}",
    "duplicates=\{report.duplicate_name_count}, cycles=\{report.cycle_node_count}",
  ]
}
