///|
pub(all) enum IntegrityStatus {
  IntegrityUnknown
  IntegrityVerified
  IntegrityMismatch
  IntegrityMissing
  IntegrityInvalidRange
} derive(Debug, ToJson, Eq)

///|
pub(all) struct IntegrityRange {
  resource : Int
  offset : Int
  length : Int
  checksum : UInt
  status : IntegrityStatus
} derive(Debug, ToJson, Eq)

///|
pub(all) struct IntegrityRecord {
  id : String
  resource : Int
  expected : UInt
  actual : UInt
  bytes : Int
  status : IntegrityStatus
  message : String
} derive(Debug, ToJson, Eq)

///|
pub(all) struct IntegrityReport {
  records : Array[IntegrityRecord]
  ranges : Array[IntegrityRange]
  verified : Int
  mismatches : Int
  missing : Int
  invalid : Int
  total_bytes : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct IntegrityPolicy {
  require_checksum : Bool
  reject_mismatch : Bool
  reject_missing : Bool
  reject_invalid_range : Bool
  max_resource_bytes : Int
} derive(Debug, ToJson, Eq)

///|
pub fn integrity_status_name(status : IntegrityStatus) -> String {
  match status {
    IntegrityUnknown => "unknown"
    IntegrityVerified => "verified"
    IntegrityMismatch => "mismatch"
    IntegrityMissing => "missing"
    IntegrityInvalidRange => "invalid-range"
  }
}

///|
pub fn integrity_range(
  resource : Int,
  offset : Int,
  length : Int,
  checksum : UInt,
) -> IntegrityRange {
  { resource, offset, length, checksum, status: IntegrityUnknown }
}

///|
pub fn integrity_range_end(value : IntegrityRange) -> Int {
  value.offset + value.length
}

///|
pub fn integrity_range_valid(value : IntegrityRange, size : Int) -> Bool {
  value.resource >= 0 &&
  value.offset >= 0 &&
  value.length >= 0 &&
  integrity_range_end(value) <= size
}

///|
pub fn integrity_ranges_overlap(
  left : IntegrityRange,
  right : IntegrityRange,
) -> Bool {
  left.resource == right.resource &&
  left.offset < integrity_range_end(right) &&
  right.offset < integrity_range_end(left)
}

///|
pub fn integrity_ranges_total(ranges : Array[IntegrityRange]) -> Int {
  let mut total = 0
  for value in ranges {
    total = total + value.length
  }
  total
}

///|
pub fn integrity_checksum(data : Bytes) -> UInt {
  binary_checksum(data)
}

///|
pub fn integrity_checksum_range(data : Bytes, range : IntegrityRange) -> UInt? {
  if range.offset < 0 ||
    range.length < 0 ||
    integrity_range_end(range) > data.length() {
    return None
  }
  Some(binary_checksum_range(data, range.offset, range.length) catch { _ => 0 })
}

///|
pub fn integrity_record(
  id : String,
  resource : Int,
  expected : UInt,
  actual : UInt,
  bytes : Int,
) -> IntegrityRecord {
  let status = if bytes < 0 {
    IntegrityInvalidRange
  } else if expected == 0 {
    IntegrityUnknown
  } else if expected == actual {
    IntegrityVerified
  } else {
    IntegrityMismatch
  }
  {
    id,
    resource,
    expected,
    actual,
    bytes,
    status,
    message: integrity_status_name(status),
  }
}

///|
pub fn integrity_record_missing(id : String, resource : Int) -> IntegrityRecord {
  {
    id,
    resource,
    expected: 0,
    actual: 0,
    bytes: 0,
    status: IntegrityMissing,
    message: "resource bytes are missing",
  }
}

///|
pub fn integrity_records_for_buffers(
  buffers : Array[Bytes],
  expected : Array[UInt],
) -> Array[IntegrityRecord] {
  let records : Array[IntegrityRecord] = []
  for index, data in buffers {
    let checksum = integrity_checksum(data)
    let required = match expected.get(index) {
      Some(value) => value
      None => 0
    }
    records.push(
      integrity_record(
        "buffer[\{index}]",
        index,
        required,
        checksum,
        data.length(),
      ),
    )
  }
  for index in buffers.length()..<expected.length() {
    records.push(integrity_record_missing("buffer[\{index}]", index))
  }
  records
}

///|
pub fn integrity_ranges_for_buffer(
  data : Bytes,
  ranges : Array[IntegrityRange],
) -> Array[IntegrityRange] {
  ranges.map(fn(range) {
    match integrity_checksum_range(data, range) {
      Some(value) => { ..range, checksum: value, status: IntegrityVerified }
      None => { ..range, status: IntegrityInvalidRange }
    }
  })
}

///|
pub fn integrity_duplicate_checksum_count(
  records : Array[IntegrityRecord],
) -> Int {
  let seen : Map[UInt, Int] = Map([])
  let mut duplicates = 0
  for record in records {
    if record.expected == 0 {
      continue
    }
    let count = match seen.get(record.expected) {
      Some(value) => value + 1
      None => 1
    }
    seen[record.expected] = count
    if count > 1 {
      duplicates = duplicates + 1
    }
  }
  duplicates
}

///|
pub fn integrity_status_count(
  records : Array[IntegrityRecord],
  status : IntegrityStatus,
) -> Int {
  records.filter(fn(record) { record.status == status }).length()
}

///|
pub fn default_integrity_policy() -> IntegrityPolicy {
  {
    require_checksum: false,
    reject_mismatch: true,
    reject_missing: false,
    reject_invalid_range: true,
    max_resource_bytes: 2 * 1024 * 1024 * 1024,
  }
}

///|
pub fn integrity_report(
  records : Array[IntegrityRecord],
  ranges : Array[IntegrityRange],
  policy : IntegrityPolicy,
) -> IntegrityReport {
  let verified = integrity_status_count(records, IntegrityVerified)
  let mismatches = integrity_status_count(records, IntegrityMismatch)
  let missing = integrity_status_count(records, IntegrityMissing)
  let invalid = integrity_status_count(records, IntegrityInvalidRange)
  let violations = (policy.reject_mismatch && mismatches > 0) ||
    (policy.reject_missing && missing > 0) ||
    (policy.reject_invalid_range && invalid > 0) ||
    integrity_ranges_total(ranges) > policy.max_resource_bytes
  {
    records,
    ranges,
    verified,
    mismatches,
    missing,
    invalid,
    total_bytes: integrity_ranges_total(ranges) +
    integrity_record_bytes(records),
    valid: !violations,
  }
}

///|
pub fn integrity_compare_records(
  before : Array[IntegrityRecord],
  after : Array[IntegrityRecord],
) -> Array[String] {
  let changes : Array[String] = []
  for previous in before {
    let mut current : IntegrityRecord? = None
    for candidate in after {
      if candidate.id == previous.id {
        current = Some(candidate)
        break
      }
    }
    match current {
      Some(value) =>
        if value.status != previous.status {
          changes.push(
            "\{previous.id}: \{integrity_status_name(previous.status)} -> \{integrity_status_name(value.status)}",
          )
        }
      None => changes.push("\{previous.id}: removed")
    }
  }
  for current in after {
    if !before.any(fn(record) { record.id == current.id }) {
      changes.push("\{current.id}: added")
    }
  }
  changes
}

///|
fn integrity_record_bytes(records : Array[IntegrityRecord]) -> Int {
  let mut total = 0
  for record in records {
    total = total + record.bytes
  }
  total
}

///|
pub fn integrity_find_range(
  ranges : Array[IntegrityRange],
  resource : Int,
  offset : Int,
) -> IntegrityRange? {
  for range in ranges {
    if range.resource == resource && range.offset == offset {
      return Some(range)
    }
  }
  None
}

///|
pub fn integrity_overlaps(
  ranges : Array[IntegrityRange],
) -> Array[(IntegrityRange, IntegrityRange)] {
  let result : Array[(IntegrityRange, IntegrityRange)] = []
  for left in 0..<ranges.length() {
    let first = left + 1
    for right in first..<ranges.length() {
      match (ranges.get(left), ranges.get(right)) {
        (Some(a), Some(b)) =>
          if integrity_ranges_overlap(a, b) {
            result.push((a, b))
          }
        _ => ()
      }
    }
  }
  result
}

///|
pub fn integrity_report_lines(report : IntegrityReport) -> Array[String] {
  [
    "records=\{report.records.length()}",
    "ranges=\{report.ranges.length()}",
    "verified=\{report.verified}",
    "mismatches=\{report.mismatches}",
    "missing=\{report.missing}",
    "invalid=\{report.invalid}",
    "total_bytes=\{report.total_bytes}",
    "valid=\{report.valid}",
  ]
}
