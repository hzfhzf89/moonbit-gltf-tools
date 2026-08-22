///|
/// Stable report projections for CI logs, Markdown artifacts, and automation.

///|
pub(all) enum ReportFormat {
  Summary
  Json
  Markdown
  Lines
} derive(Debug, ToJson, Eq)

///|
pub(all) struct CiAnnotation {
  level : String
  code : String
  path : String
  message : String
  title : String
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ReportSection {
  title : String
  lines : Array[String]
  passed : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ReportBundle {
  title : String
  verdict : String
  score : Int
  sections : Array[ReportSection]
  annotations : Array[CiAnnotation]
  lines : Array[String]
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn ci_annotation(
  level : String,
  code : String,
  path : String,
  message : String,
  title : String,
) -> CiAnnotation {
  { level, code, path, message, title }
}

///|
pub fn report_section(
  title : String,
  lines : Array[String],
  passed : Bool,
) -> ReportSection {
  { title, lines, passed }
}

///|
pub fn report_bundle_from_profile(profile : ProductionProfile) -> ReportBundle {
  let sections : Array[ReportSection] = []
  sections.push(
    report_section(
      "Production",
      production_profile_summary_lines(profile),
      profile.gate.passed,
    ),
  )
  sections.push(
    report_section(
      "Semantic validation",
      semantic_report_summary_lines(profile.semantic),
      profile.semantic.valid,
    ),
  )
  sections.push(
    report_section(
      "Geometry",
      geometry_report_summary_lines(profile.geometry),
      profile.geometry.degenerate_triangle_count == 0,
    ),
  )
  sections.push(
    report_section(
      "Scene graph",
      scene_report_summary_lines(profile.scene),
      profile.scene.cycle_node_count == 0,
    ),
  )
  sections.push(
    report_section(
      "Resources",
      resource_manifest_summary_lines(profile.resources),
      profile.resources.valid,
    ),
  )
  sections.push(
    report_section(
      "Optimization",
      optimization_plan_summary_lines(profile.optimization),
      !optimization_plan_has_blockers(profile.optimization),
    ),
  )
  let annotations : Array[CiAnnotation] = []
  for issue in profile.semantic.issues {
    annotations.push(
      ci_annotation(
        semantic_severity_name(issue.severity),
        issue.rule,
        issue.path,
        issue.message,
        "glTF semantic validation",
      ),
    )
  }
  for line in profile.gate.violations {
    annotations.push(
      ci_annotation(
        "error", "PRODUCTION_GATE", "production", line, "Production quality gate",
      ),
    )
  }
  let lines : Array[String] = []
  for section in sections {
    lines.push("## \{section.title}")
    for line in section.lines {
      lines.push(line)
    }
  }
  {
    title: "moonbit-gltf-tools asset report",
    verdict: production_verdict_name(profile.verdict),
    score: profile.gate.score,
    sections,
    annotations,
    lines,
    valid: profile.gate.passed,
  }
}

///|
pub fn report_bundle_summary(bundle : ReportBundle) -> String {
  "\{bundle.title}: verdict=\{bundle.verdict}, score=\{bundle.score}, valid=\{bundle.valid}"
}

///|
pub fn report_bundle_json(bundle : ReportBundle) -> String {
  Repr(bundle).to_string()
}

///|
pub fn report_bundle_lines(bundle : ReportBundle) -> Array[String] {
  bundle.lines
}

///|
pub fn report_bundle_markdown(bundle : ReportBundle) -> String {
  let builder = StringBuilder()
  builder.write_string("# ")
  builder.write_string(bundle.title)
  builder.write_string("\n\n")
  builder.write_string(
    "Verdict: **\{bundle.verdict}**  \nScore: **\{bundle.score}/100**\n\n",
  )
  for section in bundle.sections {
    builder.write_string("## \{section.title}\n\n")
    for line in section.lines {
      builder.write_string("- \{line}\n")
    }
    builder.write_string("\n")
  }
  builder.to_string()
}

///|
pub fn report_bundle_annotations(bundle : ReportBundle) -> Array[String] {
  bundle.annotations.map(annotation => {
    "::notice title=\{annotation.title},file=\{annotation.path}::\{annotation.code}: \{annotation.message}"
  })
}

///|
pub fn report_bundle_has_errors(bundle : ReportBundle) -> Bool {
  !bundle.valid
}

///|
pub fn report_bundle_section(
  bundle : ReportBundle,
  title : String,
) -> ReportSection? {
  for section in bundle.sections {
    if section.title == title {
      return Some(section)
    }
  }
  None
}

///|
pub fn report_bundle_failed_sections(bundle : ReportBundle) -> Array[String] {
  bundle.sections
  .filter(section => !section.passed)
  .map(section => section.title)
}

///|
pub fn report_bundle_summary_lines(bundle : ReportBundle) -> Array[String] {
  [
    report_bundle_summary(bundle),
    "sections=\{bundle.sections.length()}, annotations=\{bundle.annotations.length()}",
    "failed_sections=\{report_bundle_failed_sections(bundle).join(",")}",
  ]
}
