///|
/// Import pipeline planning and stage accounting.
///
/// A production importer benefits from explicit stage boundaries. This module
/// describes the dependency order between parsing, binary decoding, semantic
/// validation, optimization, and packaging, so a CLI or build service can
/// report a failed stage without hiding the successful work before it.

///|
pub(all) enum ImportStageKind {
  ParseDocument
  LoadBinary
  ValidateStructure
  ValidateSemantics
  AuditLayout
  AnalyzeGeometry
  AnalyzeMaterials
  AuditResources
  AnalyzeAnimations
  AnalyzeSkins
  BuildOptimizationPlan
  BuildPackagePlan
  EmitReport
} derive(Debug, ToJson, Eq)

///|
pub(all) enum ImportStageStatus {
  Pending
  Running
  Passed
  PassedWithWarnings
  Failed
  Skipped
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ImportStage {
  index : Int
  kind : ImportStageKind
  name : String
  dependencies : Array[Int]
  status : ImportStageStatus
  duration_hint_ms : Int
  blocking : Bool
  messages : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ImportPipeline {
  stages : Array[ImportStage]
  valid : Bool
  completed_count : Int
  failed_count : Int
  warning_count : Int
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ImportPipelinePolicy {
  fail_on_semantic_error : Bool
  fail_on_layout_error : Bool
  fail_on_unsafe_resource : Bool
  run_optimization : Bool
  run_packaging : Bool
  emit_report : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn default_import_pipeline_policy() -> ImportPipelinePolicy {
  {
    fail_on_semantic_error: true,
    fail_on_layout_error: true,
    fail_on_unsafe_resource: true,
    run_optimization: true,
    run_packaging: true,
    emit_report: true,
  }
}

///|
pub fn import_stage_name(kind : ImportStageKind) -> String {
  match kind {
    ParseDocument => "parse-document"
    LoadBinary => "load-binary"
    ValidateStructure => "validate-structure"
    ValidateSemantics => "validate-semantics"
    AuditLayout => "audit-layout"
    AnalyzeGeometry => "analyze-geometry"
    AnalyzeMaterials => "analyze-materials"
    AuditResources => "audit-resources"
    AnalyzeAnimations => "analyze-animations"
    AnalyzeSkins => "analyze-skins"
    BuildOptimizationPlan => "build-optimization-plan"
    BuildPackagePlan => "build-package-plan"
    EmitReport => "emit-report"
  }
}

///|
pub fn import_stage_is_terminal(status : ImportStageStatus) -> Bool {
  status == Passed ||
  status == PassedWithWarnings ||
  status == Failed ||
  status == Skipped
}

///|
pub fn import_stage_is_success(status : ImportStageStatus) -> Bool {
  status == Passed || status == PassedWithWarnings
}

///|
pub fn import_stage_status_name(status : ImportStageStatus) -> String {
  match status {
    Pending => "pending"
    Running => "running"
    Passed => "passed"
    PassedWithWarnings => "passed-with-warnings"
    Failed => "failed"
    Skipped => "skipped"
  }
}

///|
fn stage(
  index : Int,
  kind : ImportStageKind,
  dependencies : Array[Int],
  blocking : Bool,
) -> ImportStage {
  {
    index,
    kind,
    name: import_stage_name(kind),
    dependencies,
    status: Pending,
    duration_hint_ms: 0,
    blocking,
    messages: [],
  }
}

///|
pub fn default_import_stages() -> Array[ImportStage] {
  [
    stage(0, ParseDocument, [], true),
    stage(1, LoadBinary, [0], true),
    stage(2, ValidateStructure, [0], true),
    stage(3, ValidateSemantics, [2], true),
    stage(4, AuditLayout, [1, 2], true),
    stage(5, AnalyzeGeometry, [1, 3, 4], false),
    stage(6, AnalyzeMaterials, [3], false),
    stage(7, AuditResources, [2, 3], true),
    stage(8, AnalyzeAnimations, [1, 3, 4], false),
    stage(9, AnalyzeSkins, [1, 3, 4], false),
    stage(10, BuildOptimizationPlan, [5, 6, 7, 8, 9], false),
    stage(11, BuildPackagePlan, [7], false),
    stage(12, EmitReport, [5, 6, 7, 8, 9, 10, 11], false),
  ]
}

///|
pub fn import_pipeline_stage(
  pipeline : ImportPipeline,
  kind : ImportStageKind,
) -> ImportStage? {
  for stage in pipeline.stages {
    if stage.kind == kind {
      return Some(stage)
    }
  }
  None
}

///|
pub fn import_pipeline_pending_stages(
  pipeline : ImportPipeline,
) -> Array[ImportStage] {
  pipeline.stages.filter(stage => stage.status == Pending)
}

///|
pub fn import_pipeline_failed_stages(
  pipeline : ImportPipeline,
) -> Array[ImportStage] {
  pipeline.stages.filter(stage => stage.status == Failed)
}

///|
pub fn import_pipeline_ready_stages(
  pipeline : ImportPipeline,
) -> Array[ImportStage] {
  let ready : Array[ImportStage] = []
  for stage in pipeline.stages {
    if stage.status == Pending {
      let dependencies_ready = stage.dependencies.fold(init=true, (
        passed,
        dependency,
      ) => {
        match pipeline.stages.get(dependency) {
          Some(value) => passed && import_stage_is_success(value.status)
          None => false
        }
      })
      if dependencies_ready {
        ready.push(stage)
      }
    }
  }
  ready
}

///|
pub fn import_pipeline_mark_stage(
  pipeline : ImportPipeline,
  kind : ImportStageKind,
  status : ImportStageStatus,
  messages : Array[String],
) -> ImportPipeline {
  let stages : Array[ImportStage] = []
  for stage in pipeline.stages {
    if stage.kind == kind {
      stages.push({ ..stage, status, messages })
    } else {
      stages.push(stage)
    }
  }
  let completed = stages.fold(init=0, (count, stage) => {
    if import_stage_is_terminal(stage.status) {
      count + 1
    } else {
      count
    }
  })
  let failed = stages.fold(init=0, (count, stage) => {
    if stage.status == Failed {
      count + 1
    } else {
      count
    }
  })
  let warnings = stages.fold(init=0, (count, stage) => {
    if stage.status == PassedWithWarnings {
      count + 1
    } else {
      count
    }
  })
  {
    stages,
    valid: failed == 0,
    completed_count: completed,
    failed_count: failed,
    warning_count: warnings,
  }
}

///|
pub fn import_pipeline_from_profile(
  doc : GltfDocument,
  profile : ProductionProfile,
  policy : ImportPipelinePolicy,
) -> ImportPipeline {
  let base = {
    stages: default_import_stages(),
    valid: true,
    completed_count: 0,
    failed_count: 0,
    warning_count: 0,
  }
  let mut pipeline = base
  pipeline = import_pipeline_mark_stage(pipeline, ParseDocument, Passed, [])
  pipeline = import_pipeline_mark_stage(pipeline, LoadBinary, Passed, [])
  pipeline = import_pipeline_mark_stage(
    pipeline,
    ValidateStructure,
    if profile.asset_report.diagnostics.errors == 0 {
      Passed
    } else {
      Failed
    },
    diagnostics_to_lines(profile.asset_report.diagnostics),
  )
  pipeline = import_pipeline_mark_stage(
    pipeline,
    ValidateSemantics,
    if profile.semantic.errors == 0 || !policy.fail_on_semantic_error {
      if profile.semantic.warnings > 0 {
        PassedWithWarnings
      } else {
        Passed
      }
    } else {
      Failed
    },
    semantic_issue_lines(profile.semantic),
  )
  let layout_policy = {
    ..default_buffer_layout_policy(),
    reject_overlaps: policy.fail_on_layout_error,
  }
  let layout = buffer_layout_report(doc, layout_policy)
  pipeline = import_pipeline_mark_stage(
    pipeline,
    AuditLayout,
    if layout.valid || !policy.fail_on_layout_error {
      Passed
    } else {
      Failed
    },
    buffer_layout_summary_lines(layout),
  )
  pipeline = import_pipeline_mark_stage(pipeline, AnalyzeGeometry, Passed, [])
  pipeline = import_pipeline_mark_stage(pipeline, AnalyzeMaterials, Passed, [])
  pipeline = import_pipeline_mark_stage(
    pipeline,
    AuditResources,
    if profile.resources.unsafe_count == 0 || !policy.fail_on_unsafe_resource {
      Passed
    } else {
      Failed
    },
    resource_manifest_summary_lines(profile.resources),
  )
  pipeline = import_pipeline_mark_stage(pipeline, AnalyzeAnimations, Passed, [])
  pipeline = import_pipeline_mark_stage(pipeline, AnalyzeSkins, Passed, [])
  pipeline = import_pipeline_mark_stage(
    pipeline,
    BuildOptimizationPlan,
    if policy.run_optimization {
      Passed
    } else {
      Skipped
    },
    optimization_plan_summary_lines(profile.optimization),
  )
  pipeline = import_pipeline_mark_stage(
    pipeline,
    BuildPackagePlan,
    if policy.run_packaging {
      Passed
    } else {
      Skipped
    },
    [],
  )
  pipeline = import_pipeline_mark_stage(
    pipeline,
    EmitReport,
    if policy.emit_report {
      Passed
    } else {
      Skipped
    },
    production_profile_summary_lines(profile),
  )
  pipeline
}

///|
pub fn import_pipeline_is_complete(pipeline : ImportPipeline) -> Bool {
  pipeline.completed_count == pipeline.stages.length()
}

///|
pub fn import_pipeline_has_blocker(pipeline : ImportPipeline) -> Bool {
  for stage in pipeline.stages {
    if stage.status == Failed && stage.blocking {
      return true
    }
  }
  false
}

///|
pub fn import_pipeline_progress(pipeline : ImportPipeline) -> Double {
  if pipeline.stages.length() == 0 {
    1.0
  } else {
    pipeline.completed_count.to_double() / pipeline.stages.length().to_double()
  }
}

///|
pub fn import_pipeline_stage_lines(pipeline : ImportPipeline) -> Array[String] {
  pipeline.stages.map(stage => {
    let message = if stage.messages.length() == 0 {
      ""
    } else {
      ": \{stage.messages[0]}"
    }
    "\{stage.index}. \{stage.name}=\{import_stage_status_name(stage.status)}\{message}"
  })
}

///|
pub fn import_pipeline_summary_lines(
  pipeline : ImportPipeline,
) -> Array[String] {
  [
    "complete=\{import_pipeline_is_complete(pipeline)}, progress=\{import_pipeline_progress(pipeline)}",
    "passed=\{pipeline.completed_count - pipeline.failed_count}, failed=\{pipeline.failed_count}, warnings=\{pipeline.warning_count}",
    "blocker=\{import_pipeline_has_blocker(pipeline)}",
  ]
}
