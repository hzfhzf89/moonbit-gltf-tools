///|
/// URI classification used by packaging and dependency auditing. It never
/// touches the filesystem, which keeps analysis deterministic and safe.

///|
pub(all) enum UriKind {
  Data
  Relative
  Absolute
  Fragment
  Empty
} derive(Debug, ToJson, Eq)

///|
pub(all) struct UriInfo {
  value : String
  kind : UriKind
  scheme : String?
  media_type : String?
  encoded : Bool
} derive(Debug, ToJson, Eq)

///|
fn find_colon(value : String) -> Int? {
  let mut index = 0
  for character in value {
    if character == ':' {
      return Some(index)
    }
    index += 1
  }
  None
}

///|
fn find_character(value : String, target : Char) -> Int? {
  let mut index = 0
  for character in value {
    if character == target {
      return Some(index)
    }
    index += 1
  }
  None
}

///|
pub fn classify_uri(value : String) -> UriKind {
  if value == "" {
    Empty
  } else if value.has_prefix("#") {
    Fragment
  } else if value.has_prefix("data:") {
    Data
  } else if find_colon(value) is Some(_) {
    Absolute
  } else {
    Relative
  }
}

///|
pub fn uri_scheme(value : String) -> String? {
  match find_colon(value) {
    Some(index) => if index > 0 { Some(value[:index].to_owned()) } else { None }
    None => None
  }
}

///|
pub fn uri_data_media_type(value : String) -> String? {
  if !value.has_prefix("data:") {
    return None
  }
  let comma = find_character(value, ',')
  match comma {
    Some(index) => {
      let header = value[5:index].to_owned()
      let semicolon = find_character(header, ';')
      match semicolon {
        Some(position) => Some(header[:position].to_owned())
        None => if header == "" { None } else { Some(header) }
      }
    }
    None => None
  }
}

///|
pub fn uri_is_base64(value : String) -> Bool {
  if !value.has_prefix("data:") {
    false
  } else {
    value.contains(";base64,")
  }
}

///|
pub fn uri_is_safe_external(value : String) -> Bool {
  match classify_uri(value) {
    Relative => !value.contains("..")
    Data | Fragment | Empty => true
    Absolute => false
  }
}

///|
pub fn inspect_uri(value : String) -> UriInfo {
  {
    value,
    kind: classify_uri(value),
    scheme: uri_scheme(value),
    media_type: uri_data_media_type(value),
    encoded: uri_is_base64(value),
  }
}

///|
pub fn normalize_relative_uri(value : String) -> String {
  let replaced = value.replace(old="\\", new="/")
  let parts = replaced.split("/")
  let output : Array[String] = []
  for part in parts {
    if part == "" || part == "." {
      continue
    }
    if part == ".." {
      if output.length() > 0 {
        ignore(output.pop())
      }
    } else {
      output.push(part.to_owned())
    }
  }
  output.join("/")
}

///|
pub fn uri_extension(value : String) -> String? {
  let normalized = normalize_relative_uri(value)
  let parts : Array[StringView] = normalized.split(".").collect()
  if parts.length() > 1 {
    Some(parts[parts.length() - 1].to_owned())
  } else {
    None
  }
}

///|
pub fn uri_is_image(value : String) -> Bool {
  match uri_data_media_type(value) {
    Some(media) => media.has_prefix("image/")
    None =>
      match uri_extension(value) {
        Some(ext) =>
          ext == "png" ||
          ext == "jpg" ||
          ext == "jpeg" ||
          ext == "webp" ||
          ext == "ktx2"
        None => false
      }
  }
}

///|
pub fn uri_is_buffer(value : String) -> Bool {
  match uri_data_media_type(value) {
    Some(media) => media == "application/octet-stream"
    None =>
      match uri_extension(value) {
        Some(ext) => ext == "bin" || ext == "buffer"
        None => false
      }
  }
}

///|
pub fn document_external_uris(doc : GltfDocument) -> Array[UriInfo] {
  let output : Array[UriInfo] = []
  let deps = collect_resource_deps(doc)
  for uri in deps.external_uris {
    output.push(inspect_uri(uri))
  }
  output
}

///|
pub fn document_unsafe_uri_count(doc : GltfDocument) -> Int {
  document_external_uris(doc).fold(init=0, (count, info) => {
    if uri_is_safe_external(info.value) {
      count
    } else {
      count + 1
    }
  })
}

///|
pub fn document_image_uri_count(doc : GltfDocument) -> Int {
  document_external_uris(doc).fold(init=0, (count, info) => {
    if uri_is_image(info.value) {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn document_buffer_uri_count(doc : GltfDocument) -> Int {
  document_external_uris(doc).fold(init=0, (count, info) => {
    if uri_is_buffer(info.value) {
      count + 1
    } else {
      count
    }
  })
}
