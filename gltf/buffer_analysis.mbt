///|
/// Buffer and accessor layout analysis for zero-copy import decisions.
///
/// A valid byte range can still be inefficient: overlapping views, excessive
/// stride, unused buffers, and scattered accessors increase upload and cache
/// cost. These routines expose those trade-offs as deterministic reports.

///|
pub(all) enum BufferLayoutSeverity {
  LayoutNote
  LayoutWarning
  LayoutError
} derive(Debug, ToJson, Eq)

///|
pub(all) struct BufferViewRelation {
  left : Int
  right : Int
  same_buffer : Bool
  overlaps : Bool
  adjacent : Bool
  shared_bytes : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AccessorAudit {
  accessor : Int
  buffer_view : Int?
  component_size : Int
  component_count : Int
  element_size : Int
  stride : Int
  count : Int
  payload_bytes : Int
  padding_bytes : Int
  contiguous : Bool
  aligned : Bool
  valid : Bool
  issues : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct BufferAudit {
  buffer : Int
  declared_bytes : Int
  loaded_bytes : Int
  view_count : Int
  accessor_count : Int
  referenced_bytes : Int
  unused_bytes : Int
  overlap_bytes : Int
  utilization : Double
  valid : Bool
  issues : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct BufferLayoutReport {
  accessors : Array[AccessorAudit]
  buffers : Array[BufferAudit]
  relations : Array[BufferViewRelation]
  total_declared_bytes : Int
  total_referenced_bytes : Int
  total_padding_bytes : Int
  total_overlap_bytes : Int
  unused_buffer_count : Int
  invalid_accessor_count : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct BufferLayoutPolicy {
  max_stride : Int
  require_alignment : Bool
  reject_overlaps : Bool
  warn_unused_buffers : Bool
  max_padding_ratio : Double
} derive(Debug, ToJson, Eq)

///|
pub fn default_buffer_layout_policy() -> BufferLayoutPolicy {
  {
    max_stride: 252,
    require_alignment: true,
    reject_overlaps: false,
    warn_unused_buffers: true,
    max_padding_ratio: 0.25,
  }
}

///|
pub fn buffer_view_range(doc : GltfDocument, view_index : Int) -> BinaryRange? {
  match doc.buffer_views.get(view_index) {
    Some(view) => Some({ offset: view.byte_offset, length: view.byte_length })
    None => None
  }
}

///|
pub fn buffer_range_end(range : BinaryRange) -> Int {
  range.offset + range.length
}

///|
pub fn buffer_ranges_overlap(left : BinaryRange, right : BinaryRange) -> Bool {
  left.length > 0 &&
  right.length > 0 &&
  left.offset < buffer_range_end(right) &&
  right.offset < buffer_range_end(left)
}

///|
pub fn buffer_ranges_adjacent(left : BinaryRange, right : BinaryRange) -> Bool {
  buffer_range_end(left) == right.offset ||
  buffer_range_end(right) == left.offset
}

///|
pub fn buffer_overlap_bytes(left : BinaryRange, right : BinaryRange) -> Int {
  if !buffer_ranges_overlap(left, right) {
    0
  } else {
    let start = if left.offset > right.offset {
      left.offset
    } else {
      right.offset
    }
    let finish = if buffer_range_end(left) < buffer_range_end(right) {
      buffer_range_end(left)
    } else {
      buffer_range_end(right)
    }
    if finish > start {
      finish - start
    } else {
      0
    }
  }
}

///|
pub fn buffer_view_relation(
  doc : GltfDocument,
  left : Int,
  right : Int,
) -> BufferViewRelation {
  match (doc.buffer_views.get(left), doc.buffer_views.get(right)) {
    (Some(a), Some(b)) => {
      let same = a.buffer == b.buffer
      let left_range = { offset: a.byte_offset, length: a.byte_length }
      let right_range = { offset: b.byte_offset, length: b.byte_length }
      {
        left,
        right,
        same_buffer: same,
        overlaps: same && buffer_ranges_overlap(left_range, right_range),
        adjacent: same && buffer_ranges_adjacent(left_range, right_range),
        shared_bytes: if same {
          buffer_overlap_bytes(left_range, right_range)
        } else {
          0
        },
        valid: a.byte_offset >= 0 &&
        a.byte_length >= 0 &&
        b.byte_offset >= 0 &&
        b.byte_length >= 0,
      }
    }
    _ =>
      {
        left,
        right,
        same_buffer: false,
        overlaps: false,
        adjacent: false,
        shared_bytes: 0,
        valid: false,
      }
  }
}

///|
pub fn all_buffer_view_relations(
  doc : GltfDocument,
) -> Array[BufferViewRelation] {
  let relations : Array[BufferViewRelation] = []
  for left in 0..<doc.buffer_views.length() {
    let first_right = left + 1
    for right in first_right..<doc.buffer_views.length() {
      let relation = buffer_view_relation(doc, left, right)
      if relation.overlaps || relation.adjacent {
        relations.push(relation)
      }
    }
  }
  relations
}

///|
pub fn overlapping_buffer_view_relations(
  doc : GltfDocument,
) -> Array[BufferViewRelation] {
  all_buffer_view_relations(doc).filter(relation => relation.overlaps)
}

///|
pub fn total_buffer_overlap_bytes(doc : GltfDocument) -> Int {
  overlapping_buffer_view_relations(doc).fold(init=0, (sum, relation) => {
    sum + relation.shared_bytes
  })
}

///|
pub fn buffer_view_reference_counts(doc : GltfDocument) -> Array[Int] {
  let counts : Array[Int] = []
  for _ in doc.buffer_views {
    counts.push(0)
  }
  for accessor in doc.accessors {
    match accessor.buffer_view {
      Some(view) => if view >= 0 && view < counts.length() { counts[view] += 1 }
      None => ()
    }
  }
  for image in doc.images {
    match image.buffer_view {
      Some(view) => if view >= 0 && view < counts.length() { counts[view] += 1 }
      None => ()
    }
  }
  counts
}

///|
pub fn unused_buffer_view_indices(doc : GltfDocument) -> Array[Int] {
  let counts = buffer_view_reference_counts(doc)
  let result : Array[Int] = []
  for index, count in counts {
    if count == 0 {
      result.push(index)
    }
  }
  result
}

///|
pub fn buffer_view_buffer_indices(doc : GltfDocument) -> Array[Array[Int]] {
  let result : Array[Array[Int]] = []
  for _ in doc.buffers {
    result.push([])
  }
  for index, view in doc.buffer_views {
    if view.buffer >= 0 && view.buffer < result.length() {
      result[view.buffer].push(index)
    }
  }
  result
}

///|
pub fn buffer_reference_counts(doc : GltfDocument) -> Array[Int] {
  let counts : Array[Int] = []
  for _ in doc.buffers {
    counts.push(0)
  }
  for view in doc.buffer_views {
    if view.buffer >= 0 && view.buffer < counts.length() {
      counts[view.buffer] += 1
    }
  }
  for accessor in doc.accessors {
    match accessor.buffer_view {
      Some(view) =>
        match doc.buffer_views.get(view) {
          Some(value) =>
            if value.buffer >= 0 && value.buffer < counts.length() {
              counts[value.buffer] += 1
            }
          None => ()
        }
      None => ()
    }
  }
  counts
}

///|
pub fn unused_buffer_indices(doc : GltfDocument) -> Array[Int] {
  let counts = buffer_reference_counts(doc)
  let result : Array[Int] = []
  for index, count in counts {
    if count == 0 {
      result.push(index)
    }
  }
  result
}

///|
pub fn accessor_padding_bytes(doc : GltfDocument, accessor_index : Int) -> Int {
  let layout = accessor_layout(doc, accessor_index)
  if !layout.valid || layout.stride <= layout.element_size {
    0
  } else {
    let count = match doc.accessors.get(accessor_index) {
      Some(accessor) => accessor.count
      None => 0
    }
    (layout.stride - layout.element_size) * count
  }
}

///|
pub fn accessor_is_contiguous(doc : GltfDocument, accessor_index : Int) -> Bool {
  let layout = accessor_layout(doc, accessor_index)
  layout.valid && layout.stride == layout.element_size
}

///|
pub fn accessor_payload_bytes(doc : GltfDocument, accessor_index : Int) -> Int {
  match doc.accessors.get(accessor_index) {
    Some(accessor) => accessor_element_size(accessor) * accessor.count
    None => 0
  }
}

///|
pub fn accessor_data_density(
  doc : GltfDocument,
  accessor_index : Int,
) -> Double {
  let payload = accessor_payload_bytes(doc, accessor_index)
  let padding = accessor_padding_bytes(doc, accessor_index)
  if payload + padding == 0 {
    0.0
  } else {
    payload.to_double() / (payload + padding).to_double()
  }
}

///|
pub fn accessor_audit(
  doc : GltfDocument,
  accessor_index : Int,
  policy : BufferLayoutPolicy,
) -> AccessorAudit {
  match doc.accessors.get(accessor_index) {
    None =>
      {
        accessor: accessor_index,
        buffer_view: None,
        component_size: 0,
        component_count: 0,
        element_size: 0,
        stride: 0,
        count: 0,
        payload_bytes: 0,
        padding_bytes: 0,
        contiguous: false,
        aligned: false,
        valid: false,
        issues: ["accessor index is outside the document"],
      }
    Some(accessor) => {
      let layout = accessor_layout(doc, accessor_index)
      let issues : Array[String] = []
      if policy.require_alignment &&
        layout.first_byte % accessor_alignment(accessor.component_type) != 0 {
        issues.push("accessor start is not aligned to its component type")
      }
      if layout.stride > policy.max_stride {
        issues.push("accessor stride exceeds the configured maximum")
      }
      if layout.stride < layout.element_size {
        issues.push("accessor stride is smaller than the element")
      }
      for problem in layout.problems {
        issues.push(problem)
      }
      {
        accessor: accessor_index,
        buffer_view: accessor.buffer_view,
        component_size: component_info(accessor.component_type).size,
        component_count: accessor_component_count(accessor.accessor_type),
        element_size: layout.element_size,
        stride: layout.stride,
        count: accessor.count,
        payload_bytes: accessor_payload_bytes(doc, accessor_index),
        padding_bytes: accessor_padding_bytes(doc, accessor_index),
        contiguous: layout.stride == layout.element_size,
        aligned: layout.first_byte % accessor_alignment(accessor.component_type) ==
        0,
        valid: issues.length() == 0,
        issues,
      }
    }
  }
}

///|
pub fn all_accessor_audits(
  doc : GltfDocument,
  policy : BufferLayoutPolicy,
) -> Array[AccessorAudit] {
  let result : Array[AccessorAudit] = []
  for index in 0..<doc.accessors.length() {
    result.push(accessor_audit(doc, index, policy))
  }
  result
}

///|
pub fn buffer_view_accessor_indices(
  doc : GltfDocument,
  view_index : Int,
) -> Array[Int] {
  let result : Array[Int] = []
  for accessor, value in doc.accessors {
    if value.buffer_view == Some(view_index) {
      result.push(accessor)
    }
  }
  result
}

///|
pub fn buffer_view_payload_bytes(doc : GltfDocument, view_index : Int) -> Int {
  buffer_view_accessor_indices(doc, view_index).fold(init=0, (sum, accessor) => {
    sum + accessor_payload_bytes(doc, accessor)
  })
}

///|
pub fn buffer_view_padding_bytes(doc : GltfDocument, view_index : Int) -> Int {
  buffer_view_accessor_indices(doc, view_index).fold(init=0, (sum, accessor) => {
    sum + accessor_padding_bytes(doc, accessor)
  })
}

///|
pub fn buffer_audit(
  doc : GltfDocument,
  buffer_index : Int,
  policy : BufferLayoutPolicy,
) -> BufferAudit {
  let views = buffer_view_buffer_indices(doc).get(buffer_index)
  match (doc.buffers.get(buffer_index), views) {
    (Some(buffer), Some(view_indices)) => {
      let accessor_count = view_indices.fold(init=0, (sum, view) => {
        sum + buffer_view_accessor_indices(doc, view).length()
      })
      let referenced = view_indices.fold(init=0, (sum, view) => {
        sum + buffer_view_payload_bytes(doc, view)
      })
      let padding = view_indices.fold(init=0, (sum, view) => {
        sum + buffer_view_padding_bytes(doc, view)
      })
      let relations = overlapping_buffer_view_relations(doc)
      let overlap = relations.fold(init=0, (sum, relation) => {
        match doc.buffer_views.get(relation.left) {
          Some(view) =>
            if view.buffer == buffer_index {
              sum + relation.shared_bytes
            } else {
              sum
            }
          None => sum
        }
      })
      let unused = if buffer.byte_length > referenced + padding {
        buffer.byte_length - referenced - padding
      } else {
        0
      }
      let issues : Array[String] = []
      if unused > 0 && policy.warn_unused_buffers {
        issues.push("buffer contains unused declared bytes")
      }
      if buffer.byte_length < 0 {
        issues.push("buffer has a negative declared length")
      }
      {
        buffer: buffer_index,
        declared_bytes: buffer.byte_length,
        loaded_bytes: 0,
        view_count: view_indices.length(),
        accessor_count,
        referenced_bytes: referenced,
        unused_bytes: unused,
        overlap_bytes: overlap,
        utilization: if buffer.byte_length <= 0 {
          0.0
        } else {
          referenced.to_double() / buffer.byte_length.to_double()
        },
        valid: issues.length() == 0,
        issues,
      }
    }
    _ =>
      {
        buffer: buffer_index,
        declared_bytes: 0,
        loaded_bytes: 0,
        view_count: 0,
        accessor_count: 0,
        referenced_bytes: 0,
        unused_bytes: 0,
        overlap_bytes: 0,
        utilization: 0.0,
        valid: false,
        issues: ["buffer index is outside the document"],
      }
  }
}

///|
pub fn all_buffer_audits(
  doc : GltfDocument,
  policy : BufferLayoutPolicy,
) -> Array[BufferAudit] {
  let result : Array[BufferAudit] = []
  for index in 0..<doc.buffers.length() {
    result.push(buffer_audit(doc, index, policy))
  }
  result
}

///|
pub fn buffer_layout_report(
  doc : GltfDocument,
  policy : BufferLayoutPolicy,
) -> BufferLayoutReport {
  let accessors = all_accessor_audits(doc, policy)
  let buffers = all_buffer_audits(doc, policy)
  let relations = all_buffer_view_relations(doc)
  let declared = buffers.fold(init=0, (sum, buffer) => {
    sum + buffer.declared_bytes
  })
  let referenced = buffers.fold(init=0, (sum, buffer) => {
    sum + buffer.referenced_bytes
  })
  let padding = accessors.fold(init=0, (sum, accessor) => {
    sum + accessor.padding_bytes
  })
  let overlaps = relations.fold(init=0, (sum, relation) => {
    sum + relation.shared_bytes
  })
  let invalid = accessors.fold(init=0, (count, accessor) => {
    if accessor.valid {
      count
    } else {
      count + 1
    }
  })
  let unused = buffers.fold(init=0, (count, buffer) => {
    if buffer.unused_bytes > 0 {
      count + 1
    } else {
      count
    }
  })
  {
    accessors,
    buffers,
    relations,
    total_declared_bytes: declared,
    total_referenced_bytes: referenced,
    total_padding_bytes: padding,
    total_overlap_bytes: overlaps,
    unused_buffer_count: unused,
    invalid_accessor_count: invalid,
    valid: invalid == 0 && (!policy.reject_overlaps || overlaps == 0),
  }
}

///|
pub fn buffer_layout_efficiency(report : BufferLayoutReport) -> Double {
  if report.total_declared_bytes <= 0 {
    0.0
  } else {
    report.total_referenced_bytes.to_double() /
    report.total_declared_bytes.to_double()
  }
}

///|
pub fn buffer_layout_has_overlap(report : BufferLayoutReport) -> Bool {
  report.total_overlap_bytes > 0
}

///|
pub fn buffer_layout_has_padding(report : BufferLayoutReport) -> Bool {
  report.total_padding_bytes > 0
}

///|
pub fn buffer_layout_summary_lines(
  report : BufferLayoutReport,
) -> Array[String] {
  [
    "declared_bytes=\{report.total_declared_bytes}, referenced_bytes=\{report.total_referenced_bytes}",
    "padding_bytes=\{report.total_padding_bytes}, overlap_bytes=\{report.total_overlap_bytes}",
    "unused_buffers=\{report.unused_buffer_count}, invalid_accessors=\{report.invalid_accessor_count}",
    "efficiency=\{buffer_layout_efficiency(report)}, valid=\{report.valid}",
  ]
}
