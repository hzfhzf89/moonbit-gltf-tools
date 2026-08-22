///|
/// Stable quality-gate aggregation for local tooling and CI annotations.
pub(all) enum QualityGateKind {
  Structural
  Geometry
  Materials
  Resources
  Runtime
  Performance
} derive(Debug, ToJson, Eq)

///|
pub(all) enum QualityGateStatus {
  Passed
  Warning
  Failed
  Skipped
} derive(Debug, ToJson, Eq)

///|
pub(all) struct QualityGateCheck {
  kind : QualityGateKind
  name : String
  status : QualityGateStatus
  score : Double
  findings : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct QualityGateMatrix {
  checks : Array[QualityGateCheck]
  passed : Int
  warnings : Int
  failed : Int
  skipped : Int
  score : Double
  release_ready : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct QualityGatePolicy {
  minimum_score : Double
  allow_warnings : Bool
  require_kinds : Array[QualityGateKind]
} derive(Debug, ToJson, Eq)

///|
pub fn quality_gate_kind_name(kind : QualityGateKind) -> String {
  match kind {
    Structural => "structural"
    Geometry => "geometry"
    Materials => "materials"
    Resources => "resources"
    Runtime => "runtime"
    Performance => "performance"
  }
}

///|
pub fn quality_gate_status_name(status : QualityGateStatus) -> String {
  match status {
    Passed => "passed"
    Warning => "warning"
    Failed => "failed"
    Skipped => "skipped"
  }
}

///|
pub fn quality_gate_check(
  kind : QualityGateKind,
  name : String,
  status : QualityGateStatus,
  score : Double,
  findings : Array[String],
) -> QualityGateCheck {
  { kind, name, status, score, findings }
}

///|
pub fn default_quality_gate_policy() -> QualityGatePolicy {
  {
    minimum_score: 80.0,
    allow_warnings: true,
    require_kinds: [Structural, Geometry, Resources],
  }
}

///|
pub fn quality_gate_matrix(
  checks : Array[QualityGateCheck],
) -> QualityGateMatrix {
  let mut passed = 0
  let mut warnings = 0
  let mut failed = 0
  let mut skipped = 0
  let mut score = 0.0
  for check in checks {
    score = score + check.score
    match check.status {
      Passed => passed = passed + 1
      Warning => warnings = warnings + 1
      Failed => failed = failed + 1
      Skipped => skipped = skipped + 1
    }
  }
  let evaluated = passed + warnings + failed
  let average = if evaluated == 0 {
    0.0
  } else {
    score / Double::from_int(evaluated)
  }
  {
    checks,
    passed,
    warnings,
    failed,
    skipped,
    score: average,
    release_ready: failed == 0 && average >= 80.0,
  }
}

///|
pub fn quality_gate_has_kind(
  matrix : QualityGateMatrix,
  kind : QualityGateKind,
) -> Bool {
  matrix.checks.any(fn(check) { check.kind == kind })
}

///|
pub fn quality_gate_missing_kinds(
  matrix : QualityGateMatrix,
  required : Array[QualityGateKind],
) -> Array[String] {
  required
  .filter(fn(kind) { !quality_gate_has_kind(matrix, kind) })
  .map(quality_gate_kind_name)
}

///|
pub fn quality_gate_release_check(
  matrix : QualityGateMatrix,
  policy : QualityGatePolicy,
) -> QualityGateMatrix {
  let missing = quality_gate_missing_kinds(matrix, policy.require_kinds)
  let checks = matrix.checks.copy()
  if missing.length() > 0 {
    checks.push(
      quality_gate_check(
        Structural,
        "required gate coverage",
        Failed,
        0.0,
        missing.map(fn(name) { "missing gate: \{name}" }),
      ),
    )
  }
  let result = quality_gate_matrix(checks)
  {
    ..result,
    release_ready: result.failed == 0 &&
    (policy.allow_warnings || result.warnings == 0) &&
    result.score >= policy.minimum_score,
  }
}

///|
pub fn quality_gate_summary_lines(matrix : QualityGateMatrix) -> Array[String] {
  [
    "checks=\{matrix.checks.length()}",
    "passed=\{matrix.passed}",
    "warnings=\{matrix.warnings}",
    "failed=\{matrix.failed}",
    "skipped=\{matrix.skipped}",
    "score=\{matrix.score}",
    "release_ready=\{matrix.release_ready}",
  ]
}
