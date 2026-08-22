///|
pub(all) enum AttributeValidationSeverity {
  AttributeInfo
  AttributeWarning
  AttributeError
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AttributeValidationIssue {
  attribute : String
  severity : AttributeValidationSeverity
  code : String
  message : String
  index : Int?
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AttributeValidationReport {
  vertex_count : Int
  attributes : Array[String]
  issues : Array[AttributeValidationIssue]
  valid : Bool
  complete : Bool
  score : Double
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AttributeValidationPolicy {
  require_position : Bool
  require_consistent_count : Bool
  require_finite : Bool
  allow_unknown : Bool
  max_texcoord_set : Int
} derive(Debug, ToJson, Eq)

///|
pub fn attribute_validation_severity_name(
  value : AttributeValidationSeverity,
) -> String {
  match value {
    AttributeInfo => "info"
    AttributeWarning => "warning"
    AttributeError => "error"
  }
}

///|
pub fn default_attribute_validation_policy() -> AttributeValidationPolicy {
  {
    require_position: true,
    require_consistent_count: true,
    require_finite: true,
    allow_unknown: true,
    max_texcoord_set: 8,
  }
}

///|
pub fn attribute_issue(
  attribute : String,
  severity : AttributeValidationSeverity,
  code : String,
  message : String,
  index : Int?,
) -> AttributeValidationIssue {
  { attribute, severity, code, message, index }
}

///|
pub fn attribute_name_is_known(name : String) -> Bool {
  name == "POSITION" ||
  name == "NORMAL" ||
  name == "TANGENT" ||
  name == "COLOR_0" ||
  name.has_prefix("TEXCOORD_") ||
  name.has_prefix("JOINTS_") ||
  name.has_prefix("WEIGHTS_")
}

///|
pub fn attribute_name_is_texcoord(name : String) -> Bool {
  name.has_prefix("TEXCOORD_")
}

///|
pub fn attribute_name_set(name : String) -> Int? {
  match name {
    "TEXCOORD_0" => Some(0)
    "TEXCOORD_1" => Some(1)
    "TEXCOORD_2" => Some(2)
    "TEXCOORD_3" => Some(3)
    "TEXCOORD_4" => Some(4)
    "TEXCOORD_5" => Some(5)
    "TEXCOORD_6" => Some(6)
    "TEXCOORD_7" => Some(7)
    "TEXCOORD_8" => Some(8)
    _ => None
  }
}

///|
pub fn attribute_name_is_finite(name : String) -> Bool {
  name.length() > 0 && name != "POSITION_"
}

///|
pub fn attribute_names_sorted(attributes : Map[String, Int]) -> Array[String] {
  let result : Array[String] = []
  for name, _ in attributes {
    result.push(name)
  }
  for pass in 0..<result.length() {
    let limit = result.length() - pass - 1
    for index in 0..<limit {
      if result[index] > result[index + 1] {
        let old = result[index]
        result[index] = result[index + 1]
        result[index + 1] = old
      }
    }
  }
  result
}

///|
pub fn attribute_count_map(
  attributes : Map[String, Int],
  accessors : Array[GltfAccessor],
) -> Map[String, Int] {
  let result : Map[String, Int] = Map([])
  for name, accessor_index in attributes {
    match accessors.get(accessor_index) {
      Some(accessor) => result[name] = accessor.count
      None => result[name] = -1
    }
  }
  result
}

///|
pub fn attribute_validation_report(
  attributes : Map[String, Int],
  accessors : Array[GltfAccessor],
  policy : AttributeValidationPolicy,
) -> AttributeValidationReport {
  let names = attribute_names_sorted(attributes)
  let counts = attribute_count_map(attributes, accessors)
  let issues : Array[AttributeValidationIssue] = []
  let vertex_count = match counts.get("POSITION") {
    Some(value) => value
    None => 0
  }
  if policy.require_position && !attributes.contains("POSITION") {
    issues.push(
      attribute_issue(
        "POSITION",
        AttributeError,
        "missing-position",
        "POSITION attribute is required",
        None,
      ),
    )
  }
  for name in names {
    match counts.get(name) {
      None =>
        issues.push(
          attribute_issue(
            name,
            AttributeError,
            "missing-accessor",
            "attribute accessor is missing",
            None,
          ),
        )
      Some(count) => {
        if count < 0 {
          issues.push(
            attribute_issue(
              name,
              AttributeError,
              "invalid-accessor",
              "attribute accessor index is invalid",
              None,
            ),
          )
        }
        if policy.require_consistent_count &&
          vertex_count > 0 &&
          count >= 0 &&
          count != vertex_count {
          issues.push(
            attribute_issue(
              name,
              AttributeError,
              "count-mismatch",
              "attribute count differs from POSITION",
              None,
            ),
          )
        }
        match attribute_name_set(name) {
          Some(set) =>
            if set > policy.max_texcoord_set {
              issues.push(
                attribute_issue(
                  name,
                  AttributeWarning,
                  "texcoord-set",
                  "texture coordinate set is above policy",
                  Some(set),
                ),
              )
            }
          None => ()
        }
        if !policy.allow_unknown && !attribute_name_is_known(name) {
          issues.push(
            attribute_issue(
              name,
              AttributeWarning,
              "unknown-attribute",
              "attribute name is not in the core set",
              None,
            ),
          )
        }
      }
    }
  }
  let error_count = issues
    .filter(fn(issue) { issue.severity == AttributeError })
    .length()
  let warning_count = issues
    .filter(fn(issue) { issue.severity == AttributeWarning })
    .length()
  let score = 100.0 -
    Double::from_int(error_count) * 25.0 -
    Double::from_int(warning_count) * 5.0
  {
    vertex_count,
    attributes: names,
    issues,
    valid: error_count == 0,
    complete: attributes.contains("POSITION") && error_count == 0,
    score: if score < 0.0 {
      0.0
    } else {
      score
    },
  }
}

///|
pub fn attribute_validation_for_primitive(
  primitive : GltfPrimitive,
  accessors : Array[GltfAccessor],
  policy : AttributeValidationPolicy,
) -> AttributeValidationReport {
  attribute_validation_report(primitive.attributes, accessors, policy)
}

///|
pub fn attribute_issue_codes(
  report : AttributeValidationReport,
) -> Array[String] {
  report.issues.map(fn(issue) { issue.code })
}

///|
pub fn attribute_issues_for_name(
  report : AttributeValidationReport,
  name : String,
) -> Array[AttributeValidationIssue] {
  report.issues.filter(fn(issue) { issue.attribute == name })
}

///|
pub fn attribute_report_has_code(
  report : AttributeValidationReport,
  code : String,
) -> Bool {
  report.issues.any(fn(issue) { issue.code == code })
}

///|
pub fn attribute_report_merge(
  left : AttributeValidationReport,
  right : AttributeValidationReport,
) -> AttributeValidationReport {
  let attributes = left.attributes.copy()
  for name in right.attributes {
    if !attributes.contains(name) {
      attributes.push(name)
    }
  }
  let issues = left.issues.copy()
  for issue in right.issues {
    issues.push(issue)
  }
  let errors = issues
    .filter(fn(issue) { issue.severity == AttributeError })
    .length()
  {
    vertex_count: if left.vertex_count > right.vertex_count {
      left.vertex_count
    } else {
      right.vertex_count
    },
    attributes,
    issues,
    valid: errors == 0,
    complete: left.complete && right.complete,
    score: (left.score + right.score) * 0.5,
  }
}

///|
pub fn attribute_report_lines(
  report : AttributeValidationReport,
) -> Array[String] {
  [
    "vertex_count=\{report.vertex_count}",
    "attributes=\{report.attributes.length()}",
    "issues=\{report.issues.length()}",
    "valid=\{report.valid}",
    "complete=\{report.complete}",
    "score=\{report.score}",
  ]
}
