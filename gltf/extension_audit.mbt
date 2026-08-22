///|
/// Extension usage audit for raw glTF JSON documents.
///
/// The core typed model intentionally focuses on the glTF 2.0 baseline. This
/// small raw-document audit preserves extension declarations so a production
/// importer can make an explicit compatibility decision before discarding
/// extension-specific fields.

///|
pub(all) struct ExtensionAudit {
  used : Array[String]
  required : Array[String]
  unsupported_required : Array[String]
  unknown_used : Array[String]
  duplicate_used : Array[String]
  duplicate_required : Array[String]
  required_not_used : Array[String]
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct ExtensionPolicy {
  supported : Array[String]
  allowed_required : Array[String]
  reject_unknown_used : Bool
  reject_unknown_required : Bool
  reject_duplicate_declarations : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn default_extension_policy() -> ExtensionPolicy {
  {
    supported: [
      "KHR_materials_pbrSpecularGlossiness", "KHR_materials_unlit", "KHR_texture_transform",
      "KHR_lights_punctual", "KHR_animation_pointer", "EXT_meshopt_compression",
      "KHR_draco_mesh_compression",
    ],
    allowed_required: [
      "KHR_materials_unlit", "KHR_texture_transform", "EXT_meshopt_compression",
    ],
    reject_unknown_used: false,
    reject_unknown_required: true,
    reject_duplicate_declarations: true,
  }
}

///|
fn string_array_field(root : Map[String, Json], key : String) -> Array[String] {
  match root.get(key) {
    Some(Json::Array(values)) => {
      let result : Array[String] = []
      for value in values {
        match value {
          Json::String(text) => result.push(text)
          _ => ()
        }
      }
      result
    }
    _ => []
  }
}

///|
fn duplicate_strings(values : Array[String]) -> Array[String] {
  let seen : Map[String, Bool] = Map([])
  let duplicates : Map[String, Bool] = Map([])
  for value in values {
    if seen.contains(value) {
      duplicates[value] = true
    } else {
      seen[value] = true
    }
  }
  duplicates.keys().collect()
}

///|
pub fn extension_audit(
  json : String,
  policy : ExtensionPolicy,
) -> ExtensionAudit raise ParseError {
  let root = @json.parse(json) catch {
    error => raise ParseError::InvalidJson(msg="\{Repr(error)}")
  }
  match root {
    Json::Object(object) => {
      let used = string_array_field(object, "extensionsUsed")
      let required = string_array_field(object, "extensionsRequired")
      let unsupported_required = required.filter(extension => {
        !policy.allowed_required.contains(extension)
      })
      let unknown_used = used.filter(extension => {
        !policy.supported.contains(extension)
      })
      let duplicate_used = duplicate_strings(used)
      let duplicate_required = duplicate_strings(required)
      let required_not_used = required.filter(extension => {
        !used.contains(extension)
      })
      let valid = (!policy.reject_unknown_used || unknown_used.length() == 0) &&
        (!policy.reject_unknown_required || unsupported_required.length() == 0) &&
        (
          !policy.reject_duplicate_declarations ||
          (duplicate_used.length() == 0 && duplicate_required.length() == 0)
        ) &&
        required_not_used.length() == 0
      {
        used,
        required,
        unsupported_required,
        unknown_used,
        duplicate_used,
        duplicate_required,
        required_not_used,
        valid,
      }
    }
    _ => raise ParseError::InvalidFieldType(field="root", expected="object")
  }
}

///|
pub fn extension_audit_default(
  json : String,
) -> ExtensionAudit raise ParseError {
  extension_audit(json, default_extension_policy())
}

///|
pub fn extension_is_used(audit : ExtensionAudit, extension : String) -> Bool {
  audit.used.contains(extension)
}

///|
pub fn extension_is_required(
  audit : ExtensionAudit,
  extension : String,
) -> Bool {
  audit.required.contains(extension)
}

///|
pub fn extension_usage_count(audit : ExtensionAudit) -> Int {
  audit.used.length()
}

///|
pub fn extension_required_count(audit : ExtensionAudit) -> Int {
  audit.required.length()
}

///|
pub fn extension_audit_issues(audit : ExtensionAudit) -> Array[String] {
  let result : Array[String] = []
  for extension in audit.unsupported_required {
    result.push("unsupported required extension: \{extension}")
  }
  for extension in audit.unknown_used {
    result.push("unknown used extension: \{extension}")
  }
  for extension in audit.duplicate_used {
    result.push("duplicate used extension: \{extension}")
  }
  for extension in audit.duplicate_required {
    result.push("duplicate required extension: \{extension}")
  }
  for extension in audit.required_not_used {
    result.push(
      "required extension is absent from extensionsUsed: \{extension}",
    )
  }
  result
}

///|
pub fn extension_audit_summary_lines(audit : ExtensionAudit) -> Array[String] {
  [
    "used=\{audit.used.length()}, required=\{audit.required.length()}, valid=\{audit.valid}",
    "unsupported_required=\{audit.unsupported_required.length()}, unknown_used=\{audit.unknown_used.length()}",
    "duplicates=\{audit.duplicate_used.length() + audit.duplicate_required.length()}",
  ]
}
