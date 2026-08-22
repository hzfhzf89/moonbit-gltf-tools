///|
pub(all) struct SceneSnapshotNode {
  index : Int
  parent : Int?
  child_count : Int
  mesh : Int?
  skin : Int?
  camera : Int?
  depth : Int
  signature : String
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SceneSnapshot {
  scene : Int
  nodes : Array[SceneSnapshotNode]
  roots : Array[Int]
  max_depth : Int
  mesh_nodes : Int
  skinned_nodes : Int
  leaf_nodes : Int
  signature : String
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SceneSnapshotChange {
  node : Int
  kind : String
  before : String?
  after : String?
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SceneSnapshotDiff {
  changes : Array[SceneSnapshotChange]
  added : Int
  removed : Int
  changed : Int
  unchanged : Int
  compatible : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn scene_snapshot_node_signature(node : GltfNode) -> String {
  let name = match node.name {
    Some(value) => value
    None => ""
  }
  let mesh = match node.mesh {
    Some(value) => "\{value}"
    None => "-"
  }
  let skin = match node.skin {
    Some(value) => "\{value}"
    None => "-"
  }
  let camera = match node.camera {
    Some(value) => "\{value}"
    None => "-"
  }
  "\{name}|\{mesh}|\{skin}|\{camera}|\{node.children.length()}"
}

///|
pub fn scene_snapshot_node(
  index : Int,
  parent : Int?,
  node : GltfNode,
  depth : Int,
) -> SceneSnapshotNode {
  {
    index,
    parent,
    child_count: node.children.length(),
    mesh: node.mesh,
    skin: node.skin,
    camera: node.camera,
    depth,
    signature: scene_snapshot_node_signature(node),
  }
}

///|
pub fn scene_snapshot(doc : GltfDocument, scene_index : Int) -> SceneSnapshot {
  let scene = match doc.scenes.get(scene_index) {
    Some(value) => value
    None => { name: None, nodes: [] }
  }
  let snapshots : Array[SceneSnapshotNode] = []
  let roots = scene.nodes.copy()
  let visited : Map[Int, Bool] = Map([])
  let mut max_depth = 0
  let mut mesh_nodes = 0
  let mut skinned_nodes = 0
  let mut leaf_nodes = 0
  for root in roots {
    let frontier : Array[(Int, Int, Int?)] = [(root, 1, None)]
    while frontier.length() > 0 {
      let item = frontier.remove(0)
      let index = item.0
      let depth = item.1
      let parent = item.2
      if visited.contains(index) {
        continue
      }
      visited[index] = true
      match doc.nodes.get(index) {
        Some(node) => {
          snapshots.push(scene_snapshot_node(index, parent, node, depth))
          if depth > max_depth {
            max_depth = depth
          }
          match node.mesh {
            Some(_) => mesh_nodes = mesh_nodes + 1
            None => ()
          }
          match node.skin {
            Some(_) => skinned_nodes = skinned_nodes + 1
            None => ()
          }
          if node.children.length() == 0 {
            leaf_nodes = leaf_nodes + 1
          }
          for child in node.children {
            frontier.push((child, depth + 1, Some(index)))
          }
        }
        None => ()
      }
    }
  }
  let signature = scene_snapshot_signature(snapshots)
  {
    scene: scene_index,
    nodes: snapshots,
    roots,
    max_depth,
    mesh_nodes,
    skinned_nodes,
    leaf_nodes,
    signature,
  }
}

///|
pub fn scene_snapshot_signature(nodes : Array[SceneSnapshotNode]) -> String {
  let parts : Array[String] = []
  for node in nodes {
    parts.push("\{node.index}:\{node.signature}")
  }
  parts.join(";")
}

///|
pub fn scene_snapshot_node_at(
  snapshot : SceneSnapshot,
  node : Int,
) -> SceneSnapshotNode? {
  for value in snapshot.nodes {
    if value.index == node {
      return Some(value)
    }
  }
  None
}

///|
pub fn scene_snapshot_leaf_indices(snapshot : SceneSnapshot) -> Array[Int] {
  snapshot.nodes
  .filter(fn(node) { node.child_count == 0 })
  .map(fn(node) { node.index })
}

///|
pub fn scene_snapshot_mesh_indices(snapshot : SceneSnapshot) -> Array[Int] {
  snapshot.nodes
  .filter(fn(node) { node.mesh is Some(_) })
  .map(fn(node) { node.index })
}

///|
pub fn scene_snapshot_skin_indices(snapshot : SceneSnapshot) -> Array[Int] {
  snapshot.nodes
  .filter(fn(node) { node.skin is Some(_) })
  .map(fn(node) { node.index })
}

///|
pub fn scene_snapshot_depth_histogram(
  snapshot : SceneSnapshot,
) -> Map[Int, Int] {
  let histogram : Map[Int, Int] = Map([])
  for node in snapshot.nodes {
    histogram[node.depth] = match histogram.get(node.depth) {
      Some(value) => value + 1
      None => 1
    }
  }
  histogram
}

///|
pub fn scene_snapshot_diff(
  before : SceneSnapshot,
  after : SceneSnapshot,
) -> SceneSnapshotDiff {
  let changes : Array[SceneSnapshotChange] = []
  let mut added = 0
  let mut removed = 0
  let mut changed = 0
  let mut unchanged = 0
  for old_node in before.nodes {
    let mut found : SceneSnapshotNode? = None
    for new_node in after.nodes {
      if new_node.index == old_node.index {
        found = Some(new_node)
        break
      }
    }
    match found {
      None => {
        removed = removed + 1
        changes.push({
          node: old_node.index,
          kind: "removed",
          before: Some(old_node.signature),
          after: None,
        })
      }
      Some(new_node) =>
        if old_node.signature == new_node.signature {
          unchanged = unchanged + 1
        } else {
          changed = changed + 1
          changes.push({
            node: old_node.index,
            kind: "changed",
            before: Some(old_node.signature),
            after: Some(new_node.signature),
          })
        }
    }
  }
  for new_node in after.nodes {
    if !before.nodes.any(fn(old_node) { old_node.index == new_node.index }) {
      added = added + 1
      changes.push({
        node: new_node.index,
        kind: "added",
        before: None,
        after: Some(new_node.signature),
      })
    }
  }
  { changes, added, removed, changed, unchanged, compatible: removed == 0 }
}

///|
pub fn scene_snapshot_diff_kind_count(
  diff : SceneSnapshotDiff,
  kind : String,
) -> Int {
  diff.changes.filter(fn(change) { change.kind == kind }).length()
}

///|
pub fn scene_snapshot_lines(snapshot : SceneSnapshot) -> Array[String] {
  [
    "scene=\{snapshot.scene}",
    "nodes=\{snapshot.nodes.length()}",
    "roots=\{snapshot.roots.length()}",
    "max_depth=\{snapshot.max_depth}",
    "mesh_nodes=\{snapshot.mesh_nodes}",
    "skinned_nodes=\{snapshot.skinned_nodes}",
    "leaf_nodes=\{snapshot.leaf_nodes}",
    "signature=\{snapshot.signature}",
  ]
}

///|
pub fn scene_snapshot_diff_lines(diff : SceneSnapshotDiff) -> Array[String] {
  [
    "added=\{diff.added}",
    "removed=\{diff.removed}",
    "changed=\{diff.changed}",
    "unchanged=\{diff.unchanged}",
    "compatible=\{diff.compatible}",
  ]
}
