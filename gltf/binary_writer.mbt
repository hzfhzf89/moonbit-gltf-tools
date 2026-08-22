///|
/// Deterministic GLB construction and container verification.
///
/// Importers often need a normalized GLB artifact after validation. This
/// writer keeps JSON/BIN chunk alignment explicit, uses UTF-8 encoding without
/// host dependencies, and validates the generated container with the same
/// boundary rules as the reader.

///|
pub(all) suberror BinaryWriteError {
  EmptyJson
  InvalidJsonPadding
  ChunkTooLarge(length~ : Int)
  InvalidGlbLength
  Utf8Encoding
} derive(Debug, Eq)

///|
pub impl Show for BinaryWriteError with fn output(self, logger) {
  match self {
    EmptyJson => logger.write_string("BinaryWriteError: JSON chunk is empty")
    InvalidJsonPadding =>
      logger.write_string("BinaryWriteError: JSON chunk has invalid padding")
    ChunkTooLarge(length~) =>
      logger.write_string("BinaryWriteError: chunk is too large: \{length}")
    InvalidGlbLength =>
      logger.write_string("BinaryWriteError: GLB length is invalid")
    Utf8Encoding =>
      logger.write_string("BinaryWriteError: UTF-8 encoding failed")
  }
}

///|
pub(all) struct GlbBuildOptions {
  json_padding : Char
  bin_padding : Byte
  include_empty_bin : Bool
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GlbBuildReport {
  bytes : Bytes
  json_bytes : Int
  bin_bytes : Int
  json_padding_bytes : Int
  bin_padding_bytes : Int
  total_bytes : Int
  has_bin : Bool
  checksum : UInt
  valid : Bool
  errors : Array[String]
} derive(Debug, ToJson, Eq)

///|
pub(all) struct GlbChunkInfo {
  index : Int
  kind : String
  offset : Int
  length : Int
  valid : Bool
} derive(Debug, ToJson, Eq)

///|
pub fn default_glb_build_options() -> GlbBuildOptions {
  { json_padding: ' ', bin_padding: 0, include_empty_bin: false }
}

///|
pub fn glb_padding_length(length : Int) -> Int {
  if length < 0 {
    0
  } else {
    (4 - length % 4) % 4
  }
}

///|
pub fn glb_padded_length(length : Int) -> Int {
  length + glb_padding_length(length)
}

///|
pub fn glb_json_padding(json : String, padding : Char) -> String {
  let count = glb_padding_length(json.length())
  if count == 0 {
    json
  } else {
    json + String::make(count, padding)
  }
}

///|
pub fn glb_binary_padding(bin : Bytes, padding : Byte) -> Bytes {
  let count = glb_padding_length(bin.length())
  if count == 0 {
    bin
  } else {
    Bytes::add(bin, Bytes::make(count, padding))
  }
}

///|
pub fn utf8_encode_string(value : String) -> Bytes {
  let bytes : Array[Byte] = []
  for character in value {
    let code = character.to_int()
    if code < 0x80 {
      bytes.push(code.to_byte())
    } else if code < 0x800 {
      bytes.push((0xC0 | (code >> 6)).to_byte())
      bytes.push((0x80 | (code & 0x3F)).to_byte())
    } else {
      bytes.push((0xE0 | (code >> 12)).to_byte())
      bytes.push((0x80 | ((code >> 6) & 0x3F)).to_byte())
      bytes.push((0x80 | (code & 0x3F)).to_byte())
    }
  }
  Bytes::from_array(bytes)
}

///|
pub fn u32_to_le_bytes(value : UInt) -> Bytes {
  Bytes::from_array([
    (value & 0xFF).to_byte(),
    ((value >> 8) & 0xFF).to_byte(),
    ((value >> 16) & 0xFF).to_byte(),
    ((value >> 24) & 0xFF).to_byte(),
  ])
}

///|
pub fn glb_header_bytes(total_length : Int) -> Bytes {
  Bytes::add(
    Bytes::add(u32_to_le_bytes(0x46546C67), u32_to_le_bytes(2)),
    u32_to_le_bytes(total_length.reinterpret_as_uint()),
  )
}

///|
pub fn glb_chunk_bytes(chunk_type : UInt, data : Bytes) -> Bytes {
  Bytes::add(
    u32_to_le_bytes(data.length().reinterpret_as_uint()),
    Bytes::add(u32_to_le_bytes(chunk_type), data),
  )
}

///|
pub fn glb_json_chunk(json : String, padding : Char) -> Bytes {
  glb_chunk_bytes(
    0x4E4F534A,
    utf8_encode_string(glb_json_padding(json, padding)),
  )
}

///|
pub fn glb_bin_chunk(bin : Bytes, padding : Byte) -> Bytes {
  glb_chunk_bytes(0x004E4942, glb_binary_padding(bin, padding))
}

///|
pub fn build_glb(
  json : String,
  bin : Bytes,
  options? : GlbBuildOptions = default_glb_build_options(),
) -> Bytes raise BinaryWriteError {
  if json == "" {
    raise BinaryWriteError::EmptyJson
  }
  let json_chunk = glb_json_chunk(json, options.json_padding)
  let has_bin = bin.length() > 0 || options.include_empty_bin
  let bin_chunk = if has_bin {
    glb_bin_chunk(bin, options.bin_padding)
  } else {
    Bytes::from_array([])
  }
  let total = 12 + json_chunk.length() + bin_chunk.length()
  if total < 12 {
    raise BinaryWriteError::InvalidGlbLength
  }
  Bytes::add(glb_header_bytes(total), Bytes::add(json_chunk, bin_chunk))
}

///|
pub fn glb_chunk_infos(data : Bytes) -> Array[GlbChunkInfo] {
  let result : Array[GlbChunkInfo] = []
  if data.length() < 12 {
    result
  } else {
    let mut offset = 12
    let mut index = 0
    while offset + 8 <= data.length() {
      let length = read_u32_le(data, offset).reinterpret_as_int() catch {
        _ => 0
      }
      let chunk_type = read_u32_le(data, offset + 4) catch { _ => 0 }
      let kind = if chunk_type == 0x4E4F534A {
        "JSON"
      } else if chunk_type == 0x004E4942 {
        "BIN"
      } else {
        "UNKNOWN"
      }
      let valid = length >= 0 && offset + 8 + length <= data.length()
      result.push({ index, kind, offset, length, valid })
      if length <= 0 {
        break
      }
      offset += 8 + length
      index += 1
    }
    result
  }
}

///|
pub fn glb_has_json_chunk(data : Bytes) -> Bool {
  glb_chunk_infos(data).fold(init=false, (found, chunk) => {
    found || chunk.kind == "JSON"
  })
}

///|
pub fn glb_has_bin_chunk(data : Bytes) -> Bool {
  glb_chunk_infos(data).fold(init=false, (found, chunk) => {
    found || chunk.kind == "BIN"
  })
}

///|
pub fn glb_chunk_count(data : Bytes) -> Int {
  glb_chunk_infos(data).length()
}

///|
pub fn validate_glb_container(data : Bytes) -> Array[String] {
  let errors : Array[String] = []
  if data.length() < 12 {
    errors.push("GLB header is shorter than 12 bytes")
    errors
  } else {
    let magic = read_u32_le(data, 0) catch { _ => 0 }
    let version = read_u32_le(data, 4).reinterpret_as_int() catch { _ => 0 }
    let total = read_u32_le(data, 8).reinterpret_as_int() catch { _ => 0 }
    if magic != 0x46546C67 {
      errors.push("GLB magic is invalid")
    }
    if version != 2 {
      errors.push("GLB version is not 2")
    }
    if total != data.length() {
      errors.push("GLB declared length does not match input length")
    }
    let chunks = glb_chunk_infos(data)
    if chunks.length() == 0 {
      errors.push("GLB contains no complete chunks")
    }
    if !glb_has_json_chunk(data) {
      errors.push("GLB has no JSON chunk")
    }
    let mut seen_bin = false
    for chunk in chunks {
      if !chunk.valid {
        errors.push("GLB chunk exceeds input bounds")
      }
      if chunk.kind == "BIN" {
        if seen_bin {
          errors.push("GLB contains multiple BIN chunks")
        }
        seen_bin = true
      }
    }
    errors
  }
}

///|
pub fn build_glb_report(
  json : String,
  bin : Bytes,
  options? : GlbBuildOptions = default_glb_build_options(),
) -> GlbBuildReport {
  try {
    let bytes = build_glb(json, bin, options~)
    let json_bytes = utf8_encode_string(json).length()
    let padded_json = glb_padded_length(json_bytes)
    let padded_bin = glb_padded_length(bin.length())
    let errors = validate_glb_container(bytes)
    {
      bytes,
      json_bytes,
      bin_bytes: bin.length(),
      json_padding_bytes: padded_json - json_bytes,
      bin_padding_bytes: padded_bin - bin.length(),
      total_bytes: bytes.length(),
      has_bin: glb_has_bin_chunk(bytes),
      checksum: binary_checksum(bytes),
      valid: errors.length() == 0,
      errors,
    }
  } catch {
    error =>
      {
        bytes: Bytes::from_array([]),
        json_bytes: 0,
        bin_bytes: 0,
        json_padding_bytes: 0,
        bin_padding_bytes: 0,
        total_bytes: 0,
        has_bin: false,
        checksum: 0,
        valid: false,
        errors: ["\{error}"],
      }
  }
}

///|
pub fn glb_json_byte_count(data : Bytes) -> Int {
  glb_chunk_infos(data).fold(init=0, (sum, chunk) => {
    if chunk.kind == "JSON" {
      sum + chunk.length
    } else {
      sum
    }
  })
}

///|
pub fn glb_bin_byte_count(data : Bytes) -> Int {
  glb_chunk_infos(data).fold(init=0, (sum, chunk) => {
    if chunk.kind == "BIN" {
      sum + chunk.length
    } else {
      sum
    }
  })
}

///|
pub fn glb_alignment_overhead(data : Bytes) -> Int {
  glb_chunk_infos(data).fold(init=0, (sum, chunk) => {
    sum + glb_padding_length(chunk.length)
  })
}

///|
pub fn glb_report_summary_lines(report : GlbBuildReport) -> Array[String] {
  [
    "valid=\{report.valid}, total_bytes=\{report.total_bytes}",
    "json_bytes=\{report.json_bytes}, bin_bytes=\{report.bin_bytes}",
    "json_padding=\{report.json_padding_bytes}, bin_padding=\{report.bin_padding_bytes}",
    "checksum=\{report.checksum}, has_bin=\{report.has_bin}",
  ]
}
