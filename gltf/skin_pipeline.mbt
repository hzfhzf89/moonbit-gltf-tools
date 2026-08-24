///|
/// Skin and joint validation for production import pipelines.
///
/// A skin is a cross-reference between a node hierarchy, a joint list, an
/// optional inverse-bind accessor, and per-vertex JOINTS/WEIGHTS attributes.
/// This module makes those constraints inspectable without coupling the
/// library to a renderer or a particular GPU skinning layout.

///|
pub(all) struct SkinJointInfo {
  skin_index : Int
  joint_slot : Int
  node : Int
  parent_joint_slot : Int?
  depth : Int
  path : String
  has_inverse_bind_matrix : Bool
  world_transform : Mat4
} derive(Debug, ToJson, Eq)

///|
pub(all) struct WeightSummary {
  vertex_count : Int
  influence_slots : Int
  normalized_vertex_count : Int
  non_normalized_vertex_count : Int
  zero_weight_vertex_count : Int
  negative_weight_count : Int
  over_one_weight_count : Int
  max_influences_per_vertex : Int
  average_weight_sum : Double
  min_weight_sum : Double
  max_weight_sum : Double
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SkinIssue {
  skin : Int
  severity : DiagnosticSeverity
  code : String
  path : String
  message : String
  hint : String?
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SkinReport {
  skin_index : Int
  name : String?
  joint_count : Int
  root_joint : Int?
  max_depth : Int
  duplicate_joint_count : Int
  unreachable_joint_count : Int
  invalid_joint_count : Int
  inverse_bind_accessor : Int?
  inverse_bind_matrix_count : Int
  joints : Array[SkinJointInfo]
  weight_summary : WeightSummary
  issues : Array[SkinIssue]
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SkinBudget {
  max_joints : Int
  max_influences : Int
  max_depth : Int
  require_normalized_weights : Bool
  allow_zero_weight_vertices : Bool
  max_weight_error : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct SkinBudgetResult {
  passed : Bool
  violations : Array[String]
  joint_overage : Int
  influence_overage : Int
  depth_overage : Int
  weight_error : Double
} derive(Debug, ToJson, Eq)

///|
pub fn default_skin_budget() -> SkinBudget {
  {
    max_joints: 256,
    max_influences: 4,
    max_depth: 128,
    require_normalized_weights: true,
    allow_zero_weight_vertices: false,
    max_weight_error: 0.001,
  }
}

///|
pub fn mobile_skin_budget() -> SkinBudget {
  {
    max_joints: 64,
    max_influences: 4,
    max_depth: 64,
    require_normalized_weights: true,
    allow_zero_weight_vertices: false,
    max_weight_error: 0.0001,
  }
}

///|
fn skin_issue(
  skin : Int,
  severity : DiagnosticSeverity,
  code : String,
  path : String,
  message : String,
  hint : String?,
) -> SkinIssue {
  { skin, severity, code, path, message, hint }
}

///|
pub fn skin_name(doc : GltfDocument, skin_index : Int) -> String? {
  match doc.skins.get(skin_index) {
    Some(skin) => skin.name
    None => None
  }
}

///|
pub fn skin_joint_count(doc : GltfDocument, skin_index : Int) -> Int {
  match doc.skins.get(skin_index) {
    Some(skin) => skin.joints.length()
    None => 0
  }
}

///|
pub fn skin_joint_node(
  doc : GltfDocument,
  skin_index : Int,
  joint_slot : Int,
) -> Int? {
  match doc.skins.get(skin_index) {
    Some(skin) => skin.joints.get(joint_slot)
    None => None
  }
}

///|
pub fn skin_joint_slots(doc : GltfDocument, skin_index : Int) -> Map[Int, Int] {
  let slots : Map[Int, Int] = Map([])
  match doc.skins.get(skin_index) {
    Some(skin) =>
      for slot, node in skin.joints {
        if !slots.contains(node) {
          slots[node] = slot
        }
      }
    None => ()
  }
  slots
}

///|
pub fn skin_duplicate_joint_count(doc : GltfDocument, skin_index : Int) -> Int {
  match doc.skins.get(skin_index) {
    None => 0
    Some(skin) => {
      let seen : Map[Int, Bool] = Map([])
      let mut duplicates = 0
      for node in skin.joints {
        if seen.contains(node) {
          duplicates += 1
        } else {
          seen[node] = true
        }
      }
      duplicates
    }
  }
}

///|
pub fn skin_root_joint_slot(doc : GltfDocument, skin_index : Int) -> Int? {
  match doc.skins.get(skin_index) {
    None => None
    Some(skin) => {
      let slots = skin_joint_slots(doc, skin_index)
      let parents = node_parent_indices(doc)
      let mut result : Int? = None
      for slot, node in skin.joints {
        let mut parent_is_joint = false
        match parents.get(node) {
          Some(parent) => parent_is_joint = slots.contains(parent)
          None => ()
        }
        if !parent_is_joint && result is None {
          result = Some(slot)
        }
      }
      result
    }
  }
}

///|
pub fn skin_joint_parent_slot(
  doc : GltfDocument,
  skin_index : Int,
  joint_slot : Int,
) -> Int? {
  match skin_joint_node(doc, skin_index, joint_slot) {
    None => None
    Some(node) =>
      match node_parent_indices(doc).get(node) {
        Some(parent) => skin_joint_slots(doc, skin_index).get(parent)
        None => None
      }
  }
}

///|
pub fn skin_joint_depth(
  doc : GltfDocument,
  skin_index : Int,
  joint_slot : Int,
) -> Int {
  let mut current : Int? = Some(joint_slot)
  let mut depth = 0
  let seen : Map[Int, Bool] = Map([])
  while current is Some(slot) {
    if seen.contains(slot) {
      return depth
    }
    seen[slot] = true
    depth += 1
    current = skin_joint_parent_slot(doc, skin_index, slot)
  }
  depth
}

///|
pub fn skin_max_depth(doc : GltfDocument, skin_index : Int) -> Int {
  let mut maximum = 0
  for slot in 0..<skin_joint_count(doc, skin_index) {
    let depth = skin_joint_depth(doc, skin_index, slot)
    if depth > maximum {
      maximum = depth
    }
  }
  maximum
}

///|
pub fn skin_joint_path(
  doc : GltfDocument,
  skin_index : Int,
  joint_slot : Int,
) -> String {
  match skin_joint_node(doc, skin_index, joint_slot) {
    None => "invalid-joint[\{joint_slot}]"
    Some(node) => scene_node_path_text(scene_node_path(doc, None, node))
  }
}

///|
pub fn skin_joint_world_transform(
  doc : GltfDocument,
  skin_index : Int,
  joint_slot : Int,
) -> Mat4 {
  match skin_joint_node(doc, skin_index, joint_slot) {
    Some(node) => node_world_transform(doc, node)
    None => identity_mat4()
  }
}

///|
pub fn skin_joint_infos(
  doc : GltfDocument,
  skin_index : Int,
) -> Array[SkinJointInfo] {
  let result : Array[SkinJointInfo] = []
  match doc.skins.get(skin_index) {
    None => result
    Some(skin) => {
      for slot, node in skin.joints {
        result.push({
          skin_index,
          joint_slot: slot,
          node,
          parent_joint_slot: skin_joint_parent_slot(doc, skin_index, slot),
          depth: skin_joint_depth(doc, skin_index, slot),
          path: skin_joint_path(doc, skin_index, slot),
          has_inverse_bind_matrix: skin.inverse_bind_matrices is Some(_),
          world_transform: skin_joint_world_transform(doc, skin_index, slot),
        })
      }
      result
    }
  }
}

///|
pub fn decode_skin_inverse_bind_matrices(
  doc : GltfDocument,
  asset : BinaryAsset,
  skin_index : Int,
) -> Array[Mat4] {
  match doc.skins.get(skin_index) {
    None => []
    Some(skin) =>
      match skin.inverse_bind_matrices {
        None => []
        Some(accessor_index) => {
          let decoded = decode_accessor(doc, asset, accessor_index)
          if !decoded.valid || decoded.component_count != 16 {
            []
          } else {
            let matrices : Array[Mat4] = []
            for index in 0..<decoded.count {
              let values = decoded_accessor_element(decoded, index)
              if values.length() == 16 {
                matrices.push({ values, })
              }
            }
            matrices
          }
        }
      }
  }
}

///|
pub fn skin_inverse_bind_matrix(
  doc : GltfDocument,
  asset : BinaryAsset,
  skin_index : Int,
  joint_slot : Int,
) -> Mat4 {
  match
    decode_skin_inverse_bind_matrices(doc, asset, skin_index).get(joint_slot) {
    Some(matrix) => matrix
    None => identity_mat4()
  }
}

///|
pub fn skin_joint_matrix(
  doc : GltfDocument,
  asset : BinaryAsset,
  skin_index : Int,
  joint_slot : Int,
) -> Mat4 {
  mat4_mul(
    skin_joint_world_transform(doc, skin_index, joint_slot),
    skin_inverse_bind_matrix(doc, asset, skin_index, joint_slot),
  )
}

///|
pub fn skin_joint_matrices(
  doc : GltfDocument,
  asset : BinaryAsset,
  skin_index : Int,
) -> Array[Mat4] {
  let matrices : Array[Mat4] = []
  for slot in 0..<skin_joint_count(doc, skin_index) {
    matrices.push(skin_joint_matrix(doc, asset, skin_index, slot))
  }
  matrices
}

///|
fn weight_value_is_valid(value : Double) -> Bool {
  value == value && value != 1.0 / 0.0 && value != -1.0 / 0.0
}

///|
pub fn weights_are_normalized(
  values : Array[Double],
  tolerance? : Double = 0.001,
) -> Bool {
  let sum = values.fold(init=0.0, (total, value) => total + value)
  Double::abs(sum - 1.0) <= tolerance
}

///|
pub fn normalize_weights(values : Array[Double]) -> Array[Double] {
  let positive : Array[Double] = []
  let mut sum = 0.0
  for value in values {
    let clamped = if value < 0.0 { 0.0 } else { value }
    positive.push(clamped)
    sum += clamped
  }
  if sum <= 0.0 {
    positive
  } else {
    positive.map(value => value / sum)
  }
}

///|
pub fn weight_sum(values : Array[Double]) -> Double {
  values.fold(init=0.0, (sum, value) => sum + value)
}

///|
pub fn weight_max(values : Array[Double]) -> Double {
  values.fold(init=0.0, (maximum, value) => {
    if value > maximum {
      value
    } else {
      maximum
    }
  })
}

///|
pub fn weight_nonzero_count(values : Array[Double]) -> Int {
  values.fold(init=0, (count, value) => {
    if value > 0.0 {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn weight_negative_count(values : Array[Double]) -> Int {
  values.fold(init=0, (count, value) => {
    if value < 0.0 {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn weight_over_one_count(values : Array[Double]) -> Int {
  values.fold(init=0, (count, value) => {
    if value > 1.0 {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn skin_weight_summary(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
) -> WeightSummary {
  let weights = match primitive.attributes.get("WEIGHTS_0") {
    Some(accessor) => decode_accessor_normalized(doc, asset, accessor)
    None =>
      {
        accessor_index: -1,
        count: 0,
        component_count: 0,
        values: [],
        valid: false,
        errors: ["WEIGHTS_0 is missing"],
      }
  }
  let mut normalized = 0
  let mut non_normalized = 0
  let mut zero = 0
  let mut negative = 0
  let mut over_one = 0
  let mut maximum_influences = 0
  let mut total_sum = 0.0
  let mut minimum_sum = 0.0
  let mut maximum_sum = 0.0
  for vertex in 0..<weights.count {
    let values = decoded_accessor_element(weights, vertex)
    for value in values {
      if !weight_value_is_valid(value) {
        negative += 1
      }
    }
    let sum = weight_sum(values)
    let nonzero = weight_nonzero_count(values)
    if nonzero > maximum_influences {
      maximum_influences = nonzero
    }
    if sum <= 0.0000001 {
      zero += 1
    }
    if weights_are_normalized(values) {
      normalized += 1
    } else {
      non_normalized += 1
    }
    negative += weight_negative_count(values)
    over_one += weight_over_one_count(values)
    total_sum += sum
    if vertex == 0 || sum < minimum_sum {
      minimum_sum = sum
    }
    if sum > maximum_sum {
      maximum_sum = sum
    }
  }
  {
    vertex_count: weights.count,
    influence_slots: weights.component_count,
    normalized_vertex_count: normalized,
    non_normalized_vertex_count: non_normalized,
    zero_weight_vertex_count: zero,
    negative_weight_count: negative,
    over_one_weight_count: over_one,
    max_influences_per_vertex: maximum_influences,
    average_weight_sum: if weights.count == 0 {
      0.0
    } else {
      total_sum / weights.count.to_double()
    },
    min_weight_sum: minimum_sum,
    max_weight_sum: maximum_sum,
    valid: weights.valid && negative == 0,
  }
}

///|
pub fn primitive_joint_indices(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
) -> Array[Int] {
  match primitive.attributes.get("JOINTS_0") {
    None => []
    Some(accessor) => decode_index_values(doc, asset, accessor)
  }
}

///|
pub fn primitive_influence_count(
  doc : GltfDocument,
  asset : BinaryAsset,
  primitive : GltfPrimitive,
) -> Int {
  ignore(asset)
  match primitive.attributes.get("WEIGHTS_0") {
    None => 0
    Some(accessor) =>
      match doc.accessors.get(accessor) {
        Some(value) => accessor_component_count(value.accessor_type)
        None => 0
      }
  }
}

///|
pub fn skin_used_by_mesh(doc : GltfDocument, skin_index : Int) -> Array[Int] {
  let meshes : Array[Int] = []
  for node in doc.nodes {
    if node.skin == Some(skin_index) {
      match node.mesh {
        Some(mesh) => if !meshes.contains(mesh) { meshes.push(mesh) }
        None => ()
      }
    }
  }
  meshes
}

///|
pub fn skin_used_by_node(doc : GltfDocument, skin_index : Int) -> Array[Int] {
  let nodes : Array[Int] = []
  for index, node in doc.nodes {
    if node.skin == Some(skin_index) {
      nodes.push(index)
    }
  }
  nodes
}

///|
pub fn skin_issue_count(
  report : SkinReport,
  severity : DiagnosticSeverity,
) -> Int {
  report.issues.fold(init=0, (count, issue) => {
    if issue.severity == severity {
      count + 1
    } else {
      count
    }
  })
}

///|
fn empty_weight_summary(valid : Bool) -> WeightSummary {
  {
    vertex_count: 0,
    influence_slots: 0,
    normalized_vertex_count: 0,
    non_normalized_vertex_count: 0,
    zero_weight_vertex_count: 0,
    negative_weight_count: 0,
    over_one_weight_count: 0,
    max_influences_per_vertex: 0,
    average_weight_sum: 0.0,
    min_weight_sum: 0.0,
    max_weight_sum: 0.0,
    valid,
  }
}

///|
fn merge_weight_summaries(
  left : WeightSummary,
  right : WeightSummary,
) -> WeightSummary {
  let vertex_count = left.vertex_count + right.vertex_count
  let min_weight_sum = if left.vertex_count == 0 {
    right.min_weight_sum
  } else if right.vertex_count == 0 {
    left.min_weight_sum
  } else if left.min_weight_sum < right.min_weight_sum {
    left.min_weight_sum
  } else {
    right.min_weight_sum
  }
  {
    vertex_count,
    influence_slots: if left.influence_slots > right.influence_slots {
      left.influence_slots
    } else {
      right.influence_slots
    },
    normalized_vertex_count: left.normalized_vertex_count +
    right.normalized_vertex_count,
    non_normalized_vertex_count: left.non_normalized_vertex_count +
    right.non_normalized_vertex_count,
    zero_weight_vertex_count: left.zero_weight_vertex_count +
    right.zero_weight_vertex_count,
    negative_weight_count: left.negative_weight_count +
    right.negative_weight_count,
    over_one_weight_count: left.over_one_weight_count +
    right.over_one_weight_count,
    max_influences_per_vertex: if left.max_influences_per_vertex >
      right.max_influences_per_vertex {
      left.max_influences_per_vertex
    } else {
      right.max_influences_per_vertex
    },
    average_weight_sum: if vertex_count == 0 {
      0.0
    } else {
      (
        left.average_weight_sum * left.vertex_count.to_double() +
        right.average_weight_sum * right.vertex_count.to_double()
      ) /
      vertex_count.to_double()
    },
    min_weight_sum,
    max_weight_sum: if left.max_weight_sum > right.max_weight_sum {
      left.max_weight_sum
    } else {
      right.max_weight_sum
    },
    valid: left.valid && right.valid,
  }
}

///|
fn skin_weight_summary_for_skin(
  doc : GltfDocument,
  asset : BinaryAsset,
  skin_index : Int,
) -> WeightSummary {
  let mut result = empty_weight_summary(true)
  let mut found = false
  for node in doc.nodes {
    if node.skin == Some(skin_index) {
      match node.mesh {
        None => ()
        Some(mesh_index) =>
          match doc.meshes.get(mesh_index) {
            None => ()
            Some(mesh) =>
              for primitive in mesh.primitives {
                match primitive.attributes.get("WEIGHTS_0") {
                  None => ()
                  Some(_) => {
                    let summary = skin_weight_summary(doc, asset, primitive)
                    result = if found {
                      merge_weight_summaries(result, summary)
                    } else {
                      summary
                    }
                    found = true
                  }
                }
              }
          }
      }
    }
  }
  result
}

///|
pub fn skin_report(
  doc : GltfDocument,
  asset : BinaryAsset,
  skin_index : Int,
) -> SkinReport {
  match doc.skins.get(skin_index) {
    None =>
      {
        skin_index,
        name: None,
        joint_count: 0,
        root_joint: None,
        max_depth: 0,
        duplicate_joint_count: 0,
        unreachable_joint_count: 0,
        invalid_joint_count: 1,
        inverse_bind_accessor: None,
        inverse_bind_matrix_count: 0,
        joints: [],
        weight_summary: {
          vertex_count: 0,
          influence_slots: 0,
          normalized_vertex_count: 0,
          non_normalized_vertex_count: 0,
          zero_weight_vertex_count: 0,
          negative_weight_count: 0,
          over_one_weight_count: 0,
          max_influences_per_vertex: 0,
          average_weight_sum: 0.0,
          min_weight_sum: 0.0,
          max_weight_sum: 0.0,
          valid: false,
        },
        issues: [
          skin_issue(
            skin_index,
            Error,
            "INVALID_SKIN",
            "skins[\{skin_index}]",
            "skin index is outside the document",
            None,
          ),
        ],
        valid: false,
      }
    Some(skin) => {
      let mut invalid_joint_count = 0
      let mut unreachable_count = 0
      let issues : Array[SkinIssue] = []
      for slot, node in skin.joints {
        if node < 0 || node >= doc.nodes.length() {
          invalid_joint_count += 1
          issues.push(
            skin_issue(
              skin_index,
              Error,
              "INVALID_JOINT",
              "skins[\{skin_index}].joints[\{slot}]",
              "joint node index is outside the document",
              None,
            ),
          )
        }
        if node >= 0 &&
          node < doc.nodes.length() &&
          node_ancestors(doc, node).length() == 0 &&
          node_parent_indices(doc).get(node) is None {
          unreachable_count += 1
        }
      }
      let duplicate = skin_duplicate_joint_count(doc, skin_index)
      if duplicate > 0 {
        issues.push(
          skin_issue(
            skin_index,
            Error,
            "DUPLICATE_JOINT",
            "skins[\{skin_index}].joints",
            "skin contains duplicate joint nodes",
            Some("deduplicate the joint list in the exporter"),
          ),
        )
      }
      let matrices = decode_skin_inverse_bind_matrices(doc, asset, skin_index)
      match skin.inverse_bind_matrices {
        Some(_) =>
          if matrices.length() != skin.joints.length() {
            issues.push(
              skin_issue(
                skin_index,
                Error,
                "INVERSE_BIND_COUNT",
                "skins[\{skin_index}].inverseBindMatrices",
                "inverse bind matrix count does not match joint count",
                None,
              ),
            )
          }
        None => ()
      }
      if skin.joints.length() == 0 {
        issues.push(
          skin_issue(
            skin_index,
            Warning,
            "EMPTY_SKIN",
            "skins[\{skin_index}].joints",
            "skin has no joints",
            Some("remove unused skin data"),
          ),
        )
      }
      {
        skin_index,
        name: skin.name,
        joint_count: skin.joints.length(),
        root_joint: skin_root_joint_slot(doc, skin_index),
        max_depth: skin_max_depth(doc, skin_index),
        duplicate_joint_count: duplicate,
        unreachable_joint_count: unreachable_count,
        invalid_joint_count,
        inverse_bind_accessor: skin.inverse_bind_matrices,
        inverse_bind_matrix_count: matrices.length(),
        joints: skin_joint_infos(doc, skin_index),
        weight_summary: skin_weight_summary_for_skin(doc, asset, skin_index),
        issues,
        valid: issues.fold(init=true, (passed, issue) => {
          passed && issue.severity != Error
        }),
      }
    }
  }
}

///|
pub fn all_skin_reports(
  doc : GltfDocument,
  asset : BinaryAsset,
) -> Array[SkinReport] {
  let reports : Array[SkinReport] = []
  for index in 0..<doc.skins.length() {
    reports.push(skin_report(doc, asset, index))
  }
  reports
}

///|
pub fn skin_budget_result(
  reports : Array[SkinReport],
  budget : SkinBudget,
) -> SkinBudgetResult {
  let mut joint_overage = 0
  let mut depth_overage = 0
  let mut influence_overage = 0
  let mut weight_error = 0.0
  let violations : Array[String] = []
  for report in reports {
    if report.joint_count > budget.max_joints {
      let overage = report.joint_count - budget.max_joints
      if overage > joint_overage {
        joint_overage = overage
      }
    }
    if report.max_depth > budget.max_depth {
      let overage = report.max_depth - budget.max_depth
      if overage > depth_overage {
        depth_overage = overage
      }
    }
    if report.weight_summary.max_influences_per_vertex > budget.max_influences {
      let overage = report.weight_summary.max_influences_per_vertex -
        budget.max_influences
      if overage > influence_overage {
        influence_overage = overage
      }
    }
    let error = Double::abs(report.weight_summary.average_weight_sum - 1.0)
    if error > weight_error {
      weight_error = error
    }
  }
  if joint_overage > 0 {
    violations.push("joint budget exceeded by \{joint_overage}")
  }
  if influence_overage > 0 {
    violations.push("vertex influence budget exceeded by \{influence_overage}")
  }
  if depth_overage > 0 {
    violations.push("skeleton depth budget exceeded by \{depth_overage}")
  }
  if budget.require_normalized_weights && weight_error > budget.max_weight_error {
    violations.push(
      "skin weights are not normalized within the configured tolerance",
    )
  }
  if !budget.allow_zero_weight_vertices {
    for report in reports {
      if report.weight_summary.zero_weight_vertex_count > 0 {
        violations.push("skin contains zero-weight vertices")
      }
    }
  }
  {
    passed: violations.length() == 0,
    violations,
    joint_overage,
    influence_overage,
    depth_overage,
    weight_error,
  }
}

///|
pub fn skin_report_summary_lines(report : SkinReport) -> Array[String] {
  [
    "skin=\{report.skin_index}, joints=\{report.joint_count}, root=\{Repr(report.root_joint)}",
    "depth=\{report.max_depth}, duplicate_joints=\{report.duplicate_joint_count}",
    "inverse_bind_matrices=\{report.inverse_bind_matrix_count}",
    "issues=\{report.issues.length()}, valid=\{report.valid}",
  ]
}
