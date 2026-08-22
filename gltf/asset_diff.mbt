///|
/// Structural asset diffing for CI regression detection.

///|
pub(all) enum AssetDiffKind {
  Added
  Removed
  Changed
  Unchanged
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AssetDifference {
  kind : AssetDiffKind
  category : String
  index : Int
  path : String
  before : String?
  after : String?
  severity : DiagnosticSeverity
  message : String
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AssetDiffReport {
  differences : Array[AssetDifference]
  added_count : Int
  removed_count : Int
  changed_count : Int
  unchanged_count : Int
  breaking_count : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct AssetDiffPolicy {
  fail_on_removed : Bool
  fail_on_changed : Bool
  compare_names : Bool
  compare_geometry : Bool
  compare_resources : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn default_asset_diff_policy() -> AssetDiffPolicy {
  {
    fail_on_removed: true,
    fail_on_changed: false,
    compare_names: true,
    compare_geometry: true,
    compare_resources: true,
  }
}

///|
fn difference(
  kind : AssetDiffKind,
  category : String,
  index : Int,
  path : String,
  before : String?,
  after : String?,
  severity : DiagnosticSeverity,
  message : String,
) -> AssetDifference {
  { kind, category, index, path, before, after, severity, message }
}

///|
fn compare_count(
  category : String,
  before : Int,
  after : Int,
  policy : AssetDiffPolicy,
  result : Array[AssetDifference],
) -> Unit {
  if before == after {
    result.push(
      difference(
        Unchanged,
        category,
        -1,
        category,
        Some("\{before}"),
        Some("\{after}"),
        Info,
        "count is unchanged",
      ),
    )
  } else if after > before {
    result.push(
      difference(
        Added,
        category,
        -1,
        category,
        Some("\{before}"),
        Some("\{after}"),
        Info,
        "count increased",
      ),
    )
  } else {
    result.push(
      difference(
        Removed,
        category,
        -1,
        category,
        Some("\{before}"),
        Some("\{after}"),
        if policy.fail_on_removed {
          Error
        } else {
          Warning
        },
        "count decreased",
      ),
    )
  }
}

///|
pub fn diff_documents(
  before : GltfDocument,
  after : GltfDocument,
  policy : AssetDiffPolicy,
) -> AssetDiffReport {
  let differences : Array[AssetDifference] = []
  compare_count(
    "scenes",
    before.scenes.length(),
    after.scenes.length(),
    policy,
    differences,
  )
  compare_count(
    "nodes",
    before.nodes.length(),
    after.nodes.length(),
    policy,
    differences,
  )
  compare_count(
    "meshes",
    before.meshes.length(),
    after.meshes.length(),
    policy,
    differences,
  )
  compare_count(
    "materials",
    before.materials.length(),
    after.materials.length(),
    policy,
    differences,
  )
  compare_count(
    "textures",
    before.textures.length(),
    after.textures.length(),
    policy,
    differences,
  )
  compare_count(
    "images",
    before.images.length(),
    after.images.length(),
    policy,
    differences,
  )
  compare_count(
    "buffers",
    before.buffers.length(),
    after.buffers.length(),
    policy,
    differences,
  )
  compare_count(
    "accessors",
    before.accessors.length(),
    after.accessors.length(),
    policy,
    differences,
  )
  compare_count(
    "animations",
    before.animations.length(),
    after.animations.length(),
    policy,
    differences,
  )
  compare_count(
    "skins",
    before.skins.length(),
    after.skins.length(),
    policy,
    differences,
  )
  if before.version != after.version {
    differences.push(
      difference(
        Changed,
        "asset",
        -1,
        "asset.version",
        Some(before.version),
        Some(after.version),
        Error,
        "asset version changed",
      ),
    )
  }
  if policy.compare_names {
    let count = if before.nodes.length() < after.nodes.length() {
      before.nodes.length()
    } else {
      after.nodes.length()
    }
    for index in 0..<count {
      if before.nodes[index].name != after.nodes[index].name {
        differences.push(
          difference(
            Changed,
            "nodes",
            index,
            "nodes[\{index}].name",
            before.nodes[index].name,
            after.nodes[index].name,
            if policy.fail_on_changed {
              Warning
            } else {
              Info
            },
            "node name changed",
          ),
        )
      }
    }
  }
  let added = differences.fold(init=0, (count, item) => {
    if item.kind == Added {
      count + 1
    } else {
      count
    }
  })
  let removed = differences.fold(init=0, (count, item) => {
    if item.kind == Removed {
      count + 1
    } else {
      count
    }
  })
  let changed = differences.fold(init=0, (count, item) => {
    if item.kind == Changed {
      count + 1
    } else {
      count
    }
  })
  let unchanged = differences.fold(init=0, (count, item) => {
    if item.kind == Unchanged {
      count + 1
    } else {
      count
    }
  })
  let breaking = differences.fold(init=0, (count, item) => {
    if item.severity == Error {
      count + 1
    } else {
      count
    }
  })
  {
    differences,
    added_count: added,
    removed_count: removed,
    changed_count: changed,
    unchanged_count: unchanged,
    breaking_count: breaking,
    valid: breaking == 0,
  }
}

///|
pub fn diff_has_breaking_changes(report : AssetDiffReport) -> Bool {
  report.breaking_count > 0
}

///|
pub fn diff_changes(report : AssetDiffReport) -> Array[AssetDifference] {
  report.differences.filter(item => item.kind != Unchanged)
}

///|
pub fn diff_errors(report : AssetDiffReport) -> Array[AssetDifference] {
  report.differences.filter(item => item.severity == Error)
}

///|
pub fn diff_summary_lines(report : AssetDiffReport) -> Array[String] {
  [
    "valid=\{report.valid}, added=\{report.added_count}, removed=\{report.removed_count}",
    "changed=\{report.changed_count}, unchanged=\{report.unchanged_count}",
    "breaking=\{report.breaking_count}",
  ]
}
